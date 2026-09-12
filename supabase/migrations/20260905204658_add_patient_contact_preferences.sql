alter table public.patients
    add column email text not null default '',
add column telegram text not null default '',
add column whatsapp_available boolean not null default false,
add column preferred_contact_channels text[] not null default '{}'::text[];

alter table public.patients
    add constraint patients_preferred_contact_channels_allowed_check
        check (
            preferred_contact_channels
                <@ array['phone', 'email', 'telegram', 'whatsapp']::text[]
    );

alter table public.patients
    add constraint patients_preferred_contact_channels_no_nulls_check
        check (
            array_position(preferred_contact_channels, null) is null
            );

alter table public.patients
    add constraint patients_preferred_email_requires_email_check
        check (
            not ('email' = any(preferred_contact_channels))
                or char_length(trim(email)) > 0
            );

alter table public.patients
    add constraint patients_preferred_telegram_requires_telegram_check
        check (
            not ('telegram' = any(preferred_contact_channels))
                or char_length(trim(telegram)) > 0
            );

alter table public.patients
    add constraint patients_preferred_whatsapp_requires_availability_check
        check (
            not ('whatsapp' = any(preferred_contact_channels))
                or whatsapp_available
            );

comment on column public.patients.email is
  'Optional patient email address.';

comment on column public.patients.telegram is
  'Optional patient Telegram contact or handle.';

comment on column public.patients.whatsapp_available is
  'Whether the patient is reachable through WhatsApp using the main patient phone number.';

comment on column public.patients.preferred_contact_channels is
  'Zero or more patient-preferred contact channels: phone, email, telegram, whatsapp.';