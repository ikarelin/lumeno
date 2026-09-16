create table public.schedule_day_exceptions (
  doctor_user_id uuid not null
    references public.doctor_profiles(user_id)
    on delete cascade,

  day date not null,
  is_working_day boolean not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  primary key (doctor_user_id, day)
);

comment on table public.schedule_day_exceptions is
  'One-date doctor schedule overrides. Visits remain independent and are never removed when a date is marked Day off.';

create trigger schedule_day_exceptions_set_updated_at
  before update on public.schedule_day_exceptions
  for each row
  execute function public.set_updated_at();

alter table public.schedule_day_exceptions enable row level security;

create policy "Doctors can read own schedule day exceptions"
on public.schedule_day_exceptions
for select
to authenticated
using (doctor_user_id = (select auth.uid()));

create policy "Doctors can create own schedule day exceptions"
on public.schedule_day_exceptions
for insert
to authenticated
with check (doctor_user_id = (select auth.uid()));

create policy "Doctors can update own schedule day exceptions"
on public.schedule_day_exceptions
for update
to authenticated
using (doctor_user_id = (select auth.uid()))
with check (doctor_user_id = (select auth.uid()));

revoke all on table public.schedule_day_exceptions from anon;
revoke all on table public.schedule_day_exceptions from authenticated;
grant select, insert, update on table public.schedule_day_exceptions to authenticated;
