# 🚀 Guide de Déploiement Vercel

## ✅ Préparation Effectuée

- ✅ `vercel.json` créé avec configuration Express
- ✅ Backend package.json prêt (Express, pg, cors, bcryptjs)
- ✅ Routes API configurées

## 📋 Étapes de Déploiement

### 1. **Configuration Vercel CLI** (Local)
```bash
npm install -g vercel
cd c:\Users\bmd-tech\Desktop\Boutique
vercel login
```

### 2. **Lier le Projet à Vercel**
```bash
vercel link
```
Sélectionne "Y" pour créer un nouveau projet Vercel

### 3. **Configurer les Variables d'Environnement**

Sur le dashboard Vercel (https://vercel.com/dashboard):

1. Sélectionne ton projet
2. Aller dans **Settings** → **Environment Variables**
3. Ajoute ces variables:

```
DATABASE_URL = postgresql://[user]:[password]@[host]/[database]
NODE_ENV = production
CORS_ORIGIN = https://your-domain.com
JWT_SECRET = [generate a secure key]
```

### 4. **Obtenir une Base de Données PostgreSQL**

Options recommandées:
- **Neon** (gratuit, avec Vercel): https://neon.tech
- **Supabase** (gratuit): https://supabase.com
- **Railway** (très simple): https://railway.app

Pour **Neon**:
```
1. Crée un projet sur neon.tech
2. Copie la connection string
3. Ajoute à Vercel comme DATABASE_URL
```

### 5. **Préparer les Migrations BD**

Si nécessaire, crée un script pour les migrations:
```bash
# Dans backend/package.json, ajoute:
"scripts": {
  "migrate": "node migrations/run.js",
  "build": "npm run migrate"
}
```

### 6. **Déployer**

```bash
# Test local d'abord
vercel dev

# Puis déployer en prod
vercel --prod
```

## 🎯 Vérification Post-Déploiement

```bash
# Test les endpoints
curl https://your-project.vercel.app/api/clients
curl https://your-project.vercel.app/api/debts

# Vérifier les logs
vercel logs your-project-name
```

## 🔧 Configurer l'App Mobile

Dans `mobile/lib/config/api_config.dart`:

```dart
static const String baseUrl = 'https://your-project.vercel.app/api';
```

## 📱 Points Importants

1. **Pas de fichiers locaux**: Vercel est serverless, pas de `/tmp` persistent
2. **Cold starts**: Les requêtes peuvent être plus lentes au démarrage
3. **Timeouts**: Fonction max 60s gratuit, 900s pro
4. **Base de données**: Ne pas stocker de fichiers, utiliser une DB externe

## ⚠️ Problèmes Courants

| Problème | Solution |
|----------|----------|
| `MODULE_NOT_FOUND` | `npm install` local, vérifier `package.json` |
| `DATABASE_URL undefined` | Vérifier Variables d'Env dans Vercel Settings |
| Erreur CORS | Ajouter `CORS_ORIGIN` dans les variables |
| Timeout | Optimiser les requêtes BD, utiliser `pg` connection pooling |

## ✅ Checklist Finale

- [ ] Vercel CLI installé
- [ ] Projet lié à Vercel
- [ ] Variables d'environnement ajoutées
- [ ] Base de données PostgreSQL connectée
- [ ] `vercel dev` testé localement
- [ ] `vercel --prod` déploiement succès
- [ ] Endpoints API testés en production
- [ ] API_BASE_URL mise à jour dans l'app mobile
- [ ] App mobile recompilée avec la nouvelle URL
