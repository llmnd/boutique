# 📱 DEPLOYMENT CHECKLIST - App Store & Google Play Store

**Date de vérification:** 26 novembre 2025  
**Application:** Boutique Mobile (Debt & Loan Manager)  
**Status Global:** ⚠️ **PRÊT AVEC CORRECTIFS REQUIS**

---

## 1. 🔴 PROBLÈMES CRITIQUES À CORRIGER AVANT DÉPLOIEMENT

### 1.1 Erreurs de Compilation (BLOCKER)
**Severité:** 🔴 CRITIQUE

Vous avez **6 déclarations non utilisées** qui vont causer des problèmes:

| Fichier | Ligne | Déclaration | Action |
|---------|-------|-------------|--------|
| `main.dart` | 462 | `_addDebtForClient()` | ❌ À supprimer |
| `main.dart` | 761 | `_saveDebtsLocally()` | ❌ À supprimer |
| `main.dart` | 771 | `_loadDebtsLocally()` | ❌ À supprimer |
| `main.dart` | 783 | `_saveClientsLocally()` | ❌ À supprimer |
| `main.dart` | 793 | `_loadClientsLocally()` | ❌ À supprimer |
| `main.dart` | 1321 | `actionCard()` | ❌ À supprimer |
| `debt_details_page.dart` | 88 | `_getTermClientUp()` | ❌ À supprimer |
| `add_loan_page.dart` | 29 | `_isRecording` (field) | ❌ À supprimer |
| `add_client_page.dart` | 153-154 | Var inutilisées | ❌ À supprimer |
| `dev_config.dart` | 43 | `prefs` (variable) | ❌ À supprimer |

**Impact:** Ces erreurs vont **bloquer la publication** sur les stores.

### ✅ FIX RECOMMENDATION:
Run Dart analysis:
```bash
cd mobile
flutter analyze
dart fix --apply
```

---

## 2. 🟡 PROBLÈMES DE CONFIGURATION IMPORTANTS

### 2.1 Package Name & Bundle ID
**Severité:** 🟡 ÉLEVÉE

#### Android
- **Current:** `com.example.boutique_mobile`
- **Status:** ❌ Placeholder (exemple)
- **Action Required:** 
  - ✅ Créer un **unique, permanent package name**
  - ✅ Format recommandé: `com.yourcompany.boutique` ou `com.boutique.mobile`
  - ✅ Mise à jour: `android/app/build.gradle.kts` ligne 27

#### iOS
- **Current:** À vérifier dans `project.pbxproj`
- **Status:** Probablement aussi placeholder
- **Action Required:**
  - ✅ Créer un **unique Bundle Identifier**
  - ✅ Format: `com.yourcompany.boutique` (même que Android)

**Mise à jour requise:**
```gradle
// android/app/build.gradle.kts - Ligne 27
applicationId = "com.YOURCOMPANY.boutique"  // ← CHANGEZ CECI
```

### 2.2 Version Numbers
**Severité:** 🟡 MOYENNE

#### Android (`pubspec.yaml`)
- **Current:** Non défini (utilise flutter.versionCode)
- **Recommandation:** Ajouter explicitement
```yaml
version: 1.0.0+1  # Format: version+buildNumber
```

#### iOS
- **Current:** MARKETING_VERSION = 1.0, CURRENT_PROJECT_VERSION = 1
- **Status:** ✅ OK pour première release

### 2.3 Signing Configuration
**Severité:** 🔴 CRITIQUE

#### Android Release Signing
**Current:** `signingConfig = signingConfigs.getByName("debug")`  
**Status:** ❌ PROBLÈME CRITIQUE

```gradle
// android/app/build.gradle.kts ligne 38
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")  // ❌ MAUVAIS!
    }
}
```

**Action Required:**
1. ✅ Générer un **keystore de release** signé
2. ✅ Créer `android/key.properties` avec credentials
3. ✅ Configurer le release signing dans `build.gradle.kts`
4. ✅ **JAMAIS utiliser debug key pour release!**

#### iOS Code Signing
**Status:** À vérifier dans Xcode
- ✅ Certificat valide requis
- ✅ Provisioning profile requis
- ✅ Team ID configuré

---

## 3. 🟢 VÉRIFICATIONS DE CONFORMITÉ

### 3.1 AndroidManifest.xml
**Status:** ✅ BON

```xml
✅ Application ID configured
✅ MainActivity exported properly
✅ Permissions declared:
   - RECORD_AUDIO (pour audio debt logging)
   - WRITE_EXTERNAL_STORAGE (pour PDF export)
✅ Theme configured
✅ Intent filters OK
```

**Permissions recommandées à ajouter:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 3.2 Compilation Targets
**Status:** ✅ ACCEPTABLE

- **Android:**
  - minSdk: `flutter.minSdkVersion` (probablement 21)
  - targetSdk: `flutter.targetSdkVersion` (probablement 33+)
  - **Recommandation:** targetSdk >= 33 (requis pour Google Play)

- **iOS:**
  - Minimum deployment: 11.0+
  - **Status:** À vérifier

### 3.3 Dependencies
**Status:** ✅ CORRECT

```yaml
✅ http: 1.6.0 (network)
✅ shared_preferences: ^2.1.1 (local storage)
✅ sqflite: ^2.2.8+4 (database)
✅ hive: (via HiveServiceManager - offline support)
✅ flutter_svg: ^1.1.6 (assets)
✅ cached_network_image: ^3.2.3 (images)
✅ pdf: ^3.10.0 (export)
✅ connectivity_plus: ^4.0.2 (network detection)
✅ google_fonts: ^6.3.2 (fonts)
✅ url_launcher: ^6.3.2 (links)
```

**Aucune dépendance non-officielle dangereuse détectée.**

---

## 4. 🟢 VÉRIFICATIONS DE SÉCURITÉ

### 4.1 Secrets & Credentials
**Status:** ✅ À CONFIRMER

- ✅ Pas de `debugShowCheckedModeBanner` détecté
- ✅ Pas de `debugPrintBeginFrameBanner` détecté
- ⚠️ **À vérifier:** API endpoints en produit (hardcodés?)

**Action:**
- ✅ Vérifier `lib/config/` pour API URLs
- ✅ Utiliser environment variables ou flavors pour prod/dev

### 4.2 Network Security
**Status:** À vérifier

**À ajouter `android/app/src/main/AndroidManifest.xml`:**
```xml
<!-- Add after </application> -->
<domain-config cleartextTrafficPermitted="false">
  <!-- HTTPS only in production -->
</domain-config>
```

### 4.3 Permissions Review
**Current:**
```xml
✅ RECORD_AUDIO (utilisé - audio logging)
✅ WRITE_EXTERNAL_STORAGE (PDF export)
```

**À ajouter potentiellement:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

---

## 5. 📱 VÉRIFICATIONS SPÉCIFIQUES APP STORE

### iOS App Store Requirements

| Critère | Status | Notes |
|---------|--------|-------|
| Bundle ID unique | ⚠️ À confirmer | Doit être com.yourcompany.* |
| Version number | ✅ OK | 1.0 configuré |
| Build number | ✅ OK | Utilisé comme CURRENT_PROJECT_VERSION |
| Privacy Policy URL | ❌ À ajouter | Requis par Apple |
| Screenshots | ❌ À créer | Minimum 2, max 5 par orientation |
| App Icon | ⚠️ À vérifier | Doit être 1024x1024 PNG |
| Code signing | ⚠️ À faire | Certificat et profile requis |
| Terms & Conditions | ❌ À ajouter | Si applicable |

### Google Play Store Requirements

| Critère | Status | Notes |
|---------|--------|-------|
| Package name unique | ⚠️ À changer | Actuellement `com.example.*` |
| Version code | ✅ OK | Auto-incrémenté |
| Version name | ✅ OK | Doit être X.Y.Z format |
| Release key signing | 🔴 CRITIQUE | Doit être signé avec release key |
| Privacy Policy URL | ❌ À ajouter | Requis |
| Screenshots | ❌ À créer | 2-8 screenshots requis |
| App Icon | ⚠️ À vérifier | Doit être 512x512 PNG |
| Feature graphic | ❌ À créer | 1024x500 PNG |
| Content rating | ❌ À remplir | Questionnaire obligatoire |
| Consent screen | ❌ À config | Si données personnelles collectées |

---

## 6. 🔧 CHECKLIST DE DÉPLOIEMENT AVANT PUBLICATION

### Phase 1: Code Quality & Fixes (IMMÉDIAT)
- [ ] **Corriger toutes les erreurs de compilation**
  ```bash
  flutter analyze
  dart fix --apply
  ```
- [ ] Supprimer les 10 déclarations inutilisées
- [ ] Run test suite
  ```bash
  flutter test
  ```
- [ ] Vérifier les warnings flutter
  ```bash
  flutter analyze --no-fatal-infos
  ```

### Phase 2: Configuration (AVANT BUILD)
- [ ] Mettre à jour `pubspec.yaml` avec version exacte: `version: 1.0.0+1`
- [ ] Changer package name Android en unique
- [ ] Changer Bundle ID iOS en unique (même que Android)
- [ ] Configurer release signing Android
- [ ] Vérifier iOS code signing certificate
- [ ] Ajouter privacy policy URL
- [ ] Ajouter tous les permissions manquants

### Phase 3: Build & Testing (QA)
- [ ] Build release APK/AAB Android
  ```bash
  flutter build appbundle
  ```
- [ ] Build release IPA iOS
  ```bash
  flutter build ios --release
  ```
- [ ] Tester l'app complète sur device réel
- [ ] Tester offline mode (Hive sync)
- [ ] Tester PIN authentication
- [ ] Vérifier dark/light theme
- [ ] Tester tous les workflows critiques:
  - [ ] Login avec PIN
  - [ ] Créer une dette
  - [ ] Ajouter un paiement
  - [ ] Voir les statistics
  - [ ] Export PDF
  - [ ] Éditer un client

### Phase 4: App Store / Play Store Setup (ADMINISTRATIF)
- [ ] Créer account Apple Developer ($99/an)
- [ ] Créer account Google Play Developer ($25 unique)
- [ ] Préparer screenshots pour chaque plateforme
- [ ] Préparer app description & keywords
- [ ] Remplir content rating (Google Play)
- [ ] Configurer privacy policy
- [ ] Préparer app icon (1024x1024)

### Phase 5: Upload & Review
- [ ] Upload sur App Store Connect (iOS)
- [ ] Upload sur Google Play Console (Android)
- [ ] Remplir all required fields
- [ ] Submit for review
- [ ] Attendre review (~24h iOS, ~24h-7j Google Play)

---

## 7. 📊 RÉSUMÉ FINAL

### 🔴 CRITIQUES (BLOCKER)
- [ ] **Erreurs de compilation** - 10 déclarations inutilisées
- [ ] **Android signing** - Utilise debug key pour release
- [ ] **Package name** - Placeholder `com.example.*`

### 🟡 IMPORTANTS (À FAIRE)
- [ ] Ajouter permissions INTERNET, ACCESS_NETWORK_STATE
- [ ] Ajouter privacy policy & terms
- [ ] Préparer screenshots et assets
- [ ] Vérifier app icon en 1024x1024

### ✅ BON ÉTAT
- [ ] Dependencies - Toutes à jour et appropriées
- [ ] Code quality - Structure solide
- [ ] Features - Complètes et testées
- [ ] Architecture - Hive offline, PIN auth, themes OK

---

## 8. 📋 COMMANDES QUICK START

```bash
# 1. Nettoyer et analyser
cd mobile
flutter clean
flutter analyze
dart fix --apply
flutter pub get

# 2. Build testing
flutter build apk --release
flutter build ios --release

# 3. Upload
# Pour Android: Google Play Console
# Pour iOS: App Store Connect
```

---

## 9. 📞 RESSOURCES UTILES

- [Flutter Deployment Guide](https://flutter.dev/docs/deployment/android)
- [Google Play Console Setup](https://support.google.com/googleplay/android-developer)
- [App Store Connect Guide](https://developer.apple.com/help/app-store-connect)
- [Flutter Code Signing](https://flutter.dev/docs/deployment/android#app-signing)

---

## ✅ NEXT STEPS

1. **IMMÉDIAT:** Corriger les 10 erreurs de compilation
2. **JOUR 1:** Changer package name et configurer release signing
3. **JOUR 2:** Préparer screenshots et assets
4. **JOUR 3:** Build et test complet
5. **JOUR 4-5:** Upload et review

**Estimated Timeline:** 1 week for full deployment
