import 'package:flutter/material.dart';
import 'package:boutique_mobile/hive/hive_integration.dart';
import 'package:boutique_mobile/hive/models/index.dart';
import 'package:boutique_mobile/config/api_config.dart';

/// Exemple d'utilisation du service Hive
/// À utiliser comme référence pour intégrer Hive dans votre app
class HiveUsageExample {
  /// Initialise le service Hive
  static Future<void> initializeHive(String ownerPhone) async {
    try {
      await HiveIntegration.init(
        apiBaseUrl: ApiConfig.getBaseUrl(),
        ownerPhone: ownerPhone,
      );
      print('✓ Hive initialized');
    } catch (e) {
      print('✗ Error initializing Hive: $e');
    }
  }

  /// Exemple : Sauvegarder un client
  static Future<void> exampleSaveClient(String ownerPhone) async {
    final client = HiveClient(
      id: 1,
      name: 'Jean Dupont',
      phone: '0123456789',
      ownerPhone: ownerPhone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await HiveIntegration.saveClient(client);
      print('✓ Client saved: ${client.name}');
    } catch (e) {
      print('✗ Error saving client: $e');
    }
  }

  /// Exemple : Créer une dette
  static Future<void> exampleCreateDebt(String ownerPhone) async {
    final debt = HiveDebt(
      id: 1,
      creditor: 'Jean Dupont',
      amount: 50000,
      type: 'debt', // 'debt' ou 'loan'
      clientId: 1,
      fromUser: 'Jean',
      toUser: 'Owner',
      balance: 50000,
      paid: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerPhone: ownerPhone,
    );

    try {
      await HiveIntegration.saveDebt(debt);
      print('✓ Debt created: ${debt.creditor}');
    } catch (e) {
      print('✗ Error creating debt: $e');
    }
  }

  /// Exemple : Ajouter un paiement
  static Future<void> exampleAddPayment(String ownerPhone) async {
    final payment = HivePayment(
      id: 1,
      debtId: 1,
      amount: 10000,
      paidAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerPhone: ownerPhone,
    );

    try {
      await HiveIntegration.savePayment(payment);
      print('✓ Payment added: 10000 F');

      // Récalculer le balance
      final debt = HiveIntegration.getDebt(1);
      final hiveService = HiveIntegration.getInstance();
      if (debt != null && hiveService != null) {
        final newBalance = debt.getCalculatedBalance(1, hiveService);
        print('  New balance: $newBalance');
      }
    } catch (e) {
      print('✗ Error adding payment: $e');
    }
  }

  /// Exemple : Ajouter une addition
  static Future<void> exampleAddAddition(String ownerPhone) async {
    final addition = HiveDebtAddition(
      id: 1,
      debtId: 1,
      amount: 5000,
      addedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ownerPhone: ownerPhone,
    );

    try {
      await HiveIntegration.saveDebtAddition(addition);
      print('✓ Addition added: 5000 F');

      // Récalculer le balance
      final debt = HiveIntegration.getDebt(1);
      final hiveService = HiveIntegration.getInstance();
      if (debt != null && hiveService != null) {
        final newBalance = debt.getCalculatedBalance(1, hiveService);
        print('  New balance: $newBalance');
      }
    } catch (e) {
      print('✗ Error adding addition: $e');
    }
  }

  /// Exemple : Synchroniser avec le serveur
  static Future<void> exampleSync(String ownerPhone, String token) async {
    print('Starting sync...');

    try {
      final success = await HiveIntegration.syncWithServer(
        ownerPhone,
        token: token,
      );

      if (success) {
        print('✓ Sync completed successfully');
      } else {
        print('✗ Sync failed (offline?)');
      }

      final status = HiveIntegration.getSyncStatus(ownerPhone);
      if (status != null) {
        print('  Last sync: ${status.lastSyncAt}');
        print('  Pending ops: ${status.pendingOperationsCount}');
        print('  Online: ${status.isOnline}');
      }
    } catch (e) {
      print('✗ Error syncing: $e');
    }
  }

  /// Exemple : Consulter les données locales
  static void exampleGetLocalData(String ownerPhone) {
    print('\n=== Local Cache ===');

    final hiveService = HiveIntegration.getInstance();

    // Clients
    final clients = HiveIntegration.getClients(ownerPhone);
    print('Clients (${clients.length}):');
    for (final client in clients) {
      print('  - ${client.name} (${client.phone})');
    }

    // Dettes
    final debts = HiveIntegration.getDebts(ownerPhone);
    print('\nDebts (${debts.length}):');
    for (final debt in debts) {
      final isPaid =
          hiveService != null ? debt.isFullyPaid(debt.id, hiveService) : false;
      final balance = hiveService != null
          ? debt.getCalculatedBalance(debt.id, hiveService)
          : debt.balance;
      print('  - ${debt.creditor}: ${debt.amount}F (balance: ${balance}F, paid: $isPaid)');
    }

    // Paiements
    final payments = HiveIntegration.getPayments(ownerPhone);
    print('\nPayments (${payments.length}):');
    for (final payment in payments) {
      print('  - Debt #${payment.debtId}: ${payment.amount}F (${payment.paidAt})');
    }

    // Additions
    final additions = HiveIntegration.getDebtAdditions(ownerPhone);
    print('\nAdditions (${additions.length}):');
    for (final addition in additions) {
      print('  - Debt #${addition.debtId}: +${addition.amount}F (${addition.addedAt})');
    }
  }

  /// Exemple : Consulter les statistiques
  static void exampleGetStats(String ownerPhone) {
    final hiveService = HiveIntegration.getInstance();
    if (hiveService == null) {
      print('HiveService not initialized');
      return;
    }

    print('\n=== Cache Statistics ===');
    final stats = hiveService.getCacheStats(ownerPhone);
    print('Clients: ${stats['clients']}');
    print('Debts: ${stats['debts']}');
    print('Payments: ${stats['payments']}');
    print('Additions: ${stats['additions']}');
    print('Pending changes: ${stats['pendingChanges']}');

    final status = HiveIntegration.getSyncStatus(ownerPhone);
    if (status != null) {
      print('\n=== Sync Status ===');
      print('Online: ${status.isOnline}');
      print('Syncing: ${status.isSyncing}');
      print('Last sync: ${status.lastSyncAt}');
      print('Next sync: ${status.nextSyncAt}');
      print('Failure count: ${status.failureCount}');
      if (status.lastError != null) {
        print('Last error: ${status.lastError}');
      }
    }
  }

  /// Exemple complet de flux
  static Future<void> exampleFullFlow(String ownerPhone, String token) async {
    print('=== Full Hive Flow ===\n');

    // 1. Initialiser
    await initializeHive(ownerPhone);

    // 2. Créer des données
    await exampleSaveClient(ownerPhone);
    await exampleCreateDebt(ownerPhone);
    await exampleAddPayment(ownerPhone);
    await exampleAddAddition(ownerPhone);

    // 3. Consulter les données
    exampleGetLocalData(ownerPhone);

    // 4. Consulter les stats
    exampleGetStats(ownerPhone);

    // 5. Synchroniser
    await exampleSync(ownerPhone, token);

    // 6. Afficher les stats après sync
    exampleGetStats(ownerPhone);
  }
}

/// Widget exemple pour afficher le statut de sync
class SyncStatusWidget extends StatefulWidget {
  final String ownerPhone;

  const SyncStatusWidget({
    super.key,
    required this.ownerPhone,
  });

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  late Future<void> _syncFuture;

  @override
  void initState() {
    super.initState();
    _syncFuture = HiveIntegration.syncWithServer(widget.ownerPhone);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _syncFuture,
      builder: (context, snapshot) {
        final hiveService = HiveIntegration.getInstance();
        if (hiveService == null) {
          return const Center(child: Text('Hive not initialized'));
        }

        final status = hiveService.getSyncStatus(widget.ownerPhone);
        if (status == null) {
          return const Center(child: Text('No sync status'));
        }

        return Column(
          children: [
            // Statut de connexion
            Row(
              children: [
                Icon(
                  status.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: status.isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(status.isOnline ? 'Online' : 'Offline'),
              ],
            ),
            // Statut de sync
            if (status.isSyncing)
              const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Syncing...'),
                ],
              )
            else
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('Last sync: ${status.lastSyncAt.toString().split('.')[0]}'),
                ],
              ),
            // Opérations en attente
            if (status.pendingOperationsCount > 0)
              Text(
                'Pending: ${status.pendingOperationsCount} changes',
                style: const TextStyle(color: Colors.orange),
              ),
            // Erreur
            if (status.lastError != null)
              Text(
                'Error: ${status.lastError}',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        );
      },
    );
  }
}
