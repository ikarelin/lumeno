create table public.clinics (
                                id uuid primary key default gen_random_uuid(),

                                name text not null
                                    check (char_length(trim(name)) > 0),

                                created_by_user_id uuid
                                          references auth.users(id)
                                              on delete set null,

                                created_at timestamptz not null default now(),
                                updated_at timestamptz not null default now()
);


comment on table public.clinics is
  'Clinics available to Lumeno doctors through doctor_clinics membership.';


create table public.doctor_clinics (
                                       doctor_user_id uuid not null
                                           references public.doctor_profiles(user_id)
                                               on delete cascade,

                                       clinic_id uuid not null
                                           references public.clinics(id)
                                               on delete cascade,

                                       created_at timestamptz not null default now(),

                                       primary key (
                                                    doctor_user_id,
                                                    clinic_id
                                           )
);


comment on table public.doctor_clinics is
  'Many-to-many relationship between Lumeno doctors and clinics.';


create index clinics_created_by_user_id_idx
    on public.clinics(created_by_user_id);


create index doctor_clinics_clinic_id_idx
    on public.doctor_clinics(clinic_id);


create trigger clinics_set_updated_at
    before update on public.clinics
    for each row
    execute function public.set_updated_at();


-- Keep privileged trigger logic outside the exposed public schema.
create schema if not exists private;

revoke all
    on schema private
    from public;


-- A newly created clinic is attached to its creator in the same
-- database transaction. If membership creation fails, clinic
-- creation fails as well.
create or replace function private.attach_clinic_creator()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
insert into public.doctor_clinics (
    doctor_user_id,
    clinic_id
)
values (
           new.created_by_user_id,
           new.id
       );

return new;
end;
$$;


revoke execute
    on function private.attach_clinic_creator()
    from public;


create trigger clinics_attach_creator
    after insert on public.clinics
    for each row
    execute function private.attach_clinic_creator();


alter table public.clinics
    enable row level security;


alter table public.doctor_clinics
    enable row level security;


-- A doctor may read only clinics to which they belong.
-- The creator condition also guarantees that INSERT ... RETURNING
-- can return a newly created clinic safely.
create policy "Doctors can read their clinics"
on public.clinics
for select
               to authenticated
               using (
               created_by_user_id = (select auth.uid())
               or exists (
               select 1
               from public.doctor_clinics
               where
               doctor_clinics.clinic_id = clinics.id
               and doctor_clinics.doctor_user_id = (select auth.uid())
               )
               );


-- Clinic creation is limited to the authenticated doctor account.
create policy "Doctors can create clinics"
on public.clinics
for insert
to authenticated
with check (
  created_by_user_id = (select auth.uid())
  and exists (
    select 1
    from public.doctor_profiles
    where
      doctor_profiles.user_id = (select auth.uid())
  )
);


-- Membership rows are readable only by the doctor they belong to.
create policy "Doctors can read own clinic memberships"
on public.doctor_clinics
for select
                      to authenticated
                      using (
                      doctor_user_id = (select auth.uid())
                      );


revoke all
    on table public.clinics
    from anon;


revoke all
    on table public.clinics
    from authenticated;


grant select, insert
    on table public.clinics
    to authenticated;


revoke all
    on table public.doctor_clinics
    from anon;


revoke all
    on table public.doctor_clinics
    from authenticated;


grant select
    on table public.doctor_clinics
    to authenticated;