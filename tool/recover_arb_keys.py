#!/usr/bin/env python3
"""Recover ARB key definitions from agent transcript JSONL patches."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TRANSCRIPT_DIRS = [
    Path(
        r"C:\Users\JEAN MALONGA\.cursor\projects\c-Developpements-shekinah-live"
        r"\agent-transcripts"
    ),
]

LOCALE_SUFFIX = {
    "app_fr.arb": "fr",
    "app_en.arb": "en",
    "app_pt.arb": "pt",
    "app_es.arb": "es",
    "app_zh.arb": "zh",
}


def parse_arb_fragment(fragment: str) -> dict[str, str]:
    fragment = fragment.strip()
    if not fragment:
        return {}
    if fragment.endswith(","):
        fragment = fragment[:-1]
    wrapped = "{" + fragment + "}"
    try:
        data = json.loads(wrapped)
    except json.JSONDecodeError:
        return {}
    return {
        key: value
        for key, value in data.items()
        if not key.startswith("@") and isinstance(value, str)
    }


def recover_keys() -> dict[str, dict[str, str]]:
    recovered: dict[str, dict[str, str]] = {}
    for transcript in TRANSCRIPT_DIRS[0].rglob("*.jsonl"):
        for line in transcript.read_text(encoding="utf-8").splitlines():
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue
            msg = event.get("message", {})
            for block in msg.get("content", []):
                if block.get("type") != "tool_use":
                    continue
                inp = block.get("input")
                if not isinstance(inp, dict):
                    continue
                path = str(inp.get("path", ""))
                new_string = inp.get("new_string", "")
                if not new_string:
                    continue
                for locale_file, locale in LOCALE_SUFFIX.items():
                    if locale_file not in path:
                        continue
                    for key, value in parse_arb_fragment(new_string).items():
                        recovered.setdefault(key, {})[locale] = value
    return recovered


def main() -> None:
    recovered = recover_keys()
    out = ROOT / "tool" / "recovered_arb.json"
    out.write_text(json.dumps(recovered, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Recovered {len(recovered)} keys -> {out}")


if __name__ == "__main__":
    main()
