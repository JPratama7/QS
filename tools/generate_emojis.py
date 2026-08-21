#!/usr/bin/env python3
"""
Generate data/emojis.json for the Quickshell emoji picker.

Source: rofimoji 6.7.0 character data (MIT, fdw/rofimoji), derived from
Unicode CLDR annotation data (Unicode license terms apply to annotations).

Usage: python3 tools/generate_emojis.py [ROFIMOJI_DATA_DIR]
Default: /usr/lib/python3.14/site-packages/picker/data
Output:  data/emojis.json  (compact JSON array of {c, n, k} objects)
"""
import json, re, sys, pathlib

def main() -> None:
    source = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 \
        else pathlib.Path("/usr/lib/python3.14/site-packages/picker/data")
    if not source.is_dir():
        print(f"error: rofimoji data dir not found: {source}", file=sys.stderr)
        sys.exit(1)

    entries = {}
    for csv in sorted(source.glob("emojis_*.csv")):
        for line in csv.read_text(encoding="utf-8").strip().splitlines():
            char, _, rest = line.partition(" ")
            m = re.match(r"^(.*?)(?: <small>\((.*)\)</small>)?$", rest)
            name, kw_block = m.group(1), m.group(2) or ""
            entry = entries.setdefault(char, {"c": char, "n": name, "k": []})
            entry["k"].extend(k.strip() for k in kw_block.split(",") if k.strip())

    alias_file = source / "additional" / "emojis_smileys_emotion.csv"
    if alias_file.is_file():
        for line in alias_file.read_text(encoding="utf-8").strip().splitlines():
            char, _, aliases = line.partition(" ")
            if char in entries:
                entries[char]["k"].extend(a.strip() for a in aliases.split(",") if a.strip())

    out = pathlib.Path(__file__).resolve().parent.parent / "data" / "emojis.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(list(entries.values()), ensure_ascii=False,
                              separators=(",", ":")), encoding="utf-8")
    print(f"wrote {len(entries)} entries to {out}")

if __name__ == "__main__":
    main()
