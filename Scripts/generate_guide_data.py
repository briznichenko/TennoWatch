import argparse
import json
from pathlib import Path

REVISION = '63cf904c903536b9a84c5faa2b851fd690f73d18'


def generate(source, catalog_path, output):
    entries = [item for path in sorted(source.glob('*.json')) for item in json.loads(path.read_text())]
    by_id = {item['uniqueName']: item for item in entries}
    catalog = json.loads(catalog_path.read_text())
    records = {}
    for item in catalog['items']:
        entry = by_id.get(item['uniqueName'])
        if entry is None:
            continue
        components = []
        for component in entry.get('components', []):
            detail = by_id.get(component['uniqueName'], {})
            name = detail.get('name')
            if not name:
                continue
            components.append({
                'name': name,
                'count': component.get('itemCount', 1),
                'locations': sorted({drop['location'] for drop in detail.get('drops', []) if drop.get('location')}),
            })
        records[item['uniqueName']] = {
            'masteryRequirement': entry.get('masteryReq'),
            'blueprintCredits': entry.get('bpCost'),
            'buildCredits': entry.get('buildPrice'),
            'buildSeconds': entry.get('buildTime'),
            'components': components,
            'locations': sorted({drop['location'] for drop in entry.get('drops', []) if drop.get('location')}),
        }
    result = {
        'source': f'https://github.com/WFCD/warframe-items/tree/{REVISION}',
        'snapshotDate': '2026-11-01',
        'items': records,
    }
    output.write_text(json.dumps(result, ensure_ascii=False, indent=2) + '\n')
    print(f'Generated {len(records)} acquisition records')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('source', type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    generate(args.source, root / 'TennoWatch/Resources/masterycatalog.json', root / 'TennoWatch/Resources/guide-acquisition.json')
