create table public.doctor_profiles (
  user_id uuid primary key
    references auth.users(id)
    on delete cascade,

  full_name text not null
    check (char_length(trim(full_name)) > 0),

  specialty text not null
    check (char_length(trim(specialty)) > 0),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.doctor_profiles is
  'Doctor profile data owned by the authenticated Lumeno account.';


create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;


create trigger doctor_profiles_set_updated_at
before update on public.doctor_profiles
for each row
execute function public.set_updated_at();


alter table public.doctor_profiles
enable row level security;


create policy "Users can read own doctor profile"
on public.doctor_profiles
for select
to authenticated
using (
  (select auth.uid()) = user_id
);


create policy "Users can create own doctor profile"
on public.doctor_profiles
for insert
to authenticated
with check (
  (select auth.uid()) = user_id
);


create policy "Users can update own doctor profile"
on public.doctor_profiles
for update
to authenticated
using (
  (select auth.uid()) = user_id
)
with check (
  (select auth.uid()) = user_id
);

revoke all
on table public.doctor_profiles
from anon;

revoke all
on table public.doctor_profiles
from authenticated;

grant select, insert, update
on table public.doctor_profiles
to authenticated;


-- Backfill doctors that already completed Doctor Setup while
-- profile data was temporarily stored in Auth user metadata.
insert into public.doctor_profiles (
  user_id,
  full_name,
  specialty
)
select
  id,
  trim(raw_user_meta_data ->> 'doctor_name'),
  trim(raw_user_meta_data ->> 'specialty')
from auth.users
where
  raw_user_meta_data -> 'doctor_setup_completed' = 'true'::jsonb
  and nullif(
    trim(raw_user_meta_data ->> 'doctor_name'),
    ''
  ) is not null
  and nullif(
    trim(raw_user_meta_data ->> 'specialty'),
    ''
  ) is not null
on conflict (user_id) do nothing;

