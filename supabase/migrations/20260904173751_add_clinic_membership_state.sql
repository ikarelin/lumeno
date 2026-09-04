alter table public.doctor_clinics
    add column is_default boolean not null default false,
add column archived_at timestamptz;

comment on column public.doctor_clinics.is_default is
  'Whether this clinic is the doctor default clinic for new workflows.';

comment on column public.doctor_clinics.archived_at is
  'When set, the doctor no longer actively works at this clinic. Historical data remains accessible.';

alter table public.doctor_clinics
    add constraint doctor_clinics_default_must_be_active
        check (
            not is_default
                or archived_at is null
            );

-- Existing doctors need one deterministic default clinic.
-- The oldest current membership becomes the initial default.
with ranked_memberships as (
    select
        doctor_user_id,
        clinic_id,
        row_number() over (
      partition by doctor_user_id
      order by created_at, clinic_id
    ) as position
from public.doctor_clinics
where archived_at is null
    )
update public.doctor_clinics
set is_default = true
    from ranked_memberships
where
    doctor_clinics.doctor_user_id =
    ranked_memberships.doctor_user_id
  and doctor_clinics.clinic_id =
    ranked_memberships.clinic_id
  and ranked_memberships.position = 1;

-- A doctor may have at most one default clinic.
create unique index doctor_clinics_one_default_per_doctor_idx
    on public.doctor_clinics(doctor_user_id)
    where is_default;

-- A newly created clinic becomes the default only when the doctor
-- does not currently have one.
create or replace function private.attach_clinic_creator()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
should_be_default boolean;
begin
  -- Serialize clinic-membership changes for one doctor.
  perform 1
  from public.doctor_profiles
  where user_id = new.created_by_user_id
  for update;

select not exists (
    select 1
    from public.doctor_clinics
    where
        doctor_clinics.doctor_user_id =
        new.created_by_user_id
      and doctor_clinics.is_default
)
into should_be_default;

insert into public.doctor_clinics (
    doctor_user_id,
    clinic_id,
    is_default
)
values (
           new.created_by_user_id,
           new.id,
           should_be_default
       );

return new;
end;
$$;

revoke execute
    on function private.attach_clinic_creator()
    from public;

-- Default switching is intentionally exposed as one atomic RPC.
-- Direct UPDATE access to doctor_clinics remains disabled.
create or replace function public.set_default_clinic(
  p_clinic_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
current_user_id uuid := auth.uid();
begin
  if current_user_id is null then
    raise exception 'Authentication required.';
end if;

  -- Serialize clinic-membership changes for this doctor.
  perform 1
  from public.doctor_profiles
  where user_id = current_user_id
  for update;

if not exists (
    select 1
    from public.doctor_clinics
    where
      doctor_user_id = current_user_id
      and clinic_id = p_clinic_id
      and archived_at is null
  ) then
    raise exception 'Active clinic membership not found.';
end if;

update public.doctor_clinics
set is_default = false
where
    doctor_user_id = current_user_id
  and is_default;

update public.doctor_clinics
set is_default = true
where
    doctor_user_id = current_user_id
  and clinic_id = p_clinic_id
  and archived_at is null;
end;
$$;

revoke execute
    on function public.set_default_clinic(uuid)
    from public;

revoke execute
    on function public.set_default_clinic(uuid)
    from anon;

grant execute
on function public.set_default_clinic(uuid)
to authenticated;

-- Archiving removes the clinic from the doctor's active workspace,
-- but never destroys the clinic or historical references.
create or replace function public.archive_clinic_membership(
  p_clinic_id uuid
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
current_user_id uuid := auth.uid();
  replacement_clinic_id uuid;
begin
  if current_user_id is null then
    raise exception 'Authentication required.';
end if;

  -- Serialize clinic-membership changes for this doctor.
  perform 1
  from public.doctor_profiles
  where user_id = current_user_id
  for update;

if not exists (
    select 1
    from public.doctor_clinics
    where
      doctor_user_id = current_user_id
      and clinic_id = p_clinic_id
      and archived_at is null
  ) then
    raise exception 'Active clinic membership not found.';
end if;

update public.doctor_clinics
set
    archived_at = now(),
    is_default = false
where
    doctor_user_id = current_user_id
  and clinic_id = p_clinic_id;

-- If the archived clinic was the default, promote the oldest
-- remaining active clinic. If none remain, having no default
-- is a valid state.
if not exists (
    select 1
    from public.doctor_clinics
    where
      doctor_user_id = current_user_id
      and is_default
  ) then
select clinic_id
into replacement_clinic_id
from public.doctor_clinics
where
    doctor_user_id = current_user_id
  and archived_at is null
order by created_at, clinic_id
    limit 1;

if replacement_clinic_id is not null then
update public.doctor_clinics
set is_default = true
where
    doctor_user_id = current_user_id
  and clinic_id = replacement_clinic_id;
end if;
end if;
end;
$$;

revoke execute
    on function public.archive_clinic_membership(uuid)
    from public;

revoke execute
    on function public.archive_clinic_membership(uuid)
    from anon;

grant execute
on function public.archive_clinic_membership(uuid)
to authenticated;