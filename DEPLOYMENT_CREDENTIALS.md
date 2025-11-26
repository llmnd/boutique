# DEPLOYMENT CREDENTIALS & SECURITY - KEEP THIS SECURE

⚠️ **CRITICAL: This file contains sensitive information. Keep it secure and never commit to version control.**

---

## 📦 Release Signing Certificate

### Keystore Details
- **File:** `c:\Users\bmd-tech\Desktop\boutique-release.jks`
- **Keystore Password:** `BoutiqueMobile2025!`
- **Key Alias:** `boutique_key`
- **Key Password:** `BoutiqueMobile2025!`
- **Validity:** 10,000 days (until ~2052)
- **Algorithm:** RSA 2048-bit
- **Certificate CN:** Boutique Mobile

### ⚠️ CRITICAL BACKUP INSTRUCTIONS

**This keystore is PERMANENT and CANNOT be regenerated:**
1. **Make 3 backups** of `boutique-release.jks`
   - Store one locally
   - Store one on external drive
   - Store one in cloud (Google Drive, OneDrive, etc.)

2. **Never commit to Git** - already in .gitignore

3. **Store password securely:**
   - Keep in secure password manager
   - Do NOT hardcode in files
   - Currently stored in: `android/key.properties`

4. **Losing this key means:**
   - Cannot update app on Google Play
   - Cannot update app on App Store
   - Must release as completely new app
   - Lose all user reviews and ratings

---

## 🔑 Android Configuration

### Package Name
- **Official:** `com.boutique.mobile`
- **Previous:** `com.example.boutique_mobile` (placeholder)
- **Status:** ✅ PERMANENT after first store submission
- **Cannot be changed** once published

### Build Configuration
**File:** `android/app/build.gradle.kts`
- Namespace: `com.boutique.mobile`
- applicationId: `com.boutique.mobile`
- compileSdk: 34
- minSdk: 21
- targetSdk: 34

### Signing Configuration
**File:** `android/key.properties`
```properties
storePassword=BoutiqueMobile2025!
keyPassword=BoutiqueMobile2025!
keyAlias=boutique_key
storeFile=../../boutique-release.jks
```

---

## 🍎 App Store Accounts

### Google Play Console
- **Email:** [ADD YOUR GOOGLE ACCOUNT]
- **Package ID:** `com.boutique.mobile`
- **Status:** [PENDING - Not yet created]
- **Store Listing:** [PENDING]

### Apple App Store Connect
- **Apple ID:** [ADD YOUR APPLE ID]
- **Bundle ID:** [PENDING - Will be `com.boutique.mobile`]
- **Status:** [PENDING - Not yet created]
- **App Review:** [PENDING]

---

## 📋 Deployment Checklist

### Pre-Build
- [ ] Java/JDK installed and working
- [ ] Flutter SDK updated: `flutter upgrade`
- [ ] Android SDK tools updated: `flutter doctor`
- [ ] Keystore file exists: `boutique-release.jks`
- [ ] key.properties file exists
- [ ] build.gradle.kts updated with release signing

### Build Commands
```bash
# Android Release Build
cd c:\Users\bmd-tech\Desktop\Boutique
flutter clean
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab

# iOS Release Build (Mac only)
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

### Post-Build Validation
- [ ] AAB file generated successfully (40-50MB typical)
- [ ] IPA file generated successfully (if Mac available)
- [ ] No build errors or warnings
- [ ] Signed with release certificate
- [ ] Can install on device without errors

### Store Submission
- [ ] Privacy Policy URL deployed and tested
- [ ] Screenshots captured (2-5 per platform)
- [ ] Metadata completed (descriptions, category, etc.)
- [ ] App rating content questionnaire filled
- [ ] Test account prepared
- [ ] Launch date set

---

## 🚀 Build Commands Reference

### Quick Reference

**Full Release Build (Recommended)**
```bash
cd c:\Users\bmd-tech\Desktop\Boutique\mobile
flutter clean
flutter pub get
flutter build appbundle --release
```

**Android Debug Build (For Testing)**
```bash
flutter build apk --debug
```

**Check Build Status**
```bash
flutter build --help
flutter doctor -v
```

---

## 📧 Support Contacts

- **Privacy Policy Contact:** `privacy@boutique-app.com`
- **Support Email:** `support@boutique-app.com`
- **Developer Email:** [ADD YOUR EMAIL]

---

## 🔐 Security Reminders

✅ DO:
- Keep keystore backed up in secure location
- Use strong, unique password for keystores
- Use password manager for credentials
- Keep build environment secure
- Update Android SDK regularly
- Monitor app reviews after launch

❌ DON'T:
- Commit keystore to Git
- Share keystore with team members
- Use placeholder package names in publication
- Reuse keystore password elsewhere
- Publish debug APKs/AABs
- Ignore security warnings

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-20 | Initial keystore generation and configuration |
| 1.0 | 2025-01-20 | Package name changed to com.boutique.mobile |
| 1.0 | 2025-01-20 | Release signing configured in build.gradle.kts |

---

## ⏰ Important Dates

- **Keystore Generated:** January 20, 2025
- **Package Name Locked:** Upon first store submission
- **Certificate Valid Until:** ~January 20, 2052
- **Planned Store Submission:** January 22-23, 2025

---

## 🎯 Next Steps

1. **Deploy Privacy Policy** (NEXT)
   - Choose hosting (GitHub Pages recommended)
   - Upload privacy-policy.html
   - Get permanent URL
   - Estimated time: 15-20 minutes

2. **Prepare Screenshots** 
   - Capture 2-5 per platform
   - Minimum size: 1080x1920 (Android), 1170x2532 (iOS)
   - Estimated time: 2-3 hours

3. **Complete Metadata**
   - App name, descriptions, category
   - Support email, website
   - Estimated time: 1-2 hours

4. **Build Release AAB/IPA**
   - Run build commands
   - Validate output files
   - Estimated time: 10-15 minutes

5. **Submit to Stores**
   - Create store accounts (if needed)
   - Upload AAB/IPA
   - Add screenshots and metadata
   - Submit for review
   - Estimated time: 30-60 minutes

---

**Last Updated:** January 20, 2025
**Status:** Keystore configured, Privacy Policy created, ready for deployment

