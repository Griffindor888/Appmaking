-- CSA commercial intake hardening after production advisor review.

create index if not exists idx_csa_commercial_enquiry_events_receipt
on public.csa_commercial_enquiry_events(enquiry_receipt_id);

revoke execute on function public.submit_csa_commercial_enquiry(
  text, text, text, text, text, text, boolean, uuid, text, text
) from authenticated;
