# Guide de Test - Application Shekinah Live

## 🧪 Test de la Détection de Live

### 1. **Test avec Live Actuel**
✅ **Scénario** : Un culte est actuellement en direct
📱 **Actions** :
1. Lancer l'application
2. Naviguer vers l'onglet "Live"
3. Observer le badge de statut

🎯 **Résultats attendus** :
- Badge rouge 🔴 "EN DIRECT" animé
- WebView affiche `https://shekinahgospel.org/live`
- Contenu du stream visible et fonctionnel
- Pas de message "Aucun live en cours"

### 2. **Test sans Live**
✅ **Scénario** : Aucun culte en direct
📱 **Actions** :
1. Lancer l'application
2. Naviguer vers l'onglet "Live"
3. Observer le badge de statut

🎯 **Résultats attendus** :
- Badge gris ⚪ "HORS LIGNE"
- Message "Aucun live en cours pour le moment"
- Affichage des horaires :
  - Dimanche : 09h00
  - Mercredi : 18h00
  - Jeudi : 18h00
- Bouton "Vérifier à nouveau" fonctionnel

## 🧪 Test des Archives

### 1. **Accès aux Archives**
📱 **Actions** :
1. Lancer l'application
2. Naviguer vers l'onglet "Archives"
3. Attendre le chargement

🎯 **Résultats attendus** :
- Loader animé pendant le chargement
- WebView affiche `https://shekinahgospel.org/archives`
- Contenu des archives visible
- Bouton de rafraîchissement fonctionnel

## 🧪 Test de la Navigation

### 1. **Navigation entre onglets**
📱 **Actions** :
1. Tester chaque onglet (Live, Archives, À Propos)
2. Vérifier que le contenu change correctement
3. Tester l'état actif des onglets

🎯 **Résultats attendus** :
- Navigation fluide entre les 3 sections
- Onglet actif mis en surbrillance (or)
- Contenu préservé lors du changement d'onglet
- Pas de crash ou freeze

## 🧪 Test de À Propos

### 1. **Page À Propos**
📱 **Actions** :
1. Naviguer vers l'onglet "À Propos"
2. Vérifier les informations de l'application
3. Tester les liens de contact (email et téléphone)
4. Vérifier le design et la mise en page

🎯 **Résultats attendus** :
- Informations sur le développeur affichées (EL-Jean Malonga Kisangi)
- Objectif de l'application clairement expliqué
- Email jeanmalonga08@gmail.com cliquable et fonctionnel
- Téléphone +243 846 656 910 cliquable et fonctionnel
- Design moderne avec logo et version 1.0.0
- Footer avec copyright Shekinah Gospel

## 🧪 Test de Performance

### 1. **Temps de chargement**
⏱️ **Métriques** :
- Splash screen : < 3 secondes
- Chargement live : < 5 secondes
- Chargement archives : < 5 secondes

### 2. **Utilisation mémoire**
📊 **Surveiller** :
- Pas de fuite mémoire
- Performance stable après plusieurs navigations

## 🐛 Gestion des Erreurs

### 1. **Test hors ligne**
📱 **Actions** :
1. Désactiver la connexion internet
2. Lancer l'application
3. Observer le comportement

🎯 **Résultats attendus** :
- Message d'erreur réseau clair
- Bouton de retry fonctionnel
- Pas de crash

### 2. **Test timeout**
📱 **Actions** :
1. Lancer avec connexion lente
2. Observer la gestion du timeout

🎯 **Résultats attendus** :
- Timeout géré élégamment
- Message d'erreur approprié
- Possibilité de réessayer

## 📱 Tests Multi-plateformes

### Android
- [ ] Test sur différents tailles d'écran
- [ ] Test sur différentes versions d'Android
- [ ] Vérifier les permissions

### iOS
- [ ] Test sur iPhone et iPad
- [ ] Test sur différentes versions d'iOS
- [ ] Vérifier l'intégration système

## ✅ Checklist de Validation

- [ ] Live détecté correctement quand actif
- [ ] Hors ligne détecté correctement
- [ ] Archives accessibles et fonctionnelles
- [ ] Navigation fluide entre les onglets
- [ ] À Propos et liens externes fonctionnels
- [ ] Gestion des erreurs réseau robuste
- [ ] Performance acceptable
- [ ] Interface responsive sur toutes tailles
- [ ] Nom et icône corrects
- [ ] Pas de crash majeur

## 🚀 Rapport de Test

**Date** : [Date du test]
**Testeur** : [Nom]
**Appareil** : [Modèle et OS]
**Version** : [Version de l'app]

### Résultats
✅ **Fonctionnel** : [Liste des fonctionnalités validées]
⚠️ **Problèmes** : [Liste des problèmes rencontrés]
🐛 **Bugs** : [Liste des bugs identifiés]

### Recommandations
- [ ] Suggestions d'amélioration
- [ ] Corrections nécessaires
- [ ] Optimisations à envisager

---

*Ce guide garantit une validation complète de l'application Shekinah Live*
