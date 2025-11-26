# ☑️ DEPLOYMENT INTERACTIVE CHECKLIST

## 🟥 PHASE 1: CODE FIXES (BLOCKER - À FAIRE D'ABORD)

```
⬜ Étape 1.1: Corriger les erreurs de compilation
   └─ Commande: dart fix --apply
   └─ Durée: 5 minutes
   └─ Checklist:
      ☐ Ouvrir terminal
      ☐ cd c:\Users\bmd-tech\Desktop\Boutique\mobile
      ☐ Exécuter: dart fix --apply
      ☐ Vérifier: flutter analyze (doit être clean)

⬜ Étape 1.2: Valider la compilation
   └─ Commandes:
      flutter clean
      flutter pub get
      flutter build apk --debug
   └─ Résultat attendu: ✅ BUILD SUCCESS

⬜ Étape 1.3: Build production test
   └─ Commande: flutter build appbundle --release
   └─ Résultat attendu: ✅ BUILD COMPLETE (build/app/outputs/bundle/release/)
```

**Status**: ⏳ À FAIRE IMMÉDIATEMENT

---

## 🟨 PHASE 2: CONFIGURATION ANDROID

```
⬜ Étape 2.1: Changer package name
   └─ Fichier: android/app/build.gradle.kts
   └─ Ligne: 27
   └─ Change: applicationId = "com.example.boutique_mobile"
   └─ À:      applicationId = "com.yourcompany.boutique"
   └─ Notes:
      ☐ Remplacer "yourcompany" par votre company name
      ☐ Exemple: "com.mybusiness.boutique" ou "com.john.boutique"
      ☐ Doit être unique et permanent
      ☐ Pas de changement après publication!

⬜ Étape 2.2: Générer release signing key
   └─ Commandes (à copier-coller dans PowerShell):
      
      # Générer le keystore
      keytool -genkey -v -keystore c:\Users\bmd-tech\Desktop\boutique-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias boutique_key
      
      # Quand demandé, entrez:
      Password: [PASSWORD À MÉMORISER]
      Firstname: Your Name
      Last name: Your Last Name
      Organization: Your Company
      City: Your City
      State: Your State
      Country Code: US (ou votre pays)
      
   └─ Fichier créé: c:\Users\bmd-tech\Desktop\boutique-release-key.jks
   └─ Status: ☐ Gardez ce fichier en SÉCURITÉ
              ☐ NE LE PARTAGEZ PAS
              ☐ BACKUP régulièrement

⬜ Étape 2.3: Créer key.properties
   └─ Fichier: android/key.properties
   └─ Contenu:
      storePassword=PASSWORD_UTILISÉ_CI_DESSUS
      keyPassword=PASSWORD_UTILISÉ_CI_DESSUS
      keyAlias=boutique_key
      storeFile=../../boutique-release-key.jks
   └─ Status: ☐ Créé et sauvegardé

⬜ Étape 2.4: Configurer build.gradle.kts
   └─ Fichier: android/app/build.gradle.kts
   └─ Action: Remplacer le contenu (voir ACTION_PLAN_DEPLOYMENT.md)
   └─ Résultat: Release signing configuré
```

**Status**: ⏳ À FAIRE AVANT BUILD RELEASE

---

## 🟨 PHASE 3: CONFIGURATION iOS

```
⬜ Étape 3.1: Changer Bundle ID
   └─ Fichier: ios/Runner.xcodeproj/project.pbxproj
   └─ OU utiliser Xcode GUI (plus facile)
   └─ Action: Changer "com.example.boutique_mobile" 
              en "com.yourcompany.boutique"
   └─ Status: ☐ Changé et testé

⬜ Étape 3.2: Code Signing Setup (Requis sur Mac)
   └─ Nécessite: Apple Developer Account ($99/an)
   └─ Étapes:
      ☐ Créer certificate dans Apple Developer
      ☐ Créer provisioning profile
      ☐ Télécharger et installer dans Xcode
      ☐ Configurer bundle ID dans Xcode
   └─ Note: Cette étape ne peut se faire que sur Mac

⬜ Étape 3.3: Build iOS release (Mac uniquement)
   └─ Commande: flutter build ios --release
   └─ Résultat: ✅ Archive créé pour upload
```

**Status**: ⏳ À FAIRE SUR MAC (si vous en avez)

---

## 🟩 PHASE 4: TESTING & QA

```
⬜ Étape 4.1: Test sur device Android réel
   └─ Prérequis: Device Android + cable USB
   └─ Commandes:
      flutter run --release
   └─ Tester absolument:
      ☐ Login avec PIN
      ☐ Créer une dette
      ☐ Ajouter un paiement
      ☐ Export PDF
      ☐ Offline mode (désactiver WiFi)
      ☐ Dark/Light theme toggle
      ☐ Édition client
      ☐ Statistics page
      ☐ Team screen (si applicable)

⬜ Étape 4.2: Test sur device iOS réel (Mac uniquement)
   └─ Similaire à Android
   └─ Tous les workflows doivent fonctionner

⬜ Étape 4.3: QA Final
   └─ ☐ Zéro crash
   └─ ☐ Zéro warnings en prod
   └─ ☐ Tous workflows testés
   └─ ☐ Performance acceptable
   └─ ☐ Offline sync fonctionne
```

**Status**: ⏳ À FAIRE JOUR 2

---

## 🟦 PHASE 5: PRÉPARATION STORES

### 5.A SCREENSHOTS

```
⬜ Android Screenshots
   └─ Format: 1080 x 1920 px (9:16 aspect ratio)
   └─ Nombre: 2-8 screenshots
   └─ À capturer:
      ☐ Login screen (PIN)
      ☐ Main dashboard (dettes)
      ☐ Loan view (emprunts)
      ☐ Add debt flow
      ☐ Payment screen
      ☐ Statistics
      ☐ (Optionnel) Team management
   └─ Outils: iOS simulator ou device, screenshot tool
   └─ Format: PNG

⬜ iOS Screenshots
   └─ Format: 1170 x 2532 px (max 5 par orientation)
   └─ Même captures qu'Android
   └─ Outils: Xcode simulator ou device, screenshot tool
   └─ Format: PNG

⬜ Feature Graphic (Google Play uniquement)
   └─ Format: 1024 x 500 px
   └─ Type: Bannière visuelle de l'app
   └─ Contenu: Logo + tagline + design
   └─ Format: PNG ou JPG
```

**Status**: ⏳ À FAIRE JOUR 2-3

### 5.B ASSETS VISUELS

```
⬜ App Icon
   └─ Taille: 1024 x 1024 px (minimum)
   └─ Format: PNG avec transparency
   └─ Notes:
      ☐ Pas de transparency sur bord (safe area)
      ☐ Carré simple, pas de surcharge
      ☐ Doit être reconnaissable petit
   └─ Test: Testez à différentes tailles

⬜ Vérifier icon actuel
   └─ Android: android/app/src/main/res/mipmap-*/ic_launcher.png
   └─ iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/
   └─ Status: À vérifier si existants sont OK
```

**Status**: ⏳ À FAIRE JOUR 2

### 5.C METADATA

```
⬜ App Name
   └─ Suggestion: "Boutique" (simple)
   └─ OU: "Boutique - Debt Manager"
   └─ OU: Autre selon votre branding

⬜ Short Description (80 caractères)
   └─ Exemple: "Manage debts and loans easily with Boutique"

⬜ Full Description (4000 caractères)
   └─ Inclure:
      ☐ Ce que fait l'app
      ☐ Features principales
      ☐ Avantages pour user
      ☐ Comment ça marche
      ☐ Exemple d'usage

⬜ Privacy Policy URL
   └─ REQUIS par Google & Apple
   └─ À créer: https://yourwebsite.com/privacy
   └─ Minimal:
      - What data is collected
      - How it's stored
      - How it's used
      - User rights
   └─ Outils gratuits: privacypolicygenerator.info

⬜ Support Email
   └─ Adresse email de support
   └─ Utilisée par stores pour contacter vous
   └─ Répondez rapidement aux questions!

⬜ Website (Optionnel)
   └─ Si vous avez un site officiel

⬜ Category
   └─ Google Play: Finance, Business
   └─ App Store: Finance, Business
```

**Status**: ⏳ À FAIRE JOUR 3

### 5.D LEGAL

```
⬜ Créer Privacy Policy
   └─ Si aucune: https://www.privacypolicygenerator.info
   └─ Uploadez sur: https://yourwebsite.com/privacy
   └─ SANS: Vous bloquez publication!

⬜ Terms & Conditions (Optionnel mais recommandé)
   └─ Similar à Privacy Policy

⬜ Content Rating (Google Play)
   └─ Questionnaire: 5-10 minutes
   └─ Questions:
      ☐ Violence?
      ☐ Sexual content?
      ☐ Language?
      ☐ Etc.
   └─ Pour vous: PEGI 3 (aucune restriction)
```

**Status**: ⏳ À FAIRE JOUR 3

---

## 🟪 PHASE 6: CRÉER ACCOUNTS STORES

```
⬜ Google Play Developer Account
   └─ Coût: $25 one-time
   └─ URL: https://play.google.com/console
   └─ Process:
      ☐ Sign in avec Google account
      ☐ Accepter Developer agreement
      ☐ Payer $25
      ☐ Account créé!
   └─ Durée: 10 minutes

⬜ Apple Developer Account
   └─ Coût: $99/year
   └─ URL: https://developer.apple.com/account
   └─ Process:
      ☐ Sign in avec Apple ID
      ☐ Accepter agreement
      ☐ Payer $99
      ☐ Account créé!
   └─ Durée: 15 minutes
   └─ Note: Nécessaire pour iOS build & upload

⬜ App Store Connect
   └─ URL: https://appstoreconnect.apple.com
   └─ Process:
      ☐ Sign in avec Apple ID
      ☐ Aller à "Apps"
      ☐ "+" → "New App"
      ☐ Remplir basic info
      ☐ App créé!
   └─ Durée: 10 minutes
```

**Status**: ⏳ À FAIRE JOUR 3

---

## 🟫 PHASE 7: UPLOAD STORES

### Google Play

```
⬜ Créer release dans Google Play Console
   └─ Steps:
      ☐ Google Play Console → Your App
      ☐ "Release" → "Create new release"
      ☐ "Production"
      ☐ Upload AAB file (build/app/outputs/bundle/release/)
      ☐ Review content rating
      ☐ Set privacy policy URL
      ☐ Add screenshots
      ☐ Add app description
      ☐ Review and submit!

⬜ Google Play Submission
   └─ Attendre: ~24 heures
   └─ Notification: Email quand approved
   └─ Status: Check dans console

⬜ Monitoring après publication
   └─ Monitor crashes
   └─ Monitor ratings
   └─ Monitor user feedback
```

### App Store

```
⬜ Upload IPA via Xcode ou Transporter
   └─ Prérequis: Mac + iOS build
   └─ Via Xcode:
      ☐ Product → Archive
      ☐ Distribute App
      ☐ Select "TestFlight and the App Store"
      ☐ Upload
   └─ Durée: 5-10 minutes

⬜ App Store Connect Submission
   └─ Aller à: App Store Connect → Apps → Your App
   └─ Build: Select the uploaded build
   └─ App Information: Remplir (name, description, etc)
   └─ Screenshots: Upload screenshots
   └─ Privacy Policy: Add URL
   └─ Submit for Review
   └─ Attendre: 24-48 heures

⬜ Apple Review
   └─ Possible rejections:
      ☐ Missing privacy policy → CRITICAL
      ☐ Broken links
      ☐ Crashes on device
      ☐ Non-compliant UI
   └─ Si rejet: Fix et re-submit
```

**Status**: ⏳ À FAIRE JOUR 4

---

## 🎯 FINAL CHECKLIST AVANT SUBMIT

```
CODE:
☐ flutter analyze retourne ZÉRO erreur
☐ flutter build appbundle --release SUCCESS
☐ (iOS) flutter build ios --release SUCCESS
☐ Testé sur device réel
☐ Zéro crash

CONFIGURATION:
☐ Package name changé
☐ Bundle ID changé
☐ Release signing configuré (Android)
☐ Code signing configuré (iOS)
☐ Version: 1.0.0
☐ Build number: 1

ASSETS:
☐ App icon 1024x1024 présent
☐ Screenshots capturés (2-5 min)
☐ Feature graphic 1024x500 (Google only)

METADATA:
☐ App name décidé
☐ Description écrite (short + long)
☐ Privacy policy URL créée
☐ Support email configuré
☐ Category sélectionnée

LEGAL:
☐ Privacy policy accessible
☐ Terms & conditions (if any)
☐ Content rating completed (Google)

ACCOUNTS:
☐ Google Play Developer Account créé
☐ Apple Developer Account créé (si iOS)
☐ App Store Connect setup (si iOS)

FINAL:
☐ AAB/IPA build créé
☐ Screenshots prêts
☐ Metadata complet
☐ Prêt pour upload!
```

---

## 🎉 SUCCESS CRITERIA

Si TOUS les items ci-dessus sont cochés:

✅ **VOUS ÊTES PRÊT POUR PUBLICATION!**

Prochaines étapes:
1. Upload sur Google Play Console
2. Upload sur App Store Connect
3. Attendre review
4. **PUBLICATION LIVE!** 🚀

---

## 📞 HELP DESK

**Si vous bloquez:**
1. Vérifiez les logs: `flutter build appbundle --verbose`
2. Lisez les 4 documents créés
3. Consultez documentation officielle: flutter.dev

Bon courage! 💪
