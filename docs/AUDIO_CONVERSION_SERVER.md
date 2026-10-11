# Conversion audio serveur (FFmpeg)

## Objectif

Convertir une vidéo Vimeo/YouTube en audio compressé **sur le serveur**
(`api_notif_live`), afin que l'application Flutter ne télécharge que le
fichier audio final (pas la vidéo originale multi-Go).

## Prérequis serveur

### FFmpeg

Installer FFmpeg et s'assurer que la commande est dans le `PATH`, ou
configurer le chemin absolu :

```json
"Ffmpeg": {
  "Path": "/usr/bin/ffmpeg"
}
```

Vérification :

```bash
ffmpeg -version
```

Le endpoint `/health` expose `ffmpeg.available` et `ffmpeg.version`.

### yt-dlp (YouTube, optionnel)

```json
"Youtube": {
  "Enabled": true,
  "YtDlpPath": "yt-dlp"
}
```

Si yt-dlp est absent, les conversions YouTube renvoient `UNSUPPORTED_SOURCE`.
Les conversions Vimeo restent disponibles.

### Token Vimeo

```json
"Vimeo": {
  "AccessToken": "<token>",
  "UserAgent": "ShekinahLive-AudioConversion/1.0"
}
```

Le serveur résout les URLs `download` Vimeo. Si la vidéo n'a pas de fichier
téléchargeable (pas de DRM bypass), l'API renvoie `UNSUPPORTED_SOURCE`.

### Stockage

```json
"AudioConversion": {
  "Enabled": true,
  "StorageRoot": "data/audio-conversions",
  "MaxConcurrentJobs": 1,
  "MaxQueuedJobs": 20,
  "JobTimeoutMinutes": 180,
  "MaxSourceDurationSeconds": 21600,
  "OutputTtlDays": 14,
  "MaxOutputStorageGb": 10
}
```

Prévoir suffisamment d'espace disque (vidéo streamée via FFmpeg + audio
sortie). Les fichiers expirés sont purgés périodiquement (TTL). Si `out/`
dépasse `MaxOutputStorageGb`, les fichiers les plus anciens sont supprimés
même avant la fin du TTL.

## Endpoints

| Méthode | Route | Description |
|---------|-------|-------------|
| POST | `/api/v1/media/{mediaId}/audio-conversion` | Démarre (ou cache hit) |
| GET | `/api/v1/audio-conversion/{jobId}` | Statut / progression |
| GET | `/api/v1/audio-conversion/{jobId}/file` | Téléchargement audio (Range) |
| POST | `/api/v1/audio-conversion/{jobId}/cancel` | Annulation |

Auth device : headers `X-Installation-Id` + `X-Fcm-Token` (comme les notifs).

Body POST :

```json
{
  "provider": "vimeo",
  "videoId": "123456789",
  "profile": "standard"
}
```

Profils : `economy` (Opus 48k), `standard` (Opus 64k), `compatible` (AAC 96k).

## Migration base

Au démarrage, `Database.MigrateAsync()` applique la migration
`AddAudioConversionJobs`.

## Checklist tests

- [ ] Petite vidéo (5–20 min) — profil standard
- [ ] Longue prédication (2–4 h)
- [ ] Cache hit : 2ᵉ demande même média/profil → `completed` immédiat
- [ ] Source Vimeo sans `download` → `UNSUPPORTED_SOURCE`
- [ ] Coupure pendant téléchargement audio → reprise Range
- [ ] Push « Votre audio est prêt » sur le device demandeur
- [ ] `/health` → `ffmpeg.available: true`
- [ ] Flutter n'appelle plus `videoDownloadsProvider` pour « Convertir en audio »

## Déploiement

1. Installer FFmpeg (+ yt-dlp si besoin) sur l'hôte.
2. Déployer `api_notif_live` avec les sections `AudioConversion`, `Ffmpeg`, `Vimeo`.
3. Vérifier `/health`.
4. Publier l'app Flutter qui utilise le nouveau flux.
