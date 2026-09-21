-- Patient clinical notes are separate from operational visits.note and patients.note.
-- This migration is additive and is intended for the synthetic-data development backend.
create table public.patient_clinical_notes (
  id uuid primary key default gen_random_uuid(),
  doctor_user_id uuid not null
    references public.doctor_profiles(user_id) on delete cascade,
  patient_id uuid not null
    references public.patients(id) on delete restrict,
  body text not null
    check (char_length(btrim(body)) between 1 and 20000),
  created_at timestamptz not null default now()
);

comment on table public.patient_clinical_notes is
  'Patient-scoped clinical entries; independent of operational Visit.note. '
  'Initial MVP entries are append-only and do not link to a Visit.';

create index patient_clinical_notes_owner_patient_created_idx
  on public.patient_clinical_notes (
    doctor_user_id, patient_id, created_at desc, id desc
  );

alter table public.patient_clinical_notes enable row level security;

create policy "Doctors can read own patient clinical notes"
  on public.patient_clinical_notes
  for select to authenticated
  using (
    doctor_user_id = (select auth.uid())
    and exists (
      select 1 from public.patients p
      where p.id = patient_clinical_notes.patient_id
        and p.doctor_user_id = (select auth.uid())
    )
  );

create policy "Doctors can create own active patient clinical notes"
  on public.patient_clinical_notes
  for insert to authenticated
  with check (
    doctor_user_id = (select auth.uid())
    and exists (
      select 1 from public.patients p
      where p.id = patient_clinical_notes.patient_id
        and p.doctor_user_id = (select auth.uid())
        and p.archived_at is null
    )
  );

-- No UPDATE or DELETE grants in this first slice: existing clinical entries
-- cannot be silently overwritten or erased by a client action.
revoke all on table public.patient_clinical_notes from anon;
revoke all on table public.patient_clinical_notes from authenticated;
grant select, insert on table public.patient_clinical_notes to authenticated;
