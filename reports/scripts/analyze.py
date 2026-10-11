"""Analyse Case fields for near-duplicates and metadata usage. Writes analysis.json."""
import json, os, re, sys, difflib
import xml.etree.ElementTree as ET
from collections import defaultdict

ROOT = sys.argv[1]  # force-app/main/default
OUT = sys.argv[2]
NS = '{http://soap.sforce.com/2006/04/metadata}'
FIELD_DIR = os.path.join(ROOT, 'objects/Case/fields')

# ---------------------------------------------------------------- fields
def txt(el, tag):
    e = el.find(NS + tag)
    return e.text.strip() if e is not None and e.text else ''

fields = {}
for fn in sorted(os.listdir(FIELD_DIR)):
    api = fn.replace('.field-meta.xml', '')
    t = ET.parse(os.path.join(FIELD_DIR, fn)).getroot()
    ftype = txt(t, 'type')
    formula = txt(t, 'formula')
    picks = [txt(v, 'fullName') for v in t.iter(NS + 'value') if txt(v, 'fullName')]
    gvs = txt(t.find(NS + 'valueSet'), 'valueSetName') if t.find(NS + 'valueSet') is not None else ''
    fields[api] = dict(
        api=api, label=txt(t, 'label') or api, type=(ftype or ('Standard' if '__c' not in api else '')),
        is_custom=api.endswith('__c'), formula=formula, is_formula=bool(formula),
        length=txt(t, 'length') or txt(t, 'precision'), description=txt(t, 'description'),
        help=txt(t, 'inlineHelpText'), required=txt(t, 'required') == 'true',
        external_id=txt(t, 'externalId') == 'true', unique=txt(t, 'unique') == 'true',
        track_history=txt(t, 'trackHistory') == 'true', reference_to=txt(t, 'referenceTo'),
        picklist_values=picks[:40], global_value_set=gvs,
    )
custom = {a for a, f in fields.items() if f['is_custom']}

# field names that also exist on other objects (ambiguous tokens)
other_obj_fields = defaultdict(set)
for obj in os.listdir(os.path.join(ROOT, 'objects')):
    if obj == 'Case':
        continue
    d = os.path.join(ROOT, 'objects', obj, 'fields')
    if os.path.isdir(d):
        for fn in os.listdir(d):
            other_obj_fields[fn.replace('.field-meta.xml', '')].add(obj)

# ---------------------------------------------------------------- references
FUNCTIONAL = ['Apex Class', 'Apex Trigger', 'Flow', 'LWC', 'Aura', 'Visualforce', 'Email Template',
              'Validation Rule', 'Case Formula/Field', 'Cross-Object Formula/Field', 'Workflow',
              'Approval Process', 'Assignment/Escalation/Auto-Response Rule', 'Quick Action',
              'Report', 'Dashboard', 'List View', 'Duplicate/Matching Rule', 'Other Metadata']
UI = ['Page Layout', 'Lightning Page', 'Compact Layout', 'Path Assistant']
CONFIG = ['Record Type', 'Report Type', 'Permission Set', 'Profile', 'Translation', 'Field Set']
ALL_CATS = FUNCTIONAL + UI + CONFIG

def category(rel):
    p = rel.split('/')
    top = p[0]
    if top == 'classes': return 'Apex Class'
    if top == 'triggers': return 'Apex Trigger'
    if top in ('flows', 'flowDefinitions'): return 'Flow'
    if top == 'lwc': return 'LWC'
    if top == 'aura': return 'Aura'
    if top in ('pages', 'components'): return 'Visualforce'
    if top == 'email': return 'Email Template'
    if top == 'workflows': return 'Workflow'
    if top == 'approvalProcesses': return 'Approval Process'
    if top in ('assignmentRules', 'escalationRules', 'autoResponseRules'): return 'Assignment/Escalation/Auto-Response Rule'
    if top == 'quickActions': return 'Quick Action'
    if top == 'reports': return 'Report'
    if top == 'dashboards': return 'Dashboard'
    if top in ('duplicateRules', 'matchingRules'): return 'Duplicate/Matching Rule'
    if top == 'layouts': return 'Page Layout'
    if top == 'flexipages': return 'Lightning Page'
    if top == 'pathAssistants': return 'Path Assistant'
    if top == 'reportTypes': return 'Report Type'
    if top == 'permissionsets': return 'Permission Set'
    if top == 'profiles': return 'Profile'
    if top == 'objectTranslations': return 'Translation'
    if top == 'objects':
        obj, sub = p[1], p[2] if len(p) > 2 else ''
        if obj == 'Case':
            return {'validationRules': 'Validation Rule', 'fields': 'Case Formula/Field', 'listViews': 'List View',
                    'compactLayouts': 'Compact Layout', 'recordTypes': 'Record Type', 'fieldSets': 'Field Set',
                    'webLinks': 'Other Metadata', 'businessProcesses': 'Other Metadata'}.get(sub, 'Other Metadata')
        return 'Cross-Object Formula/Field'
    return 'Other Metadata'

def component(rel):
    p = rel.split('/')
    if p[0] in ('lwc', 'aura') and len(p) > 1: return p[1]
    if p[0] == 'objects': return '.'.join([p[1]] + [re.sub(r'\..*', '', p[-1])])
    if p[0] in ('email', 'reports', 'dashboards') and len(p) > 2: return p[1] + '/' + re.sub(r'\.[^/]*$', '', p[-1].replace('-meta.xml', ''))
    return re.sub(r'\.[A-Za-z]+(-meta\.xml)?$', '', p[-1]).replace('.cls', '').replace('.trigger', '')

TOKEN = re.compile(r'([A-Za-z0-9_$.]*?)\b([A-Za-z][A-Za-z0-9_]*__c)\b')
CASE_CTX = re.compile(r'\bCase\b|Case__[cr]|\bCases\b|CaseId|Case\.')
CASE_SPECIFIC_PREFIX = ('layouts/Case-', 'objects/Case/', 'objectTranslations/Case-')
SKIP_EXT = ('.png', '.jpg', '.jpeg', '.gif', '.svg', '.zip', '.pdf', '.woff', '.woff2', '.ttf', '.ico', '.resource', '.eot')

refs = defaultdict(lambda: defaultdict(dict))  # api -> cat -> component -> {hits, files, confidence}
for dp, dn, fns in os.walk(ROOT):
    for fn in fns:
        if fn.lower().endswith(SKIP_EXT): continue
        path = os.path.join(dp, fn)
        rel = os.path.relpath(path, ROOT)
        if rel.startswith('staticresources/'): continue
        try:
            s = open(path, encoding='utf-8', errors='ignore').read()
        except Exception:
            continue
        if '__c' not in s: continue
        cat = category(rel)
        case_specific = rel.startswith(CASE_SPECIFIC_PREFIX) or (cat == 'Lightning Page' and '<sobjectType>Case</sobjectType>' in s)
        has_case = bool(CASE_CTX.search(s))
        hits = defaultdict(int)
        qualified = set()
        for m in TOKEN.finditer(s):
            api = m.group(2)
            if api not in custom: continue
            pre = m.group(1)
            if cat in ('Permission Set', 'Profile', 'Report Type', 'Translation'):
                # these name the object explicitly
                if cat in ('Permission Set', 'Profile') and not pre.endswith('Case.'): continue
            hits[api] += 1
            if re.search(r'(^|[.$])(Case|CASE|Cases|Case__r|Parent)[.$]$', pre) or pre.endswith('Case__r.'):
                qualified.add(api)
        if rel == f'objects/Case/fields/{fn}':
            hits.pop(fn.replace('.field-meta.xml', ''), None)  # self
        if cat == 'Report Type' and '<baseObject>Case</baseObject>' not in s and '<table>Case' not in s and 'Case' not in s:
            continue
        for api, n in hits.items():
            shared = bool(other_obj_fields.get(api))
            if case_specific or not shared or api in qualified:
                conf = 'Confirmed'
            elif has_case:
                conf = 'Probable (name also on: %s)' % ', '.join(sorted(other_obj_fields[api])[:4])
            else:
                continue  # belongs to another object
            if cat in ('Permission Set', 'Profile'): conf = 'Confirmed'
            comp = component(rel)
            d = refs[api][cat].setdefault(comp, {'hits': 0, 'files': set(), 'confidence': conf})
            d['hits'] += n
            d['files'].add(rel)
            if conf == 'Confirmed': d['confidence'] = conf

# ---------------------------------------------------------------- similarity
STOP = {'the', 'of', 'a', 'an', 'and', 'c'}
def norm_label(l):
    l = re.sub(r'([a-z])([A-Z])', r'\1 \2', l)
    l = l.lower().replace('&', ' and ')
    l = re.sub(r'[^a-z0-9 ]+', ' ', l)
    return ' '.join(w for w in l.split() if w not in STOP)
def norm_api(a):
    a = re.sub(r'__c$', '', a)
    return re.sub(r'[^a-z0-9]', '', a.lower())
def strip_ver(s):
    return re.sub(r'(\s*(v|ver|version|new|old|copy|bkp|backup|temp|tmp|test))?\s*\d*$', '', s).strip()

def sim(a, b):
    return difflib.SequenceMatcher(None, a, b).ratio()

def token_sort(s):
    return ' '.join(sorted(s.split()))

names = sorted(fields)
info = {a: dict(nl=norm_label(fields[a]['label']), na=norm_api(a)) for a in names}
for a in names:
    info[a]['nlv'] = strip_ver(info[a]['nl'])
    info[a]['nav'] = strip_ver(info[a]['na'])
    info[a]['nlt'] = token_sort(info[a]['nl'])

parent = {a: a for a in names}
def find(x):
    while parent[x] != x:
        parent[x] = parent[parent[x]]; x = parent[x]
    return x
edges = {}
for i, a in enumerate(names):
    A = info[a]
    for b in names[i + 1:]:
        if not (fields[a]['is_custom'] or fields[b]['is_custom']): continue
        B = info[b]
        reason, score = None, 0.0
        if A['nl'] == B['nl']:
            reason, score = 'Identical label', 1.0
        elif A['na'] == B['na']:
            reason, score = 'Identical API name (ignoring case/underscores)', 1.0
        elif A['nlt'] == B['nlt'] and len(A['nl']) > 3:
            reason, score = 'Same label words, different order', 0.98
        elif A['nlv'] and A['nlv'] == B['nlv'] and len(A['nlv']) >= 4:
            reason, score = 'Label differs only by number/version suffix', 0.97
        elif A['nav'] and A['nav'] == B['nav'] and len(A['nav']) >= 5:
            reason, score = 'API name differs only by number/version suffix', 0.96
        else:
            if min(len(A['nl']), len(B['nl'])) >= 8:
                q = difflib.SequenceMatcher(None, A['nl'], B['nl'])
                if q.real_quick_ratio() >= 0.9 and q.quick_ratio() >= 0.9:
                    r = q.ratio()
                    if r >= 0.9:
                        reason, score = 'Very similar label (fuzzy %.0f%%)' % (r * 100), r
            if not reason and min(len(A['na']), len(B['na'])) >= 10:
                q = difflib.SequenceMatcher(None, A['na'], B['na'])
                if q.real_quick_ratio() >= 0.92 and q.quick_ratio() >= 0.92:
                    r = q.ratio()
                    if r >= 0.92:
                        reason, score = 'Very similar API name (fuzzy %.0f%%)' % (r * 100), r
        if reason:
            edges[(a, b)] = (reason, score)
            parent[find(a)] = find(b)

groups = defaultdict(list)
for a in names:
    groups[find(a)].append(a)
groups = [sorted(g) for g in groups.values() if len(g) > 1 and any(fields[x]['is_custom'] for x in g)]

def serial_refs(api):
    out = {}
    for cat, comps in refs.get(api, {}).items():
        out[cat] = {c: {'hits': v['hits'], 'files': sorted(v['files']), 'confidence': v['confidence']} for c, v in comps.items()}
    return out

json.dump(dict(
    fields=fields, refs={a: serial_refs(a) for a in fields},
    edges=[[a, b, r, s] for (a, b), (r, s) in edges.items()], groups=groups,
    cats=dict(FUNCTIONAL=FUNCTIONAL, UI=UI, CONFIG=CONFIG),
    other_obj_fields={k: sorted(v) for k, v in other_obj_fields.items() if k in custom},
), open(OUT, 'w'), indent=1)
print('fields', len(fields), 'groups', len(groups), 'grouped fields', sum(len(g) for g in groups))
for g in sorted(groups, key=len, reverse=True)[:15]:
    print(len(g), [fields[x]['label'] for x in g][:12])
