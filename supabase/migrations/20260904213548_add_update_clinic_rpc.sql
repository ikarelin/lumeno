create or replace function public.update_clinic(
  p_clinic_id uuid,
  p_name text,
  p_address text default null
)
returns public.clinics
language plpgsql
security definer
set search_path = ''
as $$
declare
v_user_id uuid := auth.uid();
  v_clinic public.clinics;
begin
  if v_user_id is null then
    raise exception 'Authentication required.'
      using errcode = '42501';
end if;

  if p_clinic_id is null then
    raise exception 'Clinic id is required.'
      using errcode = '22023';
end if;

  if p_name is null
      or char_length(trim(p_name)) = 0 then
    raise exception 'Clinic name is required.'
      using errcode = '22023';
end if;

update public.clinics as clinic
set
    name = trim(p_name),
    address = nullif(
            trim(coalesce(p_address, '')),
            ''
              )
where
    clinic.id = p_clinic_id
  and clinic.created_by_user_id = v_user_id
  and exists (
    select 1
    from public.doctor_clinics as membership
    where
        membership.doctor_user_id = v_user_id
      and membership.clinic_id = clinic.id
      and membership.archived_at is null
)
    returning clinic.*
into v_clinic;

if v_clinic.id is null then
    raise exception
      'Clinic not found or cannot be edited.'
      using errcode = '42501';
end if;

return v_clinic;
end;
$$;


comment on function public.update_clinic(
  uuid,
  text,
  text
) is
  'Updates a clinic created by the authenticated doctor while their clinic membership is active.';


revoke all
    on function public.update_clinic(
    uuid,
    text,
    text
    )
    from public;


revoke all
    on function public.update_clinic(
    uuid,
    text,
    text
    )
    from anon;


grant execute
on function public.update_clinic(
  uuid,
  text,
  text
)
to authenticated;