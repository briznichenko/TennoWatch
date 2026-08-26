#!/usr/bin/env python3
import json
import sys
import argparse


def escape_swift_string(s: str) -> str:
    return s.replace("\\", "\\\\").replace("\"", "\\\"")


def build_swift_dict(data: dict, key_field: str = "InternalName") -> dict:
    # Swapped: the value pulled from the JSON (InternalName) becomes the Swift
    # dictionary KEY, and the outer JSON key becomes the Swift dictionary VALUE.
    result = {}
    for outer_key, obj in data.items():
        if not isinstance(obj, dict):
            print(f"warning: skipping '{outer_key}' — value is not an object", file=sys.stderr)
            continue
        if key_field not in obj:
            print(f"warning: skipping '{outer_key}' — missing '{key_field}'", file=sys.stderr)
            continue
        internal_name = obj[key_field]
        if internal_name in result:
            print(f"warning: duplicate key '{internal_name}' (from '{outer_key}') overwrites previous value '{result[internal_name]}'", file=sys.stderr)
        result[internal_name] = outer_key
    return result


def to_swift_literal(mapping: dict, var_name: str) -> str:
    if not mapping:
        return f"struct ExternalData {{\n    static let {var_name}: [String: String] = [:]\n}}"
    entries = ",\n        ".join(
        f'"{escape_swift_string(k)}": "{escape_swift_string(v)}"'
        for k, v in mapping.items()
    )
    return (
        "struct ExternalData {\n"
        f"    static let {var_name}: [String: String] = [\n"
        f"        {entries}\n"
        "    ]\n"
        "}"
    )


def main():
    parser = argparse.ArgumentParser(description="Convert JSON to a Swift ExternalData struct with a [String: String] dictionary.")
    parser.add_argument("input", help="Path to input JSON file")
    parser.add_argument("--key-field", default="InternalName", help="Field name whose value becomes the Swift dictionary KEY (default: InternalName)")
    parser.add_argument("--var-name", default="persistentItemNames", help="Name of the generated static let (default: persistentItemNames)")
    args = parser.parse_args()

    with open(args.input, "r", encoding="utf-8") as f:
        data = json.load(f)

    mapping = build_swift_dict(data, args.key_field)
    print(to_swift_literal(mapping, args.var_name))


if __name__ == "__main__":
    main()