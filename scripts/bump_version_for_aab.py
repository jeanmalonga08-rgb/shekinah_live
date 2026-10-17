#!/usr/bin/env python3
"""Bump pubspec.yaml version before flutter build appbundle.

Policy (Shekinah Live):
- Increment the Android build number monotonically (x.y.z+N -> x.y.z+(N+1)).
- Never reset the build number: Google Play requires versionCode to increase.

Also syncs:
- lib/core/constants/app_constants.dart (appVersion)

After publishing the AAB to the store, run:
    python scripts/bump_version_for_aab.py --sync-api-only

Usage:
  python scripts/bump_version_for_aab.py          # apply
  python scripts/bump_version_for_aab.py --dry-run
    python scripts/bump_version_for_aab.py --sync-api-only  # after store publication
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUBSPEC = ROOT / "pubspec.yaml"
APP_CONSTANTS = ROOT / "lib" / "core" / "constants" / "app_constants.dart"
API_APPSETTINGS_PROD = ROOT / "api_notif_live" / "appsettings.Production.json"
DEFAULT_NOTIF_API_URL = "https://api-live.asdc-rdc.org"

VERSION_LINE = re.compile(r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$", re.M)
APP_VERSION = re.compile(
    r"(static const String appVersion = ')(\d+\.\d+\.\d+)(';)"
)


def next_version(major: int, minor: int, patch: int, build: int) -> tuple[int, int, int, int]:
    return major, minor, patch, build + 1


def parse_pubspec(text: str) -> tuple[int, int, int, int]:
    match = VERSION_LINE.search(text)
    if not match:
        raise SystemExit("Could not find version: x.y.z+build in pubspec.yaml")
    return tuple(int(g) for g in match.groups())  # type: ignore[return-value]


def apply_pubspec(text: str, major: int, minor: int, patch: int, build: int) -> str:
    replacement = f"version: {major}.{minor}.{patch}+{build}"
    return VERSION_LINE.sub(replacement, text, count=1)


def apply_app_constants(text: str, name: str) -> str:
    if not APP_VERSION.search(text):
        raise SystemExit("Could not find appVersion in app_constants.dart")
    return APP_VERSION.sub(rf"\g<1>{name}\g<3>", text, count=1)


def load_ops_key() -> str | None:
    env_key = os.environ.get("OPS_API_KEY", "").strip()
    if env_key:
        return env_key
    if not API_APPSETTINGS_PROD.is_file():
        return None
    try:
        data = json.loads(API_APPSETTINGS_PROD.read_text(encoding="utf-8"))
        key = (data.get("Ops") or {}).get("ApiKey")
        return key.strip() if isinstance(key, str) and key.strip() else None
    except (json.JSONDecodeError, OSError):
        return None


def sync_version_to_api(version_label: str, release_notes: str, release_channel: str) -> bool:
    api_url = os.environ.get("NOTIF_API_URL", DEFAULT_NOTIF_API_URL).strip().rstrip("/")
    ops_key = load_ops_key()
    if not ops_key:
        print(
            "Skip API sync: set OPS_API_KEY or Ops:ApiKey in "
            "api_notif_live/appsettings.Production.json"
        )
        return False

    payload = {
        "latestVersion": version_label,
        "releaseNotes": release_notes,
        "notifyUsers": True,
        "releaseChannel": release_channel,
    }
    url = f"{api_url}/api/v1/ops/app/version"
    request = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "X-Ops-Key": ops_key,
        },
        method="PUT",
    )

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            print(f"API app_config synced ({response.status}): {version_label} -> {api_url}")
            return True
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        print(f"Warning: API sync HTTP {exc.code}: {body}", file=sys.stderr)
    except OSError as exc:
        print(f"Warning: API sync failed: {exc}", file=sys.stderr)
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Bump version before AAB build.")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the new version without writing files.",
    )
    parser.add_argument(
        "--no-sync-api",
        action="store_true",
        help="Deprecated; normal version bumps no longer sync to the API.",
    )
    parser.add_argument(
        "--sync-api-only",
        action="store_true",
        help="Sync the current full version to the API after store publication.",
    )
    parser.add_argument(
        "--track",
        choices=("alpha", "production"),
        default="production",
        help="Google Play track being published (used with --sync-api-only).",
    )
    args = parser.parse_args()

    pubspec_text = PUBSPEC.read_text(encoding="utf-8")
    major, minor, patch, build = parse_pubspec(pubspec_text)
    if args.sync_api_only:
        version_name = f"{major}.{minor}.{patch}"
        version_label = f"{version_name}+{build}"
        release_notes = f"Version {version_name} de Shekinah Tabernacle disponible sur le store."
        return (
            0
            if sync_version_to_api(version_label, release_notes, args.track)
            else 1
        )

    old_label = f"{major}.{minor}.{patch}+{build}"

    n_major, n_minor, n_patch, n_build = next_version(major, minor, patch, build)
    new_label = f"{n_major}.{n_minor}.{n_patch}+{n_build}"
    new_name = f"{n_major}.{n_minor}.{n_patch}"
    release_notes = (
        f"Version {new_name} — bannière de mise à jour, "
        "rappel audio hors culte, améliorations."
    )

    if old_label == new_label:
        print(f"Version unchanged: {old_label}")
        return 0

    print(f"{old_label} -> {new_label}")

    if args.dry_run:
        return 0

    PUBSPEC.write_text(
        apply_pubspec(pubspec_text, n_major, n_minor, n_patch, n_build),
        encoding="utf-8",
    )

    constants_text = APP_CONSTANTS.read_text(encoding="utf-8")
    APP_CONSTANTS.write_text(
        apply_app_constants(constants_text, new_name),
        encoding="utf-8",
    )

    print(f"Updated {PUBSPEC.relative_to(ROOT)} and {APP_CONSTANTS.relative_to(ROOT)}")

    print(
        "After the new version is available on the store, run "
        "scripts/bump_version_for_aab.py --sync-api-only to notify users."
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())
