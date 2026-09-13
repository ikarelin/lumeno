create table public.visits (
  id uuid primary key default gen_random_uuid(),

  doctor_user_id uuid not null
    references public.doctor_profiles(user_id)
    on delete cascade,

  patient_id uuid not null
    references public.patients(id)
    on delete restrict,

  clinic_id uuid not null
    references public.clinics(id)
    on delete restrict,

  starts_at timestamptz not null,
  duration_minutes integer not null
    check (duration_minutes > 0),
  ends_at timestamptz not null,
  status text not null default 'scheduled'
    check (status in ('scheduled', 'cancelled', 'completed')),
  note text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.visits is
  'Persisted doctor visits. Cancelled visits remain for history but do not occupy availability.';

create index visits_doctor_starts_at_idx
  on public.visits(doctor_user_id, starts_at);

create index visits_doctor_period_idx
  on public.visits(doctor_user_id, starts_at, ends_at);

create index visits_patient_starts_at_idx
  on public.visits(patient_id, starts_at);

create index visits_clinic_starts_at_idx
  on public.visits(clinic_id, starts_at);

create or replace function public.set_visit_ends_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.ends_at := new.starts_at + (new.duration_minutes * interval '1 minute');
  return new;
end;
$$;

create trigger visits_set_ends_at
  before insert or update of starts_at, duration_minutes on public.visits
  for each row
  execute function public.set_visit_ends_at();

create trigger visits_set_updated_at
  before update on public.visits
  for each row
  execute function public.set_updated_at();

alter table public.visits enable row level security;

create policy "Doctors can read own visits"
on public.visits
for select
to authenticated
using (doctor_user_id = (select auth.uid()));

create policy "Doctors can create own visits"
on public.visits
for insert
to authenticated
with check (
  doctor_user_id = (select auth.uid())
  and exists (
    select 1
    from public.patients
    where patients.id = visits.patient_id
      and patients.doctor_user_id = (select auth.uid())
      and patients.archived_at is null
  )
  and exists (
    select 1
    from public.doctor_clinics
    where doctor_clinics.clinic_id = visits.clinic_id
      and doctor_clinics.doctor_user_id = (select auth.uid())
  )
);

create policy "Doctors can update own visits"
on public.visits
for update
to authenticated
using (doctor_user_id = (select auth.uid()))
with check (
  doctor_user_id = (select auth.uid())
  and exists (
    select 1
    from public.patients
    where patients.id = visits.patient_id
      and patients.doctor_user_id = (select auth.uid())
      and patients.archived_at is null
  )
  and exists (
    select 1
    from public.doctor_clinics
    where doctor_clinics.clinic_id = visits.clinic_id
      and doctor_clinics.doctor_user_id = (select auth.uid())
  )
);

create policy "Doctors can delete own visits"
on public.visits
for delete
to authenticated
using (doctor_user_id = (select auth.uid()));

revoke all on table public.visits from anon;
revoke all on table public.visits from authenticated;
grant select, insert, update, delete on table public.visits to authenticated;
