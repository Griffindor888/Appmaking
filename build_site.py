from pathlib import Path
import json, html, zlib, base64

ROOT=Path('dist')
ROOT.mkdir(exist_ok=True)
DOMAIN='https://cs-agency.com.au'
EMAIL='info@cs-agency.com.au'
ORG_DESC='Australian-founded technology institution with an operating presence in Australia and the United States, developing governed AI, human assurance, intelligent operations and cyber-risk infrastructure for global markets.'
KEYWORDS='Cyber Security Agency Australia, CSA, governed AI, AI governance, autonomous systems, AI workforce, cyber security Australia, cyber security United States, WARDALE OS, Solurius, AUTTO Connect, Cyber Security Insurance Australia, CSiA, digital trust, human assurance, Brisbane, New York, global technology'
NY_STREET='30 Wall Street, 8th Floor'

NAV='''<nav class="nav"><div class="wrap navin"><a class="brand" href="/"><span class="brandmark">CSA</span><span class="brandname">Cyber Security Agency Australia</span></a><div class="navlinks"><a href="/company/">Company</a><a href="/ecosystem/">Ecosystem</a><a href="/technology/">Technology</a><a href="/governance/">Governance</a><a href="/industries/">Industries</a><a href="/trust/">Trust</a><a href="/research/">Research</a></div><div class="navright"><a class="quietlink" href="/contact/">Contact</a><button class="menu">Menu</button></div></div></nav>'''
FOOT='''<footer class="footer"><div class="wrap"><div class="footTop"><div class="footBrand"><div class="brand"><span class="brandmark">CSA</span><span class="brandname">Cyber Security Agency Australia</span></div><p>Australian-founded technology institution developing governed AI, human assurance, intelligent operations and cyber-risk infrastructure.</p><p class="footContact"><a href="mailto:info@cs-agency.com.au">info@cs-agency.com.au</a><br>Brisbane · Australia &nbsp; / &nbsp; New York · United States</p></div><div><h4>Institution</h4><a href="/company/">Company</a><a href="/governance/">Governance</a><a href="/trust/">Trust Centre</a><a href="/contact/">Contact</a></div><div><h4>Ecosystem</h4><a href="/platforms/wardale/">WARDALE</a><a href="/platforms/solurius/">Solurius</a><a href="/platforms/autto-connect/">AUTTO Connect</a><a href="/platforms/csia/">CSiA</a></div><div><h4>Knowledge</h4><a href="/research/">Research & Insights</a><a href="/knowledge/">Public knowledge</a><a href="/library/">Enterprise library</a></div><div><h4>Legal & security</h4><a href="/privacy/">Privacy</a><a href="/terms/">Website Terms</a><a href="/security/">Security & Disclosure</a><a href="/accessibility/">Accessibility</a></div></div><div class="legal"><span>Cyber Security Agency Australia Pty Ltd · ABN 89 659 238 570 · ACN 659 238 570</span><span>© 2026 Cyber Security Agency Australia</span></div></div></footer>'''

PAGES=json.loads(zlib.decompress(base64.b64decode(Path('pages.b64').read_text(encoding='ascii'))).decode('utf-8'))

def metadata(route,title,desc):
    canonical=DOMAIN+route
    robots='noindex,follow' if route=='/library/' else 'index,follow,max-image-preview:large,max-snippet:-1,max-video-preview:-1'
    org={
      '@type':'Corporation','@id':DOMAIN+'/#organization','name':'Cyber Security Agency Australia Pty Ltd','legalName':'Cyber Security Agency Australia Pty Ltd','alternateName':['Cyber Security Agency Australia','CSA'],'url':DOMAIN+'/','email':EMAIL,'telephone':'+61-7-3067-5577','faxNumber':'+1-938-888-7770','description':ORG_DESC,
      'foundingLocation':{'@type':'Country','name':'Australia'},
      'identifier':[{'@type':'PropertyValue','propertyID':'ABN','value':'89 659 238 570'},{'@type':'PropertyValue','propertyID':'ACN','value':'659 238 570'}],
      'location':[{'@type':'Place','name':'Head Office — Australia','address':{'@type':'PostalAddress','addressLocality':'Brisbane','addressRegion':'QLD','addressCountry':'AU'}},{'@type':'Place','name':'North America Office','address':{'@type':'PostalAddress','streetAddress':NY_STREET,'addressLocality':'New York','addressRegion':'NY','postalCode':'10005','addressCountry':'US'}}],
      'contactPoint':[{'@type':'ContactPoint','contactType':'corporate enquiries','email':EMAIL,'telephone':'+61-7-3067-5577','areaServed':'AU','availableLanguage':['en']},{'@type':'ContactPoint','contactType':'North America office','email':EMAIL,'telephone':'+1-770-796-7537','areaServed':{'@type':'AdministrativeArea','name':'North America'},'availableLanguage':['en']}],
      'areaServed':[{'@type':'Country','name':'Australia'},{'@type':'Country','name':'United States'},{'@type':'AdministrativeArea','name':'Global markets'}],
      'knowsAbout':['Governed AI','AI governance','Autonomous systems','AI workforce governance','Cyber security','Human assurance','Digital trust','Intelligent operations','Cyber-risk readiness']
    }
    graph={'@context':'https://schema.org','@graph':[org,{'@type':'WebSite','@id':DOMAIN+'/#website','url':DOMAIN+'/','name':'Cyber Security Agency Australia','publisher':{'@id':DOMAIN+'/#organization'},'inLanguage':'en-AU'},{'@type':'WebPage','@id':canonical+'#webpage','url':canonical,'name':title,'description':desc,'isPartOf':{'@id':DOMAIN+'/#website'},'about':{'@id':DOMAIN+'/#organization'},'inLanguage':'en-AU'}]}
    bits=[
      f'<meta name="robots" content="{robots}">',
      '<meta name="author" content="Cyber Security Agency Australia Pty Ltd">',
      '<meta name="publisher" content="Cyber Security Agency Australia Pty Ltd">',
      '<meta name="application-name" content="CSA Digital Headquarters">',
      '<meta name="theme-color" content="#ffffff">',
      '<meta name="color-scheme" content="light">',
      f'<meta name="keywords" content="{html.escape(KEYWORDS,quote=True)}">',
      '<meta name="coverage" content="Australia; United States; Global">',
      '<meta name="geo.region" content="AU-QLD">',
      '<meta name="geo.placename" content="Brisbane, Queensland, Australia; New York, New York, United States">',
      '<meta property="og:type" content="website">',
      '<meta property="og:site_name" content="Cyber Security Agency Australia">',
      f'<meta property="og:title" content="{html.escape(title,quote=True)}">',
      f'<meta property="og:description" content="{html.escape(desc,quote=True)}">',
      f'<meta property="og:url" content="{canonical}">',
      '<meta property="og:locale" content="en_AU">',
      '<meta property="og:locale:alternate" content="en_US">',
      '<meta name="twitter:card" content="summary">',
      f'<meta name="twitter:title" content="{html.escape(title,quote=True)}">',
      f'<meta name="twitter:description" content="{html.escape(desc,quote=True)}">',
      f'<link rel="canonical" href="{canonical}">',
      f'<link rel="alternate" hreflang="en" href="{canonical}">',
      f'<link rel="alternate" hreflang="x-default" href="{canonical}">',
      '<link rel="icon" href="/favicon.svg" type="image/svg+xml">',
      '<link rel="manifest" href="/site.webmanifest">',
      '<script type="application/ld+json">'+json.dumps(graph,separators=(',',':'),ensure_ascii=False)+'</script>'
    ]
    return ''.join(bits)

def write_page(route,data):
    out=ROOT/('index.html' if route=='/' else route.strip('/')+'/index.html')
    out.parent.mkdir(parents=True,exist_ok=True)
    title=data['title']; desc=data['desc']; body=data['body']
    doc='<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>'+html.escape(title)+'</title><meta name="description" content="'+html.escape(desc,quote=True)+'">'+metadata(route,title,desc)+'<link rel="stylesheet" href="/styles.css"><script defer src="/app.js"></script></head><body>'+NAV+'<main>'+body+'</main>'+FOOT+'</body></html>'
    out.write_text(doc,encoding='utf-8')

for route,data in PAGES.items():
    write_page(route,data)
for name in ['styles.css','app.js']:
    (ROOT/name).write_text(Path(name).read_text(encoding='utf-8'),encoding='utf-8')
(ROOT/'favicon.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" rx="14" fill="#ffffff"/><path d="M14 32c0-10 8-18 18-18h18v8H32c-5.5 0-10 4.5-10 10s4.5 10 10 10h18v8H32c-10 0-18-8-18-18Z" fill="#283740"/><path d="M50 14v8H34l8-8h8Z" fill="#0a88c8"/></svg>',encoding='utf-8')
(ROOT/'site.webmanifest').write_text(json.dumps({'name':'Cyber Security Agency Australia','short_name':'CSA','start_url':'/','display':'standalone','background_color':'#ffffff','theme_color':'#ffffff','lang':'en-AU','description':ORG_DESC},indent=2),encoding='utf-8')
(ROOT/'robots.txt').write_text('User-agent: *\nAllow: /\nDisallow: /library/\nSitemap: https://cs-agency.com.au/sitemap.xml\n',encoding='utf-8')
routes=[r for r in PAGES if r!='/library/']
priority={'/':'1.0','/company/':'0.9','/ecosystem/':'0.9','/technology/':'0.9','/governance/':'0.9','/industries/':'0.8','/trust/':'0.9','/research/':'0.8','/knowledge/':'0.7','/engagement/':'0.8','/contact/':'0.8'}
xml=['<?xml version="1.0" encoding="UTF-8"?>','<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
for r in sorted(routes,key=lambda x:(0 if x=='/' else 1,x)):
    xml += ['  <url>',f'    <loc>{DOMAIN+r}</loc>','    <lastmod>2026-08-30</lastmod>',f'    <changefreq>{"weekly" if r in ["/","/research/","/trust/"] else "monthly"}</changefreq>',f'    <priority>{priority.get(r,"0.6")}</priority>','  </url>']
xml.append('</urlset>')
(ROOT/'sitemap.xml').write_text('\n'.join(xml)+'\n',encoding='utf-8')
(ROOT/'llms.txt').write_text(f'''# Cyber Security Agency Australia — CSA

Canonical site: {DOMAIN}/
Legal entity: Cyber Security Agency Australia Pty Ltd
ABN: 89 659 238 570
ACN: 659 238 570
Contact: {EMAIL}
Head Office: Brisbane, Queensland, Australia (street address not published)
North America Office: 30 Wall Street, 8th Floor, New York, NY 10005, United States
Operating presence: Australia and United States
Market orientation: Global

## Institutional scope
CSA is an Australian-founded technology institution developing connected systems for governed AI, human assurance, intelligent operations and cyber-risk readiness.

## Ecosystem
- WARDALE OS — governed work, identity, authority, execution and evidence infrastructure.
- Solurius — human assurance and workforce intelligence.
- AUTTO Connect — intelligent automotive operating venture.
- Cyber Security Insurance Australia (CSiA) — cyber-risk readiness and partner-dependent insurance pathway.
- CSA Governance — institutional governance and implementation intellectual property.

## Intellectual-property boundary
The public website provides selected abstracts, research, standards summaries and methodology. Proprietary governance volumes, templates, implementation frameworks, enterprise playbooks, certification instruments and audit methodology are controlled materials and are not publicly reproduced.
''',encoding='utf-8')
sec=ROOT/'.well-known'; sec.mkdir(exist_ok=True)
(sec/'security.txt').write_text(f'Contact: mailto:{EMAIL}\nPolicy: {DOMAIN}/security/\nCanonical: {DOMAIN}/.well-known/security.txt\nPreferred-Languages: en\nExpires: 2027-08-30T00:00:00Z\n',encoding='utf-8')
(ROOT/'404.html').write_text('<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Page not found — CSA</title><meta name="description" content="The requested page is not part of the current Cyber Security Agency Australia public website."><meta name="robots" content="noindex"><link rel="stylesheet" href="/styles.css"></head><body><main><section class="pageHero"><div class="wrap"><div class="eyebrow">CSA Digital Headquarters</div><h1>Page not found.</h1><p>The requested route is not part of the current public institutional surface.</p><p><a class="link" href="/">Return to Cyber Security Agency Australia →</a></p></div></section></main></body></html>',encoding='utf-8')
