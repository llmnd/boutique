# Guide d'intégration Hive

## Architecture

### Structure des fichiers
```
lib/
├── hive/
│   ├── models/
│   │   ├── hive_client.dart
│   │   ├── hive_debt.dart
│   │   ├── hive_payment.dart
│   │   ├── hive_debt_addition.dart
│   │   ├── hive_sync_status.dart
│   │   ├── hive_pending_operation.dart
│   │   └── index.dart
│   ├── services/
│   │   ├── hive_service.dart           # Service principal
│   │   ├── sync_queue.dart             # File d'attente des opérations
│   │   ├── conflict_resolver.dart      # Résolution des conflits
│   │   └── index.dart
│   ├── adapters/
│   │   └── hive_adapters.dart          # TypeAdapters Hive
│   └── hive_integration.dart           # Wrapper d'intégration
```

## Fonctionnement

### 1. Initialisation

```dart
import 'package:boutique_mobile/hive/hive_integration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive
  await HiveIntegration.init(
    apiBaseUrl: 'http://localhost:3000/api',
    ownerPhone: '1234567890',
  );
  
  runApp(const MyApp());
}
```

### 2. Sauvegarde de données locales

```dart
// Sauvegarder un client
final client = HiveClient(
  id: 1,
  name: 'Jean Dupont',
  phone: '0123456789',
  ownerPhone: '0987654321',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await HiveIntegration.saveClient(client);

// Sauvegarder une dette
final debt = HiveDebt(
  id: 1,
  creditor: 'Jean Dupont',
  amount: 50000,
  type: 'debt',
  clientId: 1,
  fromUser: 'Jean',
  toUser: 'Owner',
  balance: 50000,
  paid: false,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  ownerPhone: '0987654321',
);

await HiveIntegration.saveDebt(debt);
```

### 3. Récupération de données

```dart
// Récupérer tous les clients
final clients = HiveIntegration.getClients('0987654321');

// Récupérer une dette spécifique
final debt = HiveIntegration.getDebt(1);

// Récupérer les paiements d'une dette
final payments = HiveIntegration.getDebtPayments(1);

// Récupérer les additions d'une dette
final additions = HiveIntegration.getDebtAdditionsByDebtId(1);
```

### 4. Synchronisation avec le serveur

```dart
// Synchroniser avec le serveur
final success = await HiveIntegration.syncWithServer(
  '0987654321',
  token: 'your_auth_token',
);

// Vérifier le statut de synchronisation
final syncStatus = HiveIntegration.getSyncStatus('0987654321');
print('Dernière sync: ${syncStatus?.lastSyncAt}');
print('Nombre d\'opérations en attente: ${syncStatus?.pendingOperationsCount}');

// Vérifier l'état de connexion
if (HiveIntegration.isOnline()) {
  print('En ligne');
} else {
  print('Hors ligne - utilisation du cache local');
}
```

### 5. Calculs et statistiques

```dart
// Calculer le balance réel
final debt = HiveIntegration.getDebt(1)!;
final balance = debt.getCalculatedBalance(1);

// Vérifier si la dette est entièrement payée
final isPaid = debt.isFullyPaid(1);

// Obtenir le solde restant
final remaining = debt.getRemainingBalance(1);

// Obtenir les statistiques du cache
final stats = hiveService.getCacheStats('0987654321');
print('Clients en cache: ${stats['clients']}');
print('Dettes en cache: ${stats['debts']}');
print('Modifications en attente: ${stats['pendingChanges']}');
```

## Fonctionnement de la synchronisation

### Stratégie de résolution des conflits
- **Last-Write-Wins**: La version la plus récente (basée sur `updatedAt`) prime
- Les données locales plus récentes remplacent les données serveur
- Les données serveur plus récentes remplacent les données locales

### File d'attente des opérations
- Chaque modification locale est ajoutée à une queue
- Les opérations sont traitées par priorité (haute → normale → basse)
- Retry automatique jusqu'à 3 fois en cas d'échec
- Fonctionnement offline : les opérations restent en queue jusqu'à reconnexion

### Détection de connexion
- Détection automatique via `connectivity_plus`
- Synchronisation automatique tous les 5 minutes quand en ligne
- Pas de sync quand hors ligne

## Intégration avec sync_service.dart existant

```dart
// Dans votre sync_service.dart
import 'package:boutique_mobile/hive/hive_integration.dart';

class SyncService {
  Future<void> syncClients() async {
    // Récupérer les clients du cache Hive
    final cachedClients = HiveIntegration.getClients(ownerPhone);
    
    if (cachedClients.isNotEmpty) {
      // Utiliser le cache offline
      return processClients(cachedClients);
    }
    
    // Sinon, faire une requête au serveur
    final response = await http.get(...);
    
    // Sauvegarder en cache Hive
    for (final client in response) {
      await HiveIntegration.saveClient(client);
    }
  }
}
```

## Modèles de données et correspondance avec PostgreSQL

### HiveClient ↔ clients table
```
HiveClient.id          → clients.id
HiveClient.name        → clients.name
HiveClient.phone       → clients.phone
HiveClient.ownerPhone  → clients.owner_phone
```

### HiveDebt ↔ debts table
```
HiveDebt.id         → debts.id
HiveDebt.creditor   → debts.creditor
HiveDebt.amount     → debts.amount
HiveDebt.type       → debts.type ('debt'|'loan')
HiveDebt.clientId   → debts.client_id
HiveDebt.fromUser   → debts.from_user
HiveDebt.toUser     → debts.to_user
HiveDebt.balance    → debts.balance (auto-calculé)
HiveDebt.paid       → debts.paid (auto-mis à jour)
```

### HivePayment ↔ payments table
```
HivePayment.id      → payments.id
HivePayment.debtId  → payments.debt_id
HivePayment.amount  → payments.amount
HivePayment.paidAt  → payments.paid_at
```

### HiveDebtAddition ↔ debt_additions table
```
HiveDebtAddition.id     → debt_additions.id
HiveDebtAddition.debtId → debt_additions.debt_id
HiveDebtAddition.amount → debt_additions.amount
HiveDebtAddition.addedAt → debt_additions.added_at
```

## Gestion de l'offline

### Pendant l'offline
1. Toutes les modifications sont enregistrées dans Hive
2. Les opérations sont mises en queue
3. L'UI utilise les données du cache local

### À la reconnexion
1. Détection automatique de la connexion
2. Synchronisation automatique des opérations en queue
3. Récupération des données serveur mises à jour
4. Résolution des conflits si nécessaire

## Erreurs et logs

```dart
// Récupérer le dernier statut de sync
final status = HiveIntegration.getSyncStatus('0987654321');
if (status?.lastError != null) {
  print('Erreur de sync: ${status?.lastError}');
  print('Nombre d\'échecs: ${status?.failureCount}');
}

// Les adaptateurs Hive gèrent automatiquement les migrations de schéma
```

## Performance

- **Lecture locale** : O(n) où n = nombre d'entités (très rapide, en mémoire)
- **Écriture locale** : O(1) en moyenne (très rapide)
- **Synchronisation** : Asynchrone et non-bloquante
- **Mémoire** : Optimisée avec Hive Box partitionnées par owner_phone

## Nettoyage

```dart
// Effacer toutes les données locales d'un propriétaire
await HiveIntegration.clearLocalData('0987654321');

// Fermer le service (à faire dans dispose)
await HiveIntegration.close();
```

## Bonnes pratiques

1. **Toujours initialiser Hive** avant d'utiliser l'app
2. **Appeler `close()`** dans le dispose du widget principal
3. **Vérifier `isOnline()`** avant d'afficher les données
4. **Écouter la synchronisation** pour mettre à jour l'UI
5. **Gérer les erreurs de sync** avec `getSyncStatus().lastError`
6. **Utiliser les calculs d'extension** pour les balances (balance auto-calculée)
