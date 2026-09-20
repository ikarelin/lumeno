-- TIMEZONE-01A: persist an explicitly chosen doctor IANA time zone.
-- Existing profiles remain unconfigured; never infer one from a device or region.
-- Do not rewrite existing Visit timestamps or date-only schedule exceptions.
alter table public.doctor_profiles
  add column time_zone_id text;

comment on column public.doctor_profiles.time_zone_id is
  'Explicit doctor-selected IANA timezone, e.g. Europe/Moscow. NULL means not configured.';

alter table public.doctor_profiles
  add constraint doctor_profiles_time_zone_id_nonblank
  check (time_zone_id is null or char_length(btrim(time_zone_id)) > 0);
