-- PATIENT-NOTES-01B: optional Visit context for append-only patient notes.
-- Requires 20260921120000_create_patient_clinical_notes.sql (already applied).
-- PostgreSQL >= 15: ON DELETE SET NULL can target only visit_id.
-- A note must never be linked to another patient's or doctor's Visit.

alter table public.patient_clinical_notes
  add column visit_id uuid;

-- PostgreSQL foreign keys can only reference unique keys. The redundant
-- composite key lets the database enforce all three identities atomically,
-- including if a Visit is later reassigned to another patient.
alter table public.visits
  add constraint visits_id_patient_doctor_unique
  unique (id, patient_id, doctor_user_id);

alter table public.patient_clinical_notes
  add constraint patient_clinical_notes_visit_same_owner_patient_fk
  foreign key (visit_id, patient_id, doctor_user_id)
  references public.visits (id, patient_id, doctor_user_id)
  on update restrict
  on delete set null (visit_id);

create index patient_clinical_notes_owner_patient_visit_created_idx
  on public.patient_clinical_notes (
    doctor_user_id, patient_id, visit_id, created_at desc, id desc
  );

comment on column public.patient_clinical_notes.visit_id is
  'Optional Visit context. A linked Visit must belong to this note patient and doctor. '
  'Deleting a Visit clears visit_id but preserves the clinical note.';

comment on table public.patient_clinical_notes is
  'Patient-scoped append-only clinical entries, separate from operational Visit.note. '
  'Entries can optionally link to an existing Visit of the same patient and doctor.';
