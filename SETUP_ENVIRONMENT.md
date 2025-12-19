# 🔧 Configuration d'Environnement - Guide Complet

## 📋 Résumé Rapide

| Dossier | Fichier | Nécessaire? | Contenu |
|---------|---------|-----------|---------|
| `/` | `.env` | ❌ Non utilisé | Ignoré |
| `/` | `.env.example` | 📖 Référence | Documentation |
| `/backend` | `.env` | ✅ OUI | DATABASE_URL, API_BASE_URL |
| `/mobile` | `.env` | ❌ Non utilisé | Pas nécessaire (hardcoded) |
| `/public` | `.env` | ✅ OUI | API_BASE_URL (pour web) |

---

## 🎯 Pour un CLONE du projet

Si quelqu'un clone le repo, voici exactement ce qu'il doit faire:

### 1️⃣ Backend (.env)

**Placer à**: `./backend/.env`

```dotenv
# Base de données PostgreSQL (Neon)
DATABASE_URL=postgresql://user:password@host/database?sslmode=require

# URL de l'API (pointant vers votre serveur déployé)
API_BASE_URL=https://your-backend-url.com/api
```

**Où obtenir?**
- `DATABASE_URL`: De Neon.tech (tu crées une base)
- `API_BASE_URL`: De Koyeb/Render/Vercel backend

### 2️⃣ Frontend Web (.env)

**Placer à**: `./public/.env`

```dotenv
# URL de l'API (même que le backend)
API_BASE_URL=https://your-backend-url.com/api
```

**Note**: Ce `.env` est copié dans le build web

### 3️⃣ Mobile (PAS NÉCESSAIRE)

**Dossier**: `./mobile/`
**Fichier .env**: ❌ N'existe pas et n'est pas nécessaire

Pourquoi? L'API URL est **hardcodée** dans le code:

```dart
// mobile/lib/config/api_config.dart
static String getBaseUrl() {
  if (kIsWeb) {
    return 'https://vocal-fernandina-llmndg-0b759290.koyeb.app/api';
  }
  // Fallback hardcoded pour Android
  return dotenv.env['API_BASE_URL'] ?? 'https://vocal-fernandina-llmndg-0b759290.koyeb.app/api';
}
```

**Pour changer l'URL mobile**, il faut éditer directement ce fichier Dart.

---

## 📱 Configuration pour le Fichier .env.example

**Location**: `./` (racine du repo)

```dotenv
# ================================
# Configuration Environnements
# ================================

# API Configuration
ENVIRONMENT=production
API_HOST=https://api.boutique.example.com/api

# Android Keystore (pour compilation)
KEYSTORE_PATH=~/boutique-key.jks
KEYSTORE_PASSWORD=your_keystore_password
KEY_PASSWORD=your_key_password
KEY_ALIAS=boutique_key

# App Metadata
APP_NAME=Boutique
APP_VERSION=1.0.0
APP_BUILD_NUMBER=1
APP_PACKAGE_NAME=com.mnllmnd.boutique
```

**Usage**: C'est une **documentation de référence** pour le `.gitignore`. À adapter selon tes besoins.

---

## 🚀 Checklist de Déploiement

```bash
# 1. Clone le repo
git clone <repo-url>
cd Boutique

# 2. Créer backend/.env
cat > backend/.env << EOF
DATABASE_URL=postgresql://...
API_BASE_URL=https://...
EOF

# 3. Créer public/.env
cat > public/.env << EOF
API_BASE_URL=https://...
EOF

# 4. Backend - Installation et démarrage
cd backend
npm install
npm start

# 5. Mobile - Compilation (API URL déjà hardcodée)
cd mobile
flutter clean
flutter pub get
flutter build apk --release

# 6. Web - Compilation
cd ..
npm run build

# 7. Déploiement
vercel --prod
```

---

## 🔑 Variables Clés Nécessaires

### Backend Requirements
- ✅ `DATABASE_URL`: Connection string PostgreSQL (obligatoire)
- ✅ `API_BASE_URL`: URL publique du backend (pour web)

### Web Frontend Requirements
- ✅ `API_BASE_URL`: URL du backend (pour appels HTTP)

### Mobile App Requirements
- ✅ **Aucun .env requis** - Tout est hardcodé
- ⚠️ Pour changer d'API: Éditer `mobile/lib/config/api_config.dart`

### Optional (Non-Critical)
- `ENVIRONMENT`: pour logging
- `APP_VERSION`: pour tracking
- `KEYSTORE_*`: pour signature Android

---

## 🔓 .gitignore Status

```gitignore
# Les fichiers .env DOIVENT être ignorés:
.env
.env.local
.env.*.local
backend/.env
public/.env
mobile/.env
```

**Exception**: `.env.example` est **inclus** dans le repo (documentation).

---

## ⚙️ Exemple Réel (Production)

### Structure attendue après clone:

```
Boutique/
├── backend/
│   ├── .env                    ← À créer avec DATABASE_URL
│   ├── .env.example            ← Documentation (incluse)
│   └── ...
├── mobile/
│   ├── lib/config/
│   │   └── api_config.dart     ← Hardcoded (pas .env)
│   └── ...
├── public/
│   ├── .env                    ← À créer avec API_BASE_URL
│   ├── download.html
│   └── ...
├── .env.example                ← Documentation (incluse)
└── ...
```

---

## 🆘 Dépannage

### "Error: No pubspec.yaml found"
→ Tu es au mauvais endroit. Assure-toi d'être dans `./mobile` pour Flutter.

### "API 404 / Connection refused"
→ Vérifier que `backend/.env` contient le bon `DATABASE_URL` et `API_BASE_URL`.

### "Web app montre page grise"
→ Vérifier que `public/.env` contient le bon `API_BASE_URL`.

### "Mobile app crashe au démarrage"
→ L'API URL est hardcodée. Éditer `mobile/lib/config/api_config.dart` directement.

---

## 📚 Fichiers Connexes

- [API_ROUTES_MAPPING.md](API_ROUTES_MAPPING.md) - Toutes les routes backend
- [backend/index.js](backend/index.js) - Backend principal
- [mobile/lib/config/api_config.dart](mobile/lib/config/api_config.dart) - Config mobile
- [vercel.json](vercel.json) - Config Vercel deployment
