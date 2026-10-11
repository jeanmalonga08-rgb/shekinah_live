#!/usr/bin/env python3
"""Generate Flutter gen-l10n ARB files for Shekinah Live."""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

from arb_catalog import populate

try:
    from recovered_arb_snippet import add_recovered_keys
except ImportError:
    def add_recovered_keys(_s) -> None:
        return

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "lib" / "l10n"

LOCALES = ("fr", "en", "pt", "es", "zh")
TEMPLATE_LOCALE = "fr"

T: dict[str, dict[str, str]] = {}


def s(key: str, fr: str, en: str, pt: str, es: str, zh: str) -> None:
    if key in T:
        return
    T[key] = {"fr": fr, "en": en, "pt": pt, "es": es, "zh": zh}


# Placeholder metadata (template ARB only).
PLACEHOLDER_META: dict[str, dict[str, Any]] = {
    "worshipAt": {"time": {"type": "String"}},
    "liveWatchingSince": {"elapsed": {"type": "String"}},
    "cantiquesNumber": {"number": {"type": "int"}},
    "cultesService": {"day": {"type": "String"}},
    "notificationsNextServiceBody": {"time": {"type": "String"}},
    "requetesSubtitle": {"appName": {"type": "String"}},
    "shareAppMessage": {
        "appName": {"type": "String"},
        "playStoreUrl": {"type": "String"},
        "websiteUrl": {"type": "String"},
    },
    "sharePredicationSubject": {"title": {"type": "String"}},
    "sharePredicationBody": {
        "title": {"type": "String"},
        "preacher": {"type": "String"},
        "date": {"type": "String"},
        "archivesUrl": {"type": "String"},
        "playStoreUrl": {"type": "String"},
    },
    "shareCantiqueSubject": {"title": {"type": "String"}},
    "shareCantiqueBody": {
        "title": {"type": "String"},
        "subtitle": {"type": "String"},
        "appName": {"type": "String"},
        "playStoreUrl": {"type": "String"},
        "websiteUrl": {"type": "String"},
    },
    "shareOfflineBody": {
        "category": {"type": "String"},
        "title": {"type": "String"},
        "subtitle": {"type": "String"},
        "format": {"type": "String"},
        "appName": {"type": "String"},
        "playStoreUrl": {"type": "String"},
        "websiteUrl": {"type": "String"},
    },
    "shareListenInApp": {"appName": {"type": "String"}},
    "shareSite": {"url": {"type": "String"}},
    "downloadProgress": {"percent": {"type": "int"}},
    "downloadManagerSummary": {
        "active": {"type": "int"},
        "total": {"type": "int"},
    },
    "downloadManagerErrors": {"count": {"type": "int"}},
    "downloadSpeedPerSec": {"size": {"type": "String"}},
    "libraryDownloadAllQueued": {
        "queued": {"type": "int"},
        "skipped": {"type": "int"},
    },
    "deleteOfflineConfirm": {"title": {"type": "String"}},
    "offlineFileCount": {"count": {"type": "int"}},
    "predicationCount": {"count": {"type": "int"}},
    "cantiqueCount": {"count": {"type": "int"}},
    "notificationUnread": {"count": {"type": "int"}},
    "ceremonyCount": {"count": {"type": "int"}},
    "contactCopyright": {"version": {"type": "String"}},
    "libraryBooksAvailable": {"count": {"type": "int"}},
    "libraryMessagesAvailable": {"count": {"type": "int"}},
    "libraryDownloadAllConfirm": {"count": {"type": "int"}},
    "libraryDownloadAllDone": {
        "downloaded": {"type": "int"},
        "skipped": {"type": "int"},
    },
    "libraryDownloadAllProgress": {
        "current": {"type": "int"},
        "total": {"type": "int"},
    },
    "libraryMessageCount": {"count": {"type": "int"}},
    "notreEgliseSisterChurchesCount": {"count": {"type": "int"}},
    "countdownWithDays": {
        "days": {"type": "int"},
        "hours": {"type": "String"},
        "minutes": {"type": "String"},
    },
    "countdownWithHours": {
        "hours": {"type": "String"},
        "minutes": {"type": "String"},
        "seconds": {"type": "String"},
    },
    "countdownMinutesOnly": {
        "minutes": {"type": "String"},
        "seconds": {"type": "String"},
    },
    "countdownChronoWithDays": {
        "days": {"type": "int"},
        "time": {"type": "String"},
    },
}


def add_special_strings() -> None:
    s(
        "sharePredicationBody",
        "Prédication : {title}\n{preacher}\n{date}\n\nÉcoutez cette prédication dans l'application Shekinah Tabernacle :\n{playStoreUrl}\n\nSite : {archivesUrl}",
        "Sermon: {title}\n{preacher}\n{date}\n\nListen to this sermon in the Shekinah Tabernacle app:\n{playStoreUrl}\n\nWebsite: {archivesUrl}",
        "Pregação: {title}\n{preacher}\n{date}\n\nOuça esta pregação no aplicativo Shekinah Tabernacle:\n{playStoreUrl}\n\nSite: {archivesUrl}",
        "Predicación: {title}\n{preacher}\n{date}\n\nEscuche esta predicación en la aplicación Shekinah Tabernacle:\n{playStoreUrl}\n\nSitio: {archivesUrl}",
        "讲道：{title}\n{preacher}\n{date}\n\n在 Shekinah Tabernacle 应用中收听此讲道：\n{playStoreUrl}\n\n网站：{archivesUrl}",
    )
    s(
        "downloadProgress",
        "Téléchargement… {percent} %",
        "Downloading… {percent}%",
        "Baixando… {percent}%",
        "Descargando… {percent}%",
        "下载中… {percent}%",
    )
    s(
        "deleteOfflineConfirm",
        "Retirer « {title} » de la mémoire de l'appareil ?",
        "Remove \"{title}\" from device storage?",
        "Remover \"{title}\" da memória do dispositivo?",
        "¿Eliminar «{title}» de la memoria del dispositivo?",
        "从设备存储中移除「{title}」？",
    )
    s(
        "offlineFileCount",
        "{count, plural, =0{Aucun fichier} =1{1 fichier} other{{count} fichiers}}",
        "{count, plural, =0{No files} =1{1 file} other{{count} files}}",
        "{count, plural, =0{Nenhum arquivo} =1{1 arquivo} other{{count} arquivos}}",
        "{count, plural, =0{Sin archivos} =1{1 archivo} other{{count} archivos}}",
        "{count, plural, =0{无文件} =1{1 个文件} other{{count} 个文件}}",
    )
    s(
        "predicationCount",
        "{count, plural, =0{Aucune prédication} =1{1 prédication} other{{count} prédications}}",
        "{count, plural, =0{No sermons} =1{1 sermon} other{{count} sermons}}",
        "{count, plural, =0{Nenhuma pregação} =1{1 pregação} other{{count} pregações}}",
        "{count, plural, =0{Sin predicaciones} =1{1 predicación} other{{count} predicaciones}}",
        "{count, plural, =0{无讲道} =1{1 篇讲道} other{{count} 篇讲道}}",
    )
    s(
        "cantiqueCount",
        "{count, plural, =0{Aucun cantique} =1{1 cantique} other{{count} cantiques}}",
        "{count, plural, =0{No hymns} =1{1 hymn} other{{count} hymns}}",
        "{count, plural, =0{Nenhum cântico} =1{1 cântico} other{{count} cânticos}}",
        "{count, plural, =0{Sin cánticos} =1{1 cántico} other{{count} cánticos}}",
        "{count, plural, =0{无诗歌} =1{1 首诗歌} other{{count} 首诗歌}}",
    )
    s(
        "notificationUnread",
        "{count, plural, =0{Aucune notification non lue} =1{1 notification non lue} other{{count} notifications non lues}}",
        "{count, plural, =0{No unread notifications} =1{1 unread notification} other{{count} unread notifications}}",
        "{count, plural, =0{Nenhuma notificação não lida} =1{1 notificação não lida} other{{count} notificações não lidas}}",
        "{count, plural, =0{Sin notificaciones sin leer} =1{1 notificación sin leer} other{{count} notificaciones sin leer}}",
        "{count, plural, =0{无未读通知} =1{1 条未读通知} other{{count} 条未读通知}}",
    )
    s(
        "ceremonyCount",
        "{count, plural, =0{Aucune cérémonie} =1{1 cérémonie} other{{count} cérémonies}}",
        "{count, plural, =0{No ceremonies} =1{1 ceremony} other{{count} ceremonies}}",
        "{count, plural, =0{Nenhuma cerimônia} =1{1 cerimônia} other{{count} cerimônias}}",
        "{count, plural, =0{Sin ceremonias} =1{1 ceremonia} other{{count} ceremonias}}",
        "{count, plural, =0{无典礼} =1{1 场典礼} other{{count} 场典礼}}",
    )
    s(
        "offlineStorageSummary",
        "{count, plural, =1{1 fichier} other{{count} fichiers}} · {sizeMb} Mo",
        "{count, plural, =1{1 file} other{{count} files}} · {sizeMb} MB",
        "{count, plural, =1{1 arquivo} other{{count} arquivos}} · {sizeMb} MB",
        "{count, plural, =1{1 archivo} other{{count} archivos}} · {sizeMb} MB",
        "{count, plural, =1{1 个文件} other{{count} 个文件}} · {sizeMb} MB",
    )
    PLACEHOLDER_META["offlineStorageSummary"] = {
        "count": {"type": "int"},
        "sizeMb": {"type": "String"},
    }
    PLACEHOLDER_META["sizeKilobytes"] = {"size": {"type": "int"}}
    PLACEHOLDER_META["sizeMegabytes"] = {"size": {"type": "String"}}


def build_arb(locale: str) -> dict[str, Any]:
    arb: dict[str, Any] = {"@@locale": locale}
    for key in sorted(T):
        arb[key] = T[key][locale]
        if locale == TEMPLATE_LOCALE and key in PLACEHOLDER_META:
            arb[f"@{key}"] = {"placeholders": PLACEHOLDER_META[key]}
    return arb


def write_arb_files() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    key_count = len(T)
    for locale in LOCALES:
        path = OUT_DIR / f"app_{locale}.arb"
        data = build_arb(locale)
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"Wrote {path.relative_to(ROOT)} ({len(data) - 1} entries)")
    return key_count


def main() -> int:
    populate(s)
    add_recovered_keys(s)
    add_special_strings()
    count = write_arb_files()
    print(f"\nGenerated {count} localization keys across {len(LOCALES)} locales.")
    return count


if __name__ == "__main__":
    sys.exit(0 if main() else 1)
