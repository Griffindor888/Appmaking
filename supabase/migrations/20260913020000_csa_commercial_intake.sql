-- CSA commercial front door — durable ecosystem enquiry receipts.
-- Additive only. Public clients may submit through the validated RPC but cannot
-- read, insert, update or delete enquiry or event rows directly.

create extension if not exists pgcrypto;

create table if not exists public.csa_commercial_enquiries (
  receipt_id uuid primary key default gen_random_uuid(),
  correlation_id uuid not null unique,
  pathway text not null check (
    pathway in ('wardale', 'solurius', 'autto', 'csia', 'corporate')
  ),
  organisation text not null,
  contact_name text not null,
  email text not null,
  timeframe text not null check (
    timeframe in ('immediate', '30_days', '90_days', 'exploring')
  ),
  requirement text not null,
  source_path text not null default '/start/',
  status text not null default 'new' check (
    status in ('new', 'acknowledged', 'qualified', 'routed', 'closed')
  ),
  consent_recorded_at timestamptz not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_csa_commercial_enquiries_status_created
on public.csa_commercial_enquiries(status, created_at);

create index if not exists idx_csa_commercial_enquiries_pathway_created
on public.csa_commercial_enquiries(pathway, created_at desc);

create index if not exists idx_csa_commercial_enquiries_email_recent
on public.csa_commercial_enquiries(lower(email), pathway, created_at desc);

create table if not exists public.csa_commercial_enquiry_events (
  id uuid primary key default gen_random_uuid(),
  enquiry_receipt_id uuid not null references public.csa_commercial_enquiries(receipt_id) on delete restrict,
  event_type text not null check (event_type in ('enquiry.received')),
  correlation_id uuid not null unique,
  payload jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

alter table public.csa_commercial_enquiries enable row level security;
alter table public.csa_commercial_enquiry_events enable row level security;

revoke all on table public.csa_commercial_enquiries
from public, anon, authenticated;
revoke all on table public.csa_commercial_enquiry_events
from public, anon, authenticated;
grant all on table public.csa_commercial_enquiries to service_role;
grant all on table public.csa_commercial_enquiry_events to service_role;

create or replace function public.prevent_csa_commercial_event_mutation()
returns trigger
language plpgsql
set search_path = pg_catalog, public
as $$
begin
  raise exception 'CSA_COMMERCIAL_EVENT_IMMUTABLE' using errcode = '55000';
end;
$$;

create trigger csa_commercial_events_are_immutable
before update or delete on public.csa_commercial_enquiry_events
for each row execute function public.prevent_csa_commercial_event_mutation();

create or replace function public.submit_csa_commercial_enquiry(
  p_pathway text,
  p_organisation text,
  p_contact_name text,
  p_email text,
  p_timeframe text,
  p_requirement text,
  p_consent boolean,
  p_correlation_id uuid,
  p_source_path text default '/start/',
  p_website text default null
)
returns table(
  receipt_id uuid,
  pathway text,
  status text,
  correlation_id uuid
)
language plpgsql
security definer
set search_path = pg_catalog, public
as $$
declare
  v_pathway text := lower(trim(p_pathway));
  v_email text := lower(trim(p_email));
  v_timeframe text := lower(trim(p_timeframe));
  v_existing public.csa_commercial_enquiries%rowtype;
  v_enquiry public.csa_commercial_enquiries%rowtype;
begin
  if p_correlation_id is null then
    raise exception 'CSA_ENQUIRY_CORRELATION_REQUIRED' using errcode = '22023';
  end if;

  select e.* into v_existing
  from public.csa_commercial_enquiries e
  where e.correlation_id = p_correlation_id
  limit 1;

  if v_existing.receipt_id is not null then
    return query
    select v_existing.receipt_id, v_existing.pathway,
           v_existing.status, v_existing.correlation_id;
    return;
  end if;

  if p_website is not null and trim(p_website) <> '' then
    raise exception 'CSA_ENQUIRY_REJECTED' using errcode = '22023';
  end if;

  if p_consent is not true then
    raise exception 'CSA_ENQUIRY_CONSENT_REQUIRED' using errcode = '22023';
  end if;

  if v_pathway not in ('wardale', 'solurius', 'autto', 'csia', 'corporate') then
    raise exception 'CSA_ENQUIRY_PATHWAY_INVALID' using errcode = '22023';
  end if;

  if p_organisation is null or char_length(trim(p_organisation)) not between 2 and 200 then
    raise exception 'CSA_ENQUIRY_ORGANISATION_INVALID' using errcode = '22023';
  end if;

  if p_contact_name is null or char_length(trim(p_contact_name)) not between 2 and 150 then
    raise exception 'CSA_ENQUIRY_CONTACT_INVALID' using errcode = '22023';
  end if;

  if v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
     or char_length(v_email) > 254 then
    raise exception 'CSA_ENQUIRY_EMAIL_INVALID' using errcode = '22023';
  end if;

  if v_timeframe not in ('immediate', '30_days', '90_days', 'exploring') then
    raise exception 'CSA_ENQUIRY_TIMEFRAME_INVALID' using errcode = '22023';
  end if;

  if p_requirement is null or char_length(trim(p_requirement)) not between 10 and 4000 then
    raise exception 'CSA_ENQUIRY_REQUIREMENT_INVALID' using errcode = '22023';
  end if;

  if p_source_path is null or char_length(trim(p_source_path)) not between 1 and 250 then
    raise exception 'CSA_ENQUIRY_SOURCE_INVALID' using errcode = '22023';
  end if;

  if exists (
    select 1
    from public.csa_commercial_enquiries e
    where lower(e.email) = v_email
      and e.pathway = v_pathway
      and e.created_at > now() - interval '60 seconds'
  ) then
    raise exception 'CSA_ENQUIRY_RATE_LIMITED' using errcode = '54000';
  end if;

  insert into public.csa_commercial_enquiries (
    correlation_id,
    pathway,
    organisation,
    contact_name,
    email,
    timeframe,
    requirement,
    source_path,
    consent_recorded_at
  ) values (
    p_correlation_id,
    v_pathway,
    trim(p_organisation),
    trim(p_contact_name),
    v_email,
    v_timeframe,
    trim(p_requirement),
    trim(p_source_path),
    now()
  )
  returning * into v_enquiry;

  insert into public.csa_commercial_enquiry_events (
    enquiry_receipt_id,
    event_type,
    correlation_id,
    payload
  ) values (
    v_enquiry.receipt_id,
    'enquiry.received',
    v_enquiry.correlation_id,
    jsonb_build_object(
      'pathway', v_enquiry.pathway,
      'source_path', v_enquiry.source_path,
      'status', v_enquiry.status,
      'consent_recorded', true,
      'csia_boundary',
      case
        when v_enquiry.pathway = 'csia'
        then 'Readiness and evidence support the insurance pathway; regulated advice, broking, underwriting and placement remain with appropriately authorised providers.'
        else null
      end
    )
  );

  return query
  select v_enquiry.receipt_id, v_enquiry.pathway,
         v_enquiry.status, v_enquiry.correlation_id;
end;
$$;

revoke all on function public.submit_csa_commercial_enquiry(
  text, text, text, text, text, text, boolean, uuid, text, text
) from public;
grant execute on function public.submit_csa_commercial_enquiry(
  text, text, text, text, text, text, boolean, uuid, text, text
) to anon, authenticated, service_role;
