-- SCHED-01D1
-- Enforce the core scheduling invariant in PostgreSQL:
-- one doctor cannot have overlapping Visits that occupy availability.
--
-- Cancelled/completed Visits are preserved for history but do not block time.
-- The half-open [start, end) range allows adjacent Visits such as
-- 09:00-09:30 and 09:30-10:00.
--
-- Supabase CLI does not implicitly wrap migration files in a transaction.
-- LOCK TABLE requires an explicit transaction block, and we intentionally keep
-- the preflight check + trigger replacement + exclusion constraint atomic.

begin;

create extension if not exists btree_gist with schema extensions;

-- Keep the preflight check and constraint creation on a stable set of rows.
lock table public.visits in share row exclusive mode;

-- Fail with a useful migration error instead of a less obvious exclusion
-- constraint build failure when legacy overlapping scheduled Visits exist.
do $$
begin
  if exists (
    select 1
    from public.visits as left_visit
    join public.visits as right_visit
      on right_visit.doctor_user_id = left_visit.doctor_user_id
     and right_visit.id > left_visit.id
     and right_visit.status = 'scheduled'
     and tstzrange(
       right_visit.starts_at,
       right_visit.ends_at,
       '[)'
     ) && tstzrange(
       left_visit.starts_at,
       left_visit.ends_at,
       '[)'
     )
    where left_visit.status = 'scheduled'
  ) then
    raise exception
      'Cannot enable Visit overlap protection because overlapping scheduled Visits already exist.'
      using hint =
        'Resolve the existing overlap(s), then run the migration again.';
end if;
end;
$$;

-- ends_at is a derived database invariant. Recompute it on every write so a
-- direct API update cannot manually change ends_at and bypass overlap checks.
drop trigger if exists visits_set_ends_at on public.visits;

create trigger visits_set_ends_at
    before insert or update on public.visits
                         for each row
                         execute function public.set_visit_ends_at();

alter table public.visits
    add constraint visits_no_overlapping_scheduled
    exclude using gist (
    doctor_user_id with =,
    tstzrange(starts_at, ends_at, '[)') with &&
  )
  where (status = 'scheduled');

comment on constraint visits_no_overlapping_scheduled on public.visits is
  'Prevents overlapping scheduled Visits for the same doctor. Cancelled and completed Visits do not occupy availability.';

commit;
