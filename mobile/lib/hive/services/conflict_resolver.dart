import 'package:boutique_mobile/hive/models/index.dart';

class ConflictResolutionResult<T> {
  final T? resolvedData;
  final bool isResolved;
  final String reason;
  final T? localData;
  final T? serverData;

  ConflictResolutionResult({
    required this.resolvedData,
    required this.isResolved,
    required this.reason,
    this.localData,
    this.serverData,
  });
}

/// Résolveur de conflits pour la synchronisation Hive
class ConflictResolver {
  /// Résout les conflits entre les données locales et serveur
  /// Stratégie : "last-write-wins" (dernière modification gagne)
  static ConflictResolutionResult<HiveDebt> resolveDebtConflict({
    required HiveDebt localDebt,
    required HiveDebt serverDebt,
  }) {
    // Si les versions sont identiques, pas de conflit
    if (localDebt.localVersion == serverDebt.serverVersion &&
        localDebt.serverVersion == serverDebt.serverVersion) {
      return ConflictResolutionResult(
        resolvedData: serverDebt,
        isResolved: false,
        reason: 'No conflict',
        localData: localDebt,
        serverData: serverDebt,
      );
    }

    // Comparer les timestamps - la plus récente gagne
    final localIsNewer = localDebt.updatedAt.isAfter(serverDebt.updatedAt);

    if (localIsNewer) {
      // Les données locales sont plus récentes, les utiliser
      return ConflictResolutionResult(
        resolvedData: localDebt.copyWith(
          serverVersion: serverDebt.serverVersion + 1,
          needsSync: true,
        ),
        isResolved: true,
        reason:
            'Local version is newer (${localDebt.updatedAt}) > server (${serverDebt.updatedAt})',
        localData: localDebt,
        serverData: serverDebt,
      );
    } else {
      // Les données serveur sont plus récentes, les utiliser
      return ConflictResolutionResult(
        resolvedData: serverDebt.copyWith(
          localVersion: localDebt.localVersion,
          needsSync: false,
        ),
        isResolved: true,
        reason:
            'Server version is newer (${serverDebt.updatedAt}) > local (${localDebt.updatedAt})',
        localData: localDebt,
        serverData: serverDebt,
      );
    }
  }

  /// Résout les conflits pour les clients
  static ConflictResolutionResult<HiveClient> resolveClientConflict({
    required HiveClient localClient,
    required HiveClient serverClient,
  }) {
    final localIsNewer = localClient.updatedAt.isAfter(serverClient.updatedAt);

    if (localIsNewer) {
      return ConflictResolutionResult(
        resolvedData: localClient.copyWith(needsSync: true),
        isResolved: true,
        reason: 'Local version is newer',
        localData: localClient,
        serverData: serverClient,
      );
    } else {
      return ConflictResolutionResult(
        resolvedData: serverClient.copyWith(needsSync: false),
        isResolved: true,
        reason: 'Server version is newer',
        localData: localClient,
        serverData: serverClient,
      );
    }
  }

  /// Résout les conflits pour les paiements
  static ConflictResolutionResult<HivePayment> resolvePaymentConflict({
    required HivePayment localPayment,
    required HivePayment serverPayment,
  }) {
    final localIsNewer = localPayment.updatedAt.isAfter(serverPayment.updatedAt);

    if (localIsNewer) {
      return ConflictResolutionResult(
        resolvedData: localPayment.copyWith(needsSync: true),
        isResolved: true,
        reason: 'Local version is newer',
        localData: localPayment,
        serverData: serverPayment,
      );
    } else {
      return ConflictResolutionResult(
        resolvedData: serverPayment.copyWith(needsSync: false),
        isResolved: true,
        reason: 'Server version is newer',
        localData: localPayment,
        serverData: serverPayment,
      );
    }
  }

  /// Résout les conflits pour les additions
  static ConflictResolutionResult<HiveDebtAddition>
      resolveDebtAdditionConflict({
        required HiveDebtAddition localAddition,
        required HiveDebtAddition serverAddition,
      }) {
    final localIsNewer =
        localAddition.updatedAt.isAfter(serverAddition.updatedAt);

    if (localIsNewer) {
      return ConflictResolutionResult(
        resolvedData: localAddition.copyWith(needsSync: true),
        isResolved: true,
        reason: 'Local version is newer',
        localData: localAddition,
        serverData: serverAddition,
      );
    } else {
      return ConflictResolutionResult(
        resolvedData: serverAddition.copyWith(needsSync: false),
        isResolved: true,
        reason: 'Server version is newer',
        localData: localAddition,
        serverData: serverAddition,
      );
    }
  }

  /// Détecte s'il y a un conflit de données
  static bool hasConflict({
    required DateTime localUpdatedAt,
    required DateTime serverUpdatedAt,
    required int localVersion,
    required int serverVersion,
  }) {
    // Conflit si les versions ne correspondent pas ET les timestamps sont différents
    return localVersion != serverVersion &&
        localUpdatedAt != serverUpdatedAt;
  }

  /// Calcule la stratégie de fusion pour les modifications concurrentes
  static Map<String, dynamic> mergeChanges({
    required Map<String, dynamic> localChanges,
    required Map<String, dynamic> serverChanges,
  }) {
    final merged = {...serverChanges};

    // Fusionner les modifications locales plus récentes
    localChanges.forEach((key, localValue) {
      if (!merged.containsKey(key)) {
        merged[key] = localValue;
      }
    });

    return merged;
  }
}
