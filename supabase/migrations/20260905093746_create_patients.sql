create table public.patients (
                                 id uuid primary key default gen_random_uuid(),

                                 doctor_user_id uuid not null
                                     references public.doctor_profiles(user_id)
                                         on delete cascade,

                                 name text not null
                                     check (char_length(trim(name)) > 0),

                                 phone text not null
                                     check (char_length(trim(phone)) > 0),

                                 note text not null default '',

                                 created_at timestamptz not null default now(),
                                 updated_at timestamptz not null default now(),

                                 archived_at timestamptz
);


comment on table public.patients is
  'Patients owned by individual Lumeno doctors. Normal deletion is soft archive.';


create index patients_doctor_user_id_idx
    on public.patients(doctor_user_id);


create trigger patients_set_updated_at
    before update on public.patients
    for each row
    execute function public.set_updated_at();


alter table public.patients
    enable row level security;


create policy "Doctors can read own patients"
on public.patients
for select
               to authenticated
               using (
               doctor_user_id = (select auth.uid())
               );


create policy "Doctors can create own patients"
on public.patients
for insert
to authenticated
with check (
  doctor_user_id = (select auth.uid())
);


create policy "Doctors can update own patients"
on public.patients
for update
                      to authenticated
                      using (
                      doctor_user_id = (select auth.uid())
                      )
    with check (
                      doctor_user_id = (select auth.uid())
                      );


revoke all
    on table public.patients
    from anon;


revoke all
    on table public.patients
    from authenticated;


grant select, insert, update
    on table public.patients
    to authenticated;