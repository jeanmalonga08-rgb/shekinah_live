# Développement sans téléphone physique

Guide pour lancer **Shekinah Live** sur **Chrome/Edge** (Web) ou **Windows** lorsque l'appareil Android n'est pas branché.

## Prérequis

| Plateforme | Requis |
|------------|--------|
| **Web** | Chrome ou Edge (déjà détectés par Flutter) |
| **Windows** | Visual Studio 2022 avec la charge **Développement Desktop en C++** (MSVC, CMake, Windows 10 SDK) |
| **Commun** | Flutter SDK 3.10+, `flutter pub get` |

Vérifier l'environnement :

```powershell
flutter doctor -v
```

Si Windows affiche une erreur Visual Studio, installer [Visual Studio Build Tools](https://visualstudio.microsoft.com/fr/downloads/) ou Visual Studio Community avec la charge **Desktop development with C++**.

## Lancement rapide

### Web (recommandé sans téléphone)

```powershell
# Depuis la racine du projet
.\tool\dev\run-chrome.ps1
```

Ou manuellement :

```powershell
flutter run -d chrome
```

### Windows (bureau)

```powershell
.\tool\dev\run-windows.ps1
```

Ou :

```powershell
flutter run -d windows
```

### Depuis Cursor / VS Code

Menu **Run and Debug** (F5) → choisir :

- **Shekinah Live (Chrome)** — le plus simple sans matériel
- **Shekinah Live (Windows)** — nécessite la toolchain C++
- **Shekinah Live (Android)** — téléphone ou émulateur

## Limites par plateforme

| Fonctionnalité | Android | Windows | Web |
|----------------|---------|---------|-----|
| Navigation, live, prédications, cantiques | Oui | Oui | Oui |
| WebView (live, vidéos) | Oui | Oui | Oui (navigateur) |
| Téléchargements hors ligne | Oui | Oui | Non |
| Lecteur média hors ligne | Oui | Oui | Non |

Sur le **Web**, les téléchargements hors ligne sont désactivés (stockage fichier indisponible). Le reste de l'app reste testable.

## Builds release

```powershell
# Web
flutter build web --release

# Windows
flutter build windows --release
```

Artefacts :

- Web : `build/web/`
- Windows : `build/windows/x64/runner/Release/`

## Dépannage

**`Unable to find suitable Visual Studio toolchain`**  
→ Installer la charge C++ dans Visual Studio, puis `flutter doctor -v`.

**Build Web lent ou erreur mémoire**  
→ Fermer les autres applications ; utiliser `flutter run -d chrome` plutôt qu'un build release pour le dev.

**Licences Android** (si vous rebasculez sur mobile) :

```powershell
flutter doctor --android-licenses
```
