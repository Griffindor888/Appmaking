#!/usr/bin/env bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"

correlation='11111111-1111-4111-8111-111111111111'
second_correlation='22222222-2222-4222-8222-222222222222'

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
SQL

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 \
  -f supabase/migrations/20260913020000_csa_commercial_intake.sql

if psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 -c \
  "set role anon; insert into public.csa_commercial_enquiries(correlation_id,pathway,organisation,contact_name,email,timeframe,requirement,source_path,consent_recorded_at) values (gen_random_uuid(),'wardale','Bypass Org','Bypass Person','bypass@example.com','immediate','Attempted direct write','/start/',now())"; then
  echo "Anonymous client inserted a CSA enquiry directly" >&2
  exit 1
fi

if psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 -c \
  "set role anon; select * from public.csa_commercial_enquiries"; then
  echo "Anonymous client read protected CSA enquiries" >&2
  exit 1
fi

if psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 -c \
  "set role anon; select * from public.submit_csa_commercial_enquiry('unknown','Example Organisation','Founder','founder@example.com','immediate','A valid length requirement.',true,gen_random_uuid(),'/start/',null)"; then
  echo "Unknown CSA pathway was unexpectedly accepted" >&2
  exit 1
fi

if psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 -c \
  "set role anon; select * from public.submit_csa_commercial_enquiry('csia','Example Organisation','Founder','founder@example.com','immediate','A valid length requirement.',false,gen_random_uuid(),'/start/',null)"; then
  echo "CSA enquiry without privacy consent was unexpectedly accepted" >&2
  exit 1
fi

if psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 -c \
  "set role anon; select * from public.submit_csa_commercial_enquiry('csia','Example Organisation','Founder','founder@example.com','immediate','A valid length requirement.',true,gen_random_uuid(),'/start/','spam.example')"; then
  echo "Honeypot submission was unexpectedly accepted" >&2
  exit 1
fi

receipt="$(psql "$DATABASE_URL" -X -qAt -F '|' -v ON_ERROR_STOP=1 -c \
  "set role anon; select receipt_id,pathway,status,correlation_id from public.submit_csa_commercial_enquiry('csia','Example Organisation','Founder','Founder@Example.com','immediate','Cyber security insurance renewal pathway discussion.',true,'$correlation','/start/',null)")"
IFS='|' read -r receipt_id pathway status returned_correlation <<< "$receipt"

[[ "$receipt_id" =~ ^[0-9a-f-]{36}$ ]]
test "$pathway" = "csia"
test "$status" = "new"
test "$returned_correlation" = "$correlation"

repeat="$(psql "$DATABASE_URL" -X -qAt -F '|' -v ON_ERROR_STOP=1 -c \
  "set role anon; select receipt_id,correlation_id from public.submit_csa_commercial_enquiry('csia','Changed Organisation','Changed Name','different@example.com','exploring','Different values must not create another row.',true,'$correlation','/other/',null)")"
test "$repeat" = "$receipt_id|$correlation"

test "$(psql "$DATABASE_URL" -X -qAt -c "select count(*) from public.csa_commercial_enquiries where receipt_id = '$receipt_id' and email = 'founder@example.com' and pathway = 'csia' and consent_recorded_at is not null")" = "1"
test "$(psql "$DATABASE_URL" -X -qAt -c "select count(*) from public.csa_commercial_enquiry_events where enquiry_receipt_id = '$receipt_id' and event_type = 'enquiry.received' and correlation_id = '$correlation' and payload->>'consent_recorded' = 'true' and payload->>'csia_boundary' like 'Readiness and evidence support%'")" = "1"

if psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 -c \
  "set role anon; select * from public.submit_csa_commercial_enquiry('csia','Example Organisation','Founder','founder@example.com','immediate','Second rapid submission should be rejected.',true,'$second_correlation','/start/',null)"; then
  echo "Rapid duplicate CSA enquiry bypassed rate limiting" >&2
  exit 1
fi

if psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 -c \
  "set role authenticated; update public.csa_commercial_enquiries set status = 'qualified' where receipt_id = '$receipt_id'"; then
  echo "Authenticated client changed commercial state directly" >&2
  exit 1
fi

if psql "$DATABASE_URL" -X -q -v ON_ERROR_STOP=1 -c \
  "update public.csa_commercial_enquiry_events set payload = '{}'::jsonb where correlation_id = '$correlation'"; then
  echo "Immutable commercial event was unexpectedly altered" >&2
  exit 1
fi

echo "CSA commercial intake passed: validation, consent, anti-spam controls, durable/idempotent receipt, protected storage and CSiA boundary."
