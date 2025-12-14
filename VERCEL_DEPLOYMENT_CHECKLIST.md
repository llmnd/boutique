# ✅ CHECKLIST DÉPLOIEMENT VERCEL

## Phase 1: Configuration Locale ✨

- [ ] **Vérifier les dépendances backend**
  ```bash
  cd backend
  npm install
  ```

- [ ] **Tester le serveur localement**
  ```bash
  npm run dev
  ```
  - [ ] API répond sur `http://localhost:3000/api`
  - [ ] Routes principales testées:
    - [ ] `GET /api/clients`
    - [ ] `POST /api/debts`
    - [ ] `POST /api/auth/login`

## Phase 2: Préparation Vercel 🚀

- [ ] **Installer Vercel CLI**
  ```bash
  npm install -g vercel
  ```

- [ ] **Authentification Vercel**
  ```bash
  vercel login
  ```

- [ ] **Lier le projet**
  ```bash
  cd c:\Users\bmd-tech\Desktop\Boutique
  vercel link
  ```

- [ ] **Vérifier vercel.json**
  - [ ] Fichier présent à la racine
  - [ ] Routes configurées correctement
  - [ ] Builds pointe vers `backend/index.js`

## Phase 3: Base de Données 🗄️

- [ ] **Sélectionner un fournisseur PostgreSQL**
  - [ ] Neon (recommandé pour Vercel)
  - [ ] Supabase
  - [ ] Railway
  - [ ] Heroku PostgreSQL

- [ ] **Obtenir la connection string**
  - Format: `postgresql://user:password@host:port/database`

- [ ] **Tester la connexion localement**
  ```bash
  psql "your-connection-string"
  ```

- [ ] **Ajouter les migrations BD** (si nécessaire)
  - [ ] `backend/migrations/` existe
  - [ ] Script `npm run migrate` configuré

## Phase 4: Variables d'Environnement 🔐

Sur https://vercel.com/dashboard → Settings → Environment Variables:

- [ ] **DATABASE_URL**
  - Valeur: `postgresql://...`
  - Applicable: Production

- [ ] **NODE_ENV**
  - Valeur: `production`
  - Applicable: Production

- [ ] **CORS_ORIGIN**
  - Valeur: `https://your-domain.com` (ou `*` pour test)
  - Applicable: Production

- [ ] **JWT_SECRET**
  - Valeur: Clé sécurisée générée
  - Applicable: Production

## Phase 5: Test Préproduction ⚡

- [ ] **Test avec `vercel dev`**
  ```bash
  vercel dev
  ```
  - [ ] Serveur démarre sans erreurs
  - [ ] Endpoints API fonctionnent
  - [ ] BD se connecte correctement

- [ ] **Vérifier les logs**
  ```bash
  vercel logs --project=your-project-name
  ```

## Phase 6: Déploiement Production 🎯

- [ ] **Déployer en production**
  ```bash
  vercel --prod
  ```

- [ ] **Attendre que le déploiement se termine**
  - URL de production générée: `https://...vercel.app`

- [ ] **Tester les endpoints en production**
  ```bash
  curl https://your-project.vercel.app/api/clients
  ```

- [ ] **Vérifier les logs de production**
  ```bash
  vercel logs your-project-name --prod
  ```

## Phase 7: Configuration Mobile 📱

- [ ] **Mettre à jour API_BASE_URL**
  - Fichier: `mobile/.env`
  - Ancienne valeur: `https://decent-carola-llmnd-3709b8dc.koyeb.app/api`
  - Nouvelle valeur: `https://your-project.vercel.app/api`

- [ ] **Recompiler l'app mobile**
  ```bash
  cd mobile
  flutter clean
  flutter pub get
  flutter run
  ```

- [ ] **Tester la synchronisation Hive**
  - [ ] App peut se connecter à la nouvelle API
  - [ ] Sync complète sans erreurs
  - [ ] Données se synchronisent correctement

## Phase 8: Monitoring Post-Déploiement 📊

- [ ] **Vérifier les analytiques Vercel**
  - [ ] Pas d'erreurs 5xx
  - [ ] Performance acceptable
  - [ ] Pas de timeout

- [ ] **Tester les scénarios critiques**
  - [ ] Créer une dette
  - [ ] Ajouter un paiement
  - [ ] Synchroniser les données
  - [ ] Mode hors-ligne

- [ ] **Surveiller les logs**
  - [ ] Erreurs de BD
  - [ ] Erreurs CORS
  - [ ] Connexions réseau

## ⚠️ Problèmes Courants

| Problème | Solution |
|----------|----------|
| `ENOENT: no such file or directory` | Installer dépendances: `npm install` |
| `DATABASE_URL undefined` | Ajouter en variables d'env Vercel |
| `CORS error in app` | Configurer `CORS_ORIGIN` correctement |
| `Timeout 504` | Vérifier performance des requêtes BD |
| `Connection refused` | Vérifier DATABASE_URL et firewall |

## 📞 Support

- **Vercel Docs**: https://vercel.com/docs
- **Express sur Vercel**: https://vercel.com/guides/deploying-nodejs-and-express
- **Problèmes BD**: Vérifier la console PostgreSQL du fournisseur

---

**Status**: ✅ Prêt pour déploiement  
**Dernière mise à jour**: 2025-12-14  
**Responsable**: Équipe Déploiement Boutique
