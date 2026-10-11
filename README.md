# Shekinah Live

Application mobile Flutter pour le streaming live des services de Shekinah Gospel.

## Description

Shekinah Live est une application élégante et professionnelle qui permet aux fidèles d'accéder facilement aux diffusions en direct des services religieux de Shekinah Tabernacle. L'application détecte automatiquement si un live est en cours et affiche le contenu approprié.

## Fonctionnalités

### Live Streaming
- **Détection automatique** : Vérifie en temps réel si un live est en cours
- **WebView intégré** : Affiche le streaming depuis `https://shekinahgospel.org/live`
- **Gestion des états** : Affiche les statuts EN DIRECT/HORS LIGNE avec des badges animés
- **Mode hors ligne** : Affiche les horaires de culte lorsqu'aucun live n'est disponible

### Interface Utilisateur
- **Design moderne** : Interface Material 3 avec thème sombre par défaut
- **Identité visuelle** : Logo officiel et couleurs Shekinah (#0D1B2A, #FFD700, #FFFFFF)
- **Navigation intuitive** : Bottom Navigation Bar avec 3 sections
- **Splash screen** : Écran de chargement animé avec le logo

### Architecture Technique
- **Clean Architecture** : Séparation claire entre presentation, domain et data
- **State Management** : Flutter Riverpod pour une gestion d'état réactive
- **Gestion des erreurs** : Interface claire pour les erreurs réseau
- **Performance** : Optimisé avec cache et lazy loading

## Structure du Projet

```
lib/
|-- core/                    # Éléments partagés
|   |-- constants/          # Constantes de l'application
|   |-- theme/              # Thème et styles
|   |-- utils/              # Utilitaires
|
|-- domain/                 # Logique métier
|   |-- entities/           # Entités du domaine
|   |-- repositories/       # Interfaces des repositories
|   |-- usecases/           # Cas d'utilisation
|
|-- data/                   # Implémentation de la couche données
|   |-- datasources/        # Sources de données
|   |-- models/             # Modèles de données
|   |-- repositories/       # Implémentation des repositories
|
|-- presentation/           # Couche présentation
|   |-- pages/              # Écrans de l'application
|   |-- widgets/            # Widgets réutilisables
|   |-- providers/          # Providers Riverpod
```

## Technologies Utilisées

- **Flutter 3.38.5** : Framework de développement multiplateforme
- **Riverpod** : Gestion d'état réactive
- **WebView Flutter** : Intégration de contenu web
- **Dio** : Client HTTP pour les requêtes réseau
- **Dartz** : Programmation fonctionnelle (Either/Result)
- **Cached Network Image** : Cache d'images réseau
- **Flutter Spinkit** : Indicateurs de chargement animés

## Installation

### Prérequis
- Flutter SDK 3.10.4 ou supérieur
- Android SDK (pour Android)
- Xcode (pour iOS)
- Chrome ou Edge (pour le Web — **sans téléphone**)
- Visual Studio 2022 + charge **Desktop development with C++** (pour Windows)

### Développement sans téléphone

Voir le guide détaillé : [`tool/dev/DEV_SANS_TELEPHONE.md`](tool/dev/DEV_SANS_TELEPHONE.md)

```powershell
# Web (le plus simple)
.\tool\dev\run-chrome.ps1

# Windows (bureau)
.\tool\dev\run-windows.ps1
```

Dans Cursor/VS Code : **Run and Debug** → **Shekinah Live (Chrome)** ou **Shekinah Live (Windows)**.

### Étapes d'installation

1. **Cloner le repository**
   ```bash
   git clone [repository-url]
   cd shekinah_live
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Vérifier la configuration**
   ```bash
   flutter doctor
   ```

4. **Lancer l'application**
   ```bash
   # Android (téléphone ou émulateur)
   flutter run -d android

   # Web (sans téléphone)
   flutter run -d chrome

   # Windows (sans téléphone, toolchain C++ requise)
   flutter run -d windows
   ```

## Configuration

### Assets
- Le logo officiel est téléchargé automatiquement depuis `https://shekinahgospel.org/images/logo-trans.png`
- Les assets sont configurés dans `pubspec.yaml`

### URLs de Streaming
- URL principale : `https://shekinahgospel.org/live`
- URL du site : `https://shekinahgospel.org`

### Thème
- **Couleurs** :
  - Bleu foncé : `#0D1B2A` (principal)
  - Or : `#FFD700` (accent)
  - Blanc : `#FFFFFF` (texte)
- **Typographie** : Material Design 3
- **Mode par défaut** : Sombre

## Développement

### Lancer en mode développement
```bash
flutter run --debug
```

### Analyser le code
```bash
flutter analyze
```

### Tester
```bash
flutter test
```

### Build pour production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# iOS
flutter build ios --release
```

### Publication Android et notification automatique

Pour publier sur Google Play et notifier les utilisateurs après succès, ouvrir
GitHub Actions → **Publish Android to Google Play** et choisir `alpha` (test fermé)
ou `production`. Mettre à jour `version:` dans `pubspec.yaml` avant de lancer le workflow.
Le canal `alpha` notifie après le dépôt du test fermé. Pour `production`, le workflow
attend l’approbation de l’environnement `production-review` avant de notifier. Dans
GitHub → **Settings → Environments**, créer cet environnement et activer
**Required reviewers**. L’approbateur doit vérifier dans Play Console que l’examen
est terminé et que la version est disponible avant d’approuver le job dans Actions.

Configurer ces secrets dans le dépôt GitHub :

- `ANDROID_RELEASE_KEYSTORE_BASE64` : contenu Base64 de `android/app/release.keystore`.
- `ANDROID_RELEASE_KEYSTORE_PASSWORD`, `ANDROID_RELEASE_KEY_ALIAS` et `ANDROID_RELEASE_KEY_PASSWORD` : paramètres de signature Android.
- `PLAY_STORE_SERVICE_ACCOUNT_JSON` : JSON d’un compte autorisé à publier l’application dans Google Play Console.
- `OPS_API_KEY` : clé Ops de l’API notifications.

Pour un build local `--release`, créer `android/key.properties` (ignoré par Git) avec
`storeFile=app/release.keystore`, `storePassword`, `keyAlias` et `keyPassword`.
Ne jamais committer le keystore, ce fichier ou les secrets.

## Fonctionnalités Futures

- [ ] **Archives des cultes** : Accès aux enregistrements précédents
- [ ] **Notifications push** : Alertes avant les lives
- [ ] **Mode plein écran** : Interface immersive pour le streaming
- [ ] **Partage social** : Partager les lives sur les réseaux
- [ ] **Multilingue** : Support anglais et français
- [ ] **Chat intégré** : Interaction pendant les lives

## Support et Contact

Pour toute question ou suggestion concernant l'application :

- **Site web** : https://shekinahgospel.org
- **Email** : contact@shekinahgospel.org

## Licence

Ce projet est la propriété de Shekinah Gospel. Tous droits réservés.

---

**Développé avec Flutter**  
*Pour la gloire de Dieu*
