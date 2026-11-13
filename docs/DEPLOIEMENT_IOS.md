# Envoi iOS vers App Store Connect

Le workflow GitHub Actions « Upload iOS to App Store Connect » est déclenché manuellement. Il compile la branche choisie, signe l'application `com.shekinah.tabernacle` avec l'équipe Apple `8VY74895M3`, conserve l'IPA pendant 14 jours et l'envoie à App Store Connect. Il ne soumet pas la version à Apple et ne la publie pas. L'envoi nécessite un runner macOS et Xcode 26.

## Configuration initiale

1. Vérifier dans App Store Connect que l'application existante possède bien l'identifiant `com.shekinah.tabernacle` et appartient à l'équipe `8VY74895M3`.
2. Créer une clé API **d'équipe** App Store Connect, autorisée à gérer la signature et l'envoi, puis télécharger son fichier `.p8`. Une clé individuelle ne permet pas la gestion des profils de provisioning. Conserver la clé en lieu sûr.
3. Exporter depuis le trousseau macOS un certificat **Apple Distribution** valide de cette équipe, avec sa clé privée, au format `.p12` protégé par mot de passe. Encoder ce fichier en base64, sans le committer.
4. Dans GitHub, créer l'environnement `ios-app-store` et y configurer les secrets suivants :

   - `APPLE_CERTIFICATE_BASE64` : contenu base64 du fichier `.p12` ;
   - `APPLE_CERTIFICATE_PASSWORD` : mot de passe du fichier `.p12` ;
   - `APPLE_PROVISIONING_PROFILE_BASE64` : contenu base64 du profil App Store Connect `.mobileprovision`, associé au certificat de distribution ;
   - `APP_STORE_CONNECT_KEY_ID` : identifiant de la clé API ;
   - `APP_STORE_CONNECT_ISSUER_ID` : identifiant de l'émetteur de la clé d'équipe ;
   - `APP_STORE_CONNECT_PRIVATE_KEY` : contenu complet du fichier `.p8`.

   Sur macOS, `base64 -i certificat.p12 | pbcopy` copie le certificat encodé dans le presse-papiers. Pour le profil sous Windows, utiliser `[Convert]::ToBase64String([IO.File]::ReadAllBytes('chemin\vers\profil.mobileprovision')) | Set-Clipboard`. Ne jamais afficher ni ajouter ces valeurs au dépôt. Restreindre les branches autorisées et configurer les approbateurs de l'environnement si ces protections sont disponibles sur le dépôt.

## Utilisation

1. Pousser les modifications et ce workflow sur GitHub. Attendre la fin du workflow Android si celui-ci met à jour la version sur la branche, puis choisir le commit souhaité.
2. Vérifier la version dans `pubspec.yaml` : elle doit correspondre à une version acceptée dans App Store Connect. Le workflow ne modifie pas cette version.
3. Dans **Actions → Upload iOS to App Store Connect → Run workflow**, choisir la branche et saisir un numéro de build entier supérieur aux builds déjà envoyés pour cette version. Chaque nouvel essai après un envoi accepté doit utiliser un nouveau numéro.
4. Après traitement par Apple, choisir le build dans App Store Connect pour TestFlight ou pour la version App Store, compléter les informations requises puis soumettre à la revue. La mise en ligne suit les réglages de publication choisis dans App Store Connect.

La signature manuelle exige un profil App Store Connect valide associé au certificat importé. La clé API d'équipe reste nécessaire pour l'envoi. L'échec de signature ou de téléversement apparaît dans les journaux du workflow ; les secrets et certificats ne doivent pas y être copiés.
