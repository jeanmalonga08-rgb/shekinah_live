# iOS push — à faire sur Mac

Quand tu ouvres ce projet **depuis un Mac**, suis cette checklist pour activer les notifications push iOS.

> Déjà fait : `GoogleService-Info.plist`, `Info.plist` (`remote-notification`), `AppDelegate` (Firebase), branchement Flutter + API.

## 1. Clé APNs dans Firebase

1. [Apple Developer](https://developer.apple.com/account/) → **Keys** → **+**
2. Cocher **Apple Push Notifications service (APNs)**
3. Télécharger le fichier **`.p8`** (une seule fois — ne pas le perdre)
4. Noter **Key ID** et **Team ID**
5. [Firebase Console](https://console.firebase.google.com/) → projet **shekinah-tabernacle-f5346**
6. ⚙ **Project settings** → **Cloud Messaging** → **Apple app configuration**
7. Upload : fichier `.p8` + Key ID + Team ID

## 2. Xcode

```bash
cd ios
pod install
cd ..
open ios/Runner.xcworkspace
```

Dans Xcode → cible **Runner** → **Signing & Capabilities** :

- **Team** : ton compte Apple Developer
- **Bundle ID** : `com.shekinah.tabernacle`
- **+ Capability** → **Push Notifications**
- **+ Capability** → **Background Modes** → cocher **Remote notifications**

## 3. Lancer et tester

```bash
# Terminal 1 — API (sur le Mac ou PC du réseau)
cd api_notif_live && dotnet run

# Terminal 2 — app sur iPhone branché (pas simulateur pour push fiable)
flutter run --dart-define=NOTIF_API_URL=http://<IP_DU_PC>:5170
```

- Accepter la permission notifications au premier lancement
- Test push (Swagger ou `.http`) :
  ```http
  POST http://localhost:5170/api/v1/ops/notifications/test
  X-Ops-Key: dev-ops-key-change-me
  ```

## 4. Vérifications si ça ne marche pas

- [ ] Clé APNs bien uploadée dans Firebase
- [ ] Push Notifications activé dans Xcode
- [ ] Test sur **iPhone physique** (pas simulateur)
- [ ] API accessible depuis le téléphone (`NOTIF_API_URL` = IP locale du PC)
- [ ] Device enregistré : `POST /api/v1/devices/register` visible en base `ShekinahNotifLive`

## Rappel pour l’assistant Cursor

Si tu dis : **« Je suis sur Mac pour Shekinah Live — rappelle-moi la config iOS push »**, l’assistant doit te guider avec ce fichier.
