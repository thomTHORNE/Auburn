"""Turns a Notion export of Training '26 into assets/history.json, which the prototype imports on first launch.

Run from Lab/gym-week, with the export unzipped somewhere outside the repository:

    python3 tool/convert_notion.py <export folder>

The mapping is Research/Notion Import's. assets/history.json is personal data and is not committed.
"""
import csv, glob, json, os, re, sys
from datetime import datetime

src = sys.argv[1]
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'history.json')


def rows(pattern):
    path = glob.glob(os.path.join(src, pattern))[0]
    with open(path, encoding='utf-8-sig') as f:
        return list(csv.DictReader(f))


def name_of(relation):
    return re.sub(r' \((?:\.\./|https?:|[^()]*\.md).*$', '', relation).strip()


CARDIO = {'Running', 'Skiing', 'Cycling'}


def load_kind(name):
    suffix = name.rsplit(':', 1)[1].strip() if ':' in name else ''
    if suffix == 'bar':
        return 'plates'
    if suffix in ('pin-machine', 'machine', 'cable'):
        return 'stack'
    if suffix in ('db', 'preacher~db', 'db~bar'):  # db~bar is asked at import; the prototype starts it as dumbbells
        return 'dumbbells'
    return 'bodyweight'


def notes(name):
    found = {'OBSERVATIONS': '', 'SETTINGS': '', 'FORM': ''}
    for path in glob.glob(os.path.join(src, 'Training ‘26', 'db Training’26 Exercises', '*.md')):
        text = open(path, encoding='utf-8').read()
        if not text.startswith('# ' + name + '\n'):
            continue
        for block in re.findall(r'<aside>(.*?)</aside>', text, re.S):
            for key in found:
                m = re.search(r'\*\*' + key + r'\*\*(?:</u>)?(.*)', block, re.S)
                if m:
                    found[key] = re.sub(r'\n{3,}', '\n\n', m.group(1)).strip()
    return found


exercises = {}
for e in rows('Training ‘26/db Training’26 Exercises*_all.csv'):
    name = e['Name'].strip()
    if name in CARDIO:
        continue
    kind = load_kind(name)
    n = notes(name)
    exercises[name] = {
        'name': name, 'loadKind': kind,
        'barKg': 20.0 if kind == 'plates' else None,
        'stepKg': 2.5 if kind in ('stack', 'dumbbells') else None,
        'observations': n['OBSERVATIONS'], 'settings': n['SETTINGS'], 'form': n['FORM'],
    }

workouts = {}
for w in rows('db Training’26 Workouts*_all.csv'):
    name = w['Name'].strip()
    if 'mobility' in name.lower():
        continue
    start = datetime.strptime(re.sub(r' \(GMT.*\)$', '', w['date']), '%d/%m/%Y %I:%M %p')
    workouts[name] = {'gym': 'Iva Gyma' if 'Iva Gyma' in name else 'Gyms4You', 'startedAt': start.isoformat(), 'commits': {}}

skipped = 0
for s in rows('Training ‘26/db Training’26 Sets*_all.csv'):
    w = workouts.get(name_of(s['Workout']))
    ex = exercises.get(name_of(s['Exercise']))
    if w is None or ex is None:
        skipped += 1
        continue
    raw = s['Kg-Km'].strip().replace(',', '.')
    m = re.match(r'\d+(?:\.\d+)?', raw)
    if m:
        load = float(m.group(0))
    elif ex['loadKind'] == 'bodyweight':
        load = 0.0
    elif ex['loadKind'] == 'plates':
        load = ex['barKg']
    else:
        skipped += 1
        continue
    nu = re.search(r'Nu(\d+)', s['Display for workout'])
    reps = int(float(s['Rps-Min'])) if s['Rps-Min'].strip() else None
    logged = datetime.strptime(s['Created'], '%B %d, %Y %I:%M %p')
    commit = w['commits'].setdefault(ex['name'], {'exercise': ex['name'], 'position': int(nu.group(1)) if nu else 99, 'sets': []})
    commit['sets'].append({
        'loggedAt': logged.isoformat(), 'loadKg': load,
        'grade': s['Grade'].strip().lower() or None, 'test': reps is not None, 'reps': reps,
    })

result = []
for w in workouts.values():
    commits = sorted(w['commits'].values(), key=lambda c: (c['position'], c['sets'][0]['loggedAt']))
    if not commits:
        continue
    for i, c in enumerate(commits):
        c['position'] = i + 1
        c['sets'].sort(key=lambda x: x['loggedAt'])
    last = max(x['loggedAt'] for c in commits for x in c['sets'])
    result.append({'gym': w['gym'], 'startedAt': min(w['startedAt'], min(x['loggedAt'] for c in commits for x in c['sets'])), 'endedAt': last, 'commits': commits})
result.sort(key=lambda w: w['startedAt'])

os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, 'w', encoding='utf-8') as f:
    json.dump({'gyms': ['Gyms4You', 'Iva Gyma'], 'exercises': list(exercises.values()), 'workouts': result}, f, ensure_ascii=False)
print(f"{len(exercises)} exercises, {len(result)} workouts, {sum(len(c['sets']) for w in result for c in w['commits'])} sets; {skipped} sets skipped")
