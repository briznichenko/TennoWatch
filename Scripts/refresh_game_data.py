import argparse
import datetime
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import urllib.request


ROOT = Path(__file__).resolve().parents[1]
RESOURCES = ROOT / "TennoWatch/Resources"
PRIME_SOURCE = "https://raw.githubusercontent.com/WFCD/warframe-items/master/data/json/Warframes.json"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def valid_date(value):
    require(isinstance(value, str) and value.endswith("Z"), "Expected a UTC date")
    datetime.datetime.fromisoformat(value.replace("Z", "+00:00"))


def positive_integer(value):
    return type(value) is int and value > 0


def validate_catalog(catalog):
    require(type(catalog["schemaVersion"]) in (int, float), "Invalid catalog schema version")
    require(isinstance(catalog["gameVersion"], str) and catalog["gameVersion"], "Missing game version")
    valid_date(catalog["generatedAt"])
    source = (ROOT / "TennoWatch/Models/CatalogItem.swift").read_text()
    category_source = source.split("enum Category:", 1)[1].split("var displayName:", 1)[0]
    categories = set(re.findall(r'case \w+ = "([^"]+)"', category_source))
    require(categories, "Could not read Swift catalog categories")
    items = catalog["items"]
    require(isinstance(items, list) and items, "Catalog contains no items")
    names = set()
    for item in items:
        for field in ("uniqueName", "name"):
            require(isinstance(item[field], str) and item[field], f"Missing {field}")
        require(item["uniqueName"] not in names, "Duplicate catalog identifier")
        names.add(item["uniqueName"])
        require(item["category"] in categories, f"Unknown category: {item['category']}")
        for field in ("maxRank", "pointsPerRank", "xpPerRankSq"):
            require(positive_integer(item[field]), f"Invalid {field}")
        for field in ("obtainable", "requiresGilding"):
            require(type(item[field]) is bool, f"Invalid {field}")
        require(item.get("icon") is None or isinstance(item["icon"], str), "Invalid icon")
    sources = catalog["nonItemSources"]
    require(isinstance(sources, dict) and sources, "Missing non-item mastery sources")
    non_item_mastery = 0
    for group in sources.values():
        require(isinstance(group, list), "Invalid non-item source group")
        for item in group:
            require(isinstance(item["uniqueName"], str) and item["uniqueName"], "Missing source identifier")
            require(isinstance(item["name"], str) and item["name"], "Missing source name")
            require(type(item["mastery"]) is int and item["mastery"] >= 0, "Invalid source mastery")
            non_item_mastery += item["mastery"]
    total = sum(item["maxRank"] * item["pointsPerRank"] for item in items)
    obtainable = sum(item["maxRank"] * item["pointsPerRank"] for item in items if item["obtainable"])
    require(catalog["totalMasteryMax"] == total + non_item_mastery, "Incorrect total mastery")
    require(catalog["obtainableMasteryMax"] == obtainable + non_item_mastery, "Incorrect obtainable mastery")


def validate_primes(snapshot):
    valid_date(snapshot["updatedAt"])
    require(snapshot["source"] == PRIME_SOURCE, "Unexpected Prime data source")
    frames = snapshot["frames"]
    require(isinstance(frames, list) and frames, "Prime release list is empty")
    names = set()
    for frame in frames:
        require(isinstance(frame["name"], str) and frame["name"], "Missing frame name")
        require(frame["name"] not in names, "Duplicate frame name")
        names.add(frame["name"])
        valid_date(frame["releaseDate"])
        require(type(frame["isPrime"]) is bool, "Invalid Prime flag")
    require({frame["isPrime"] for frame in frames} == {False, True}, "Expected base and Prime Warframes")


def content_without_timestamp(snapshot, timestamp):
    return {key: value for key, value in snapshot.items() if key != timestamp}


def publish_if_changed(candidate, destination, timestamp):
    old = read_json(destination)
    new = read_json(candidate)
    if content_without_timestamp(old, timestamp) == content_without_timestamp(new, timestamp):
        return False
    os.replace(candidate, destination)
    return True


def refresh():
    with tempfile.TemporaryDirectory(dir=RESOURCES, prefix=".refresh-") as temporary:
        temporary = Path(temporary)
        catalog = temporary / "masterycatalog.json"
        primes = temporary / "primeReleaseOrder.json"
        catalog.write_bytes((RESOURCES / catalog.name).read_bytes())
        environment = dict(os.environ, CATALOG_OUTPUT_PATH=str(catalog))
        subprocess.run(
            ["npm", "run", "generate"], cwd=ROOT / "Scripts/generate_catalog",
            env=environment, check=True, timeout=300
        )
        warframes = temporary / "Warframes.json"
        request = urllib.request.Request(PRIME_SOURCE, headers={"User-Agent": "TennoWatch-data-refresh"})
        with urllib.request.urlopen(request, timeout=60) as response:
            warframes.write_bytes(response.read())
        subprocess.run(
            [os.sys.executable, str(ROOT / "Scripts/generate_prime_release_order.py"),
             str(warframes), "--output", str(primes)], check=True, timeout=60
        )
        validate_catalog(read_json(catalog))
        validate_primes(read_json(primes))
        previous = read_json(RESOURCES / catalog.name)
        updated = read_json(catalog)
        require(updated["schemaVersion"] == previous["schemaVersion"], "Unexpected schema change")
        require(updated["nonItemSources"] == previous["nonItemSources"], "Non-item mastery sources changed")
        statuses = []
        for candidate, timestamp in [(catalog, "generatedAt"), (primes, "updatedAt")]:
            changed = publish_if_changed(candidate, RESOURCES / candidate.name, timestamp)
            statuses.append(f"- {candidate.name}: {'updated' if changed else 'unchanged'}")
        summary = "Bundled game data refresh\n\n" + "\n".join(statuses) + "\n"
        print(summary)
        if os.environ.get("GITHUB_STEP_SUMMARY"):
            with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as output:
                output.write(summary)


def main():
    parser = argparse.ArgumentParser(description="Refresh and validate bundled mastery and Prime data.")
    parser.add_argument("--validate-only", action="store_true", help="Validate existing snapshots without network access")
    args = parser.parse_args()
    if args.validate_only:
        validate_catalog(read_json(RESOURCES / "masterycatalog.json"))
        validate_primes(read_json(RESOURCES / "primeReleaseOrder.json"))
        print("Bundled game data is valid")
    else:
        refresh()


if __name__ == "__main__":
    main()
