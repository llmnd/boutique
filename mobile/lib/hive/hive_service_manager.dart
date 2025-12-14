import 'package:boutique_mobile/hive/hive_integration.dart';
import 'package:boutique_mobile/config/api_config.dart';

/// Initialise et gère le cycle de vie de HiveService
class HiveServiceManager {
  static final HiveServiceManager _instance = HiveServiceManager._internal();
  factory HiveServiceManager() => _instance;
  HiveServiceManager._internal();

  bool _initialized = false;

  /// Initialise HiveService au démarrage de l'app
  Future<void> initializeForOwner(String ownerPhone) async {
    if (_initialized) {
      print('[HiveServiceManager] Already initialized, skipping...');
      return;
    }

    try {
      print('[HiveServiceManager] Initializing HiveService for $ownerPhone...');

      // Déterminer l'API base URL (local dev ou production)
      final String apiBaseUrl = _getApiBaseUrl();

      // Initialiser HiveIntegration
      await HiveIntegration.init(
        ownerPhone: ownerPhone,
        apiBaseUrl: apiBaseUrl,
      );

      _initialized = true;
      print('[HiveServiceManager] ✅ HiveService initialized successfully');
    } catch (e) {
      print('[HiveServiceManager] ❌ Error initializing HiveService: $e');
      rethrow;
    }
  }

  /// Obtient l'URL de l'API
  String _getApiBaseUrl() {
    // Utiliser la configuration centralisée ApiConfig
    return ApiConfig.getBaseUrl();
  }

  /// Récupère le service d'intégration Hive
  HiveIntegration get hiveIntegration => HiveIntegration();

  /// Ferme le service proprement
  Future<void> shutdown() async {
    try {
      await HiveIntegration.getInstance()?.close();
      _initialized = false;
      print('[HiveServiceManager] ✅ HiveService shutdown complete');
    } catch (e) {
      print('[HiveServiceManager] Error during shutdown: $e');
    }
  }

  /// Déclenche une synchronisation manuelle
  Future<bool> syncNow(String ownerPhone, {String? authToken}) async {
    try {
      print('[HiveServiceManager] Triggering manual sync...');
      final hiveService = HiveIntegration.getInstance();
      if (hiveService == null) {
        print('[HiveServiceManager] HiveService not initialized');
        return false;
      }

      final success = await hiveService.syncWithServer(
        ownerPhone,
        token: authToken,
      );

      if (success) {
        print('[HiveServiceManager] ✅ Sync completed successfully');
      } else {
        print('[HiveServiceManager] ⚠️ Sync completed with issues');
      }

      return success;
    } catch (e) {
      print('[HiveServiceManager] ❌ Sync error: $e');
      return false;
    }
  }

  /// Obtient le statut de synchronisation
  String? getSyncStatusJson(String ownerPhone) {
    try {
      final hiveService = HiveIntegration.getInstance();
      if (hiveService == null) return null;

      final status = hiveService.getSyncStatus(ownerPhone);
      if (status == null) return null;

      return '''
{
  "owner_phone": "${status.ownerPhone}",
  "last_sync_at": "${status.lastSyncAt.toIso8601String()}",
  "is_online": ${status.isOnline},
  "pending_operations": ${status.pendingOperationsCount},
  "sync_errors": "${status.lastError ?? 'none'}"
}
''';
    } catch (e) {
      print('[HiveServiceManager] Error getting sync status: $e');
      return null;
    }
  }

  /// Vérifie si le service est initialisé
  bool get isInitialized => _initialized;
}
