# Auto-recovered ARB keys merged from transcript patches.

from __future__ import annotations

import json
from pathlib import Path

_RECOVERED = Path(__file__).resolve().parent / "recovered_arb.json"


def add_recovered_keys(s) -> None:
    if not _RECOVERED.exists():
        return
    recovered = json.loads(_RECOVERED.read_text(encoding="utf-8"))
    for key in sorted(recovered):
        locales = recovered[key]
        if "fr" not in locales:
            continue
        fr = locales.get("fr", "")
        en = locales.get("en", fr)
        pt = locales.get("pt", en)
        es = locales.get("es", en)
        zh = locales.get("zh", en)
        s(key, fr, en, pt, es, zh)
