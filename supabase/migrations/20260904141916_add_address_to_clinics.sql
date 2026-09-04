alter table public.clinics
    add column address text
        check (
            address is null
                or char_length(trim(address)) > 0
            );


comment on column public.clinics.address is
  'Human-readable clinic address.';