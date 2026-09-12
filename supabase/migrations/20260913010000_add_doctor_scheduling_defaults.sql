alter table public.doctor_profiles
  add column if not exists default_duration_minutes integer not null default 30
    check (default_duration_minutes between 15 and 240),
  add column if not exists working_days integer[] not null default '{1,2,3,4,5}',
  add column if not exists workday_start time not null default '09:00',
  add column if not exists workday_end time not null default '18:00',
  add column if not exists break_start time,
  add column if not exists break_end time;

alter table public.doctor_profiles
  add constraint doctor_profiles_workday_order
  check (workday_start < workday_end);

alter table public.doctor_profiles
  add constraint doctor_profiles_break_pair
  check (
    (break_start is null and break_end is null)
    or (break_start is not null and break_end is not null and break_start < break_end)
  );
