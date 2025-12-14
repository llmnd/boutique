# 🔧 FIX: Erreur 404 NOT_FOUND sur Vercel

## 🚨 Problème
L'app retourne `404 NOT_FOUND` avec `ID: lhr1::...` - cela signifie que Vercel reçoit une requête mais le serveur Express n'a pas pu démarrer, probablement parce que `DATABASE_URL` n'est pas défini.

## ✅ Solution

### Étape 1: Vérifier que Neon est bien configuré
```bash
# Teste la connexion localement
$env:DATABASE_URL="postgresql://neondb_owner:npg_PWoZuK4nDar2@ep-snowy-dust-a4je8145-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
npm run dev
```

### Étape 2: Configurer les Variables sur Vercel

**Sur le dashboard Vercel:**
1. Va à https://vercel.com/dashboard
2. Sélectionne ton projet Boutique
3. Clique sur **Settings**
4. Va à **Environment Variables**
5. **Ajoute** ces variables:

```
Name: DATABASE_URL
Value: postgresql://neondb_owner:npg_PWoZuK4nDar2@ep-snowy-dust-a4je8145-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
Environments: Production (cocher)
```

```
Name: NODE_ENV
Value: production
Environments: Production (cocher)
```

### Étape 3: Redéployer

```bash
vercel --prod
```

### Étape 4: Vérifier les logs
```bash
vercel logs boutique-project-name --prod
```

Cherche des erreurs comme:
- ❌ `ECONNREFUSED` → DB pas accessible
- ❌ `ENOTFOUND` → DNS problème
- ❌ `password authentication failed` → Identifiants Neon incorrects

## 🔍 Diagnostic Rapide

Si ça ne marche pas, vérifie:

1. **La chaîne DATABASE_URL est correcte**
   - Copie exactement de Neon
   - Ne modifie pas le mot de passe
   - Inclus `?sslmode=require&channel_binding=require`

2. **Neon a créé les tables**
   - Sur https://console.neon.tech
   - Vérifie que la BD `neondb` existe
   - Vérifie que les tables existent

3. **Firewall Neon**
   - Neon accepte les connexions de Vercel par défaut
   - Pas besoin de configurer d'IP whitelist

## 📊 Test POST-FIX

Une fois le fix appliqué, test:

```bash
curl https://your-project.vercel.app/api/clients
# Devrait retourner [] ou un JSON, pas 404
```

---

Si toujours pas bon, partage le log exact:
```bash
vercel logs your-project-name --prod
```
