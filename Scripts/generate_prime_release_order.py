#!/usr/bin/env python3
import argparse
import datetime
import json
from pathlib import Path

SOURCE_URL = "https://raw.githubusercontent.com/WFCD/warframe-items/master/data/json/Warframes.json"


def main():
    parser = argparse.ArgumentParser(description="Build the bundled Prime watchlist from WFCD Warframes.json.")
    parser.add_argument("input", type=Path, help=f"Warframes.json downloaded from {SOURCE_URL}")
    args = parser.parse_args()
    items = json.loads(args.input.read_text())
    frames = []
    for item in items:
        if item.get("type") != "Warframe" or item.get("productCategory") != "Suits":
            continue
        if item["name"].endswith(" Umbra") or not item.get("releaseDate"):
            continue
        release_date = datetime.date.fromisoformat(item["releaseDate"])
        frames.append({
            "name": item["name"],
            "releaseDate": f"{release_date.isoformat()}T00:00:00Z",
            "isPrime": item["isPrime"],
        })
    if not frames or not any(frame["isPrime"] for frame in frames):
        raise ValueError("Expected both base and Prime Warframes")
    snapshot = {
        "updatedAt": f"{datetime.datetime.now(datetime.timezone.utc).date().isoformat()}T00:00:00Z",
        "source": SOURCE_URL,
        "frames": sorted(frames, key=lambda frame: (frame["releaseDate"], frame["name"])),
    }
    output = Path(__file__).resolve().parents[1] / "TennoWatch/Resources/primeReleaseOrder.json"
    output.write_text(json.dumps(snapshot, indent=2) + "\n")


if __name__ == "__main__":
    main()
