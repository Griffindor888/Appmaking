# CSA Corporate Website — Release Gate

Status: Founder-approved institutional website build; domain cutover not yet authorised.

## Mandatory before public release

1. Deploy the complete route tree, not the single-file preview bundle.
2. Add a standalone Contact page.
3. Add Privacy Policy and point-of-collection privacy notices.
4. Add Website Terms of Use.
5. Add Cookie / tracking notice and consent controls where non-essential tracking is enabled or required by visitor jurisdiction.
6. Publish legal identity in footer/legal pages: Cyber Security Agency Australia Pty Ltd, ABN 89 659 238 570, ACN 659 238 570, Queensland, Australia; confirm the public business/postal address and canonical email before release.
7. Add Responsible Disclosure / Vulnerability Disclosure Policy and /.well-known/security.txt.
8. Add Accessibility statement and contact route for accessibility issues.
9. Add claims-control review: no unsupported partnership, certification, operating-status, customer, regulatory or performance claims.
10. Add security headers, CSP, HSTS, X-Content-Type-Options, Referrer-Policy, Permissions-Policy and frame-ancestors controls.
11. Protect forms: server-side validation, anti-spam/rate limiting, CSRF controls where applicable, minimal data collection and retention rules.
12. Protect deployment: MFA for GitHub/Vercel/domain registrar, least privilege, branch protection, secret scanning, dependency/security scanning, backups and incident-response ownership.
13. Verify robots.txt, sitemap.xml, llms.txt, canonical metadata and structured data against the same approved corporate claims.
14. Run broken-link, mobile, accessibility, security-header and content-status checks.
15. Only then connect cs-agency.com.au.

## Public/controlled information boundary

Public site: Company, Ecosystem, Technology/Platforms, Governance, Industries, Trust, Research/Insights, Contact/Corporate Engagement, selected abstracts/methodology.

Controlled enterprise library: governance volumes, templates, implementation frameworks, enterprise playbooks, certification material and audit/assessment methodology.
