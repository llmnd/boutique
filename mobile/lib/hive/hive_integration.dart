import 'package:boutique_mobile/hive/services/hive_service.dart';
import 'package:boutique_mobile/hive/models/index.dart';

/// Wrapper d'intégration Hive avec l'API existante
/// Ce service facilite l'utilisation de Hive comme couche de cache locale
class HiveIntegration {
  static HiveService? _instance;

  /// Initialise le service Hive
  static Future<HiveService> init({
    required String apiBaseUrl,
    required String ownerPhone,
  }) async {
    if (_instance == null) {
      _instance = HiveService(apiBaseUrl: apiBaseUrl);
      await _instance!.init(ownerPhone: ownerPhone);
    }
    return _instance!;
  }

  /// Retourne l'instance existante
  static HiveService? getInstance() => _instance;

  /// Accès direct aux opérations CRUD

  /// Clients
  static Future<void> saveClient(HiveClient client) async {
    await _instance?.saveClient(client);
  }

  static List<HiveClient> getClients(String ownerPhone) {
    return _instance?.getClients(ownerPhone) ?? [];
  }

  static HiveClient? getClient(int id) {
    return _instance?.getClient(id);
  }

  /// Dettes
  static Future<void> saveDebt(HiveDebt debt) async {
    await _instance?.saveDebt(debt);
  }

  static List<HiveDebt> getDebts(String ownerPhone) {
    return _instance?.getDebts(ownerPhone) ?? [];
  }

  static HiveDebt? getDebt(int id) {
    return _instance?.getDebt(id);
  }

  /// Paiements
  static Future<void> savePayment(HivePayment payment) async {
    await _instance?.savePayment(payment);
  }

  static List<HivePayment> getPayments(String ownerPhone) {
    return _instance?.getPayments(ownerPhone) ?? [];
  }

  static List<HivePayment> getDebtPayments(int debtId) {
    return _instance?.getDebtPayments(debtId) ?? [];
  }

  /// Additions
  static Future<void> saveDebtAddition(HiveDebtAddition addition) async {
    await _instance?.saveDebtAddition(addition);
  }

  static List<HiveDebtAddition> getDebtAdditions(String ownerPhone) {
    return _instance?.getDebtAdditions(ownerPhone) ?? [];
  }

  static List<HiveDebtAddition> getDebtAdditionsByDebtId(int debtId) {
    return _instance?.getDebtAdditionsByDebtId(debtId) ?? [];
  }

  /// Synchronisation
  static Future<bool> syncWithServer(String ownerPhone,
      {String? token}) async {
    return await _instance?.syncWithServer(ownerPhone, token: token) ?? false;
  }

  static HiveSyncStatus? getSyncStatus(String ownerPhone) {
    return _instance?.getSyncStatus(ownerPhone);
  }

  /// Statut de connexion
  static bool isOnline() {
    return _instance?.isOnline ?? false;
  }

  static bool isSyncing() {
    return _instance?.isSyncing ?? false;
  }

  /// Gestion du cache
  static Future<void> clearLocalData(String ownerPhone) async {
    await _instance?.clearLocalData(ownerPhone);
  }

  /// Fermeture
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}

/// Helper pour les calculs de balance sur dettes
extension DebtBalanceCalculation on HiveDebt {
  double getCalculatedBalance(int debtId, HiveService? hiveService) {
    if (hiveService == null) return balance;

    final payments = hiveService
        .getDebtPayments(debtId)
        .fold<double>(0, (sum, p) => sum + p.amount);
    final additions = hiveService
        .getDebtAdditionsByDebtId(debtId)
        .fold<double>(0, (sum, a) => sum + a.amount);

    return amount + additions - payments;
  }

  bool isFullyPaid(int debtId, HiveService? hiveService) {
    final calculated = getCalculatedBalance(debtId, hiveService);
    return calculated <= 0;
  }

  double getRemainingBalance(int debtId, HiveService? hiveService) {
    final calculated = getCalculatedBalance(debtId, hiveService);
    return calculated > 0 ? calculated : 0;
  }
}

/// Helper pour les statistiques
extension SyncStatistics on HiveService {
  /// Obtient le nombre de modifications en attente
  int getPendingChangesCount(String ownerPhone) {
    final clients = getClients(ownerPhone)
        .where((c) => c.needsSync)
        .length;
    final debts = getDebts(ownerPhone)
        .where((d) => d.needsSync)
        .length;
    final payments = getPayments(ownerPhone)
        .where((p) => p.needsSync)
        .length;
    final additions = getDebtAdditions(ownerPhone)
        .where((a) => a.needsSync)
        .length;

    return clients + debts + payments + additions;
  }

  /// Obtient un résumé du cache local
  Map<String, int> getCacheStats(String ownerPhone) {
    return {
      'clients': getClients(ownerPhone).length,
      'debts': getDebts(ownerPhone).length,
      'payments': getPayments(ownerPhone).length,
      'additions': getDebtAdditions(ownerPhone).length,
      'pendingChanges': getPendingChangesCount(ownerPhone),
    };
  }
}
