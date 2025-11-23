import 'package:boutique_mobile/hive/models/index.dart';
import 'package:uuid/uuid.dart';

class SyncQueueResult {
  final bool success;
  final String message;
  final String? operationId;
  final dynamic data;

  SyncQueueResult({
    required this.success,
    required this.message,
    this.operationId,
    this.data,
  });
}

/// Gère la file d'attente des opérations à synchroniser
/// Utilise une liste en mémoire pour stocker les opérations
class SyncQueue {
  final List<HivePendingOperation> _operations = [];

  static Future<SyncQueue> init() async {
    return SyncQueue._();
  }

  SyncQueue._();

  /// Ajoute une opération à la file d'attente
  Future<SyncQueueResult> enqueue({
    required String operationType,
    required String entityType,
    required int entityId,
    required String ownerPhone,
    required Map<String, dynamic> payload,
    int priority = 0,
  }) async {
    try {
      const uuid = Uuid();
      final operation = HivePendingOperation(
        id: uuid.v4(),
        operationType: operationType,
        entityType: entityType,
        entityId: entityId,
        ownerPhone: ownerPhone,
        payload: payload,
        createdAt: DateTime.now(),
        priority: priority,
        retryCount: 0,
      );

      _operations.add(operation);

      return SyncQueueResult(
        success: true,
        message: 'Operation queued',
        operationId: operation.id,
        data: operation,
      );
    } catch (e) {
      return SyncQueueResult(
        success: false,
        message: 'Error queuing operation: $e',
      );
    }
  }

  /// Récupère les opérations en attente pour un propriétaire
  List<HivePendingOperation> getPendingOperations(String ownerPhone) {
    final filtered =
        _operations.where((op) => op.ownerPhone == ownerPhone).toList();

    // Trier par priorité (descending) puis par date (ascending)
    filtered.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    return filtered;
  }

  /// Marque une opération comme en traitement
  Future<void> markAsProcessing(String operationId, bool processing) async {
    try {
      final index = _operations.indexWhere((op) => op.id == operationId);
      if (index != -1) {
        final op = _operations[index];
        _operations[index] = op.copyWith(isProcessing: processing);
      }
    } catch (e) {
      print('Error marking as processing: $e');
    }
  }

  /// Met à jour une opération
  Future<void> updateOperation(
    String operationId, {
    bool? success,
    String? error,
    int? retryCount,
  }) async {
    try {
      final index = _operations.indexWhere((op) => op.id == operationId);
      if (index != -1) {
        final op = _operations[index];
        _operations[index] = op.copyWith(
          success: success ?? op.success,
          lastError: error ?? op.lastError,
          retryCount: retryCount ?? op.retryCount,
          lastRetryAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error updating operation: $e');
    }
  }

  /// Réessaie une opération échouée
  Future<void> retryOperation(String operationId) async {
    try {
      final index = _operations.indexWhere((op) => op.id == operationId);
      if (index != -1) {
        final op = _operations[index];
        _operations[index] = op.copyWith(
          retryCount: op.retryCount + 1,
          lastRetryAt: DateTime.now(),
          success: null,
          lastError: null,
          isProcessing: false,
        );
      }
    } catch (e) {
      print('Error retrying operation: $e');
    }
  }

  /// Récupère les opérations échouées
  List<HivePendingOperation> getFailedOperations(
    String ownerPhone, {
    int maxRetries = 3,
  }) {
    return _operations
        .where(
          (op) =>
              op.ownerPhone == ownerPhone &&
              op.retryCount >= maxRetries &&
              op.success == false,
        )
        .toList();
  }

  /// Supprime une opération
  Future<void> removeOperation(String operationId) async {
    try {
      _operations.removeWhere((op) => op.id == operationId);
    } catch (e) {
      print('Error removing operation: $e');
    }
  }

  /// Récupère le nombre d'opérations en attente
  int getPendingCount(String ownerPhone) {
    return _operations
        .where(
          (op) =>
              op.ownerPhone == ownerPhone &&
              (op.success == null || op.success == false),
        )
        .length;
  }

  /// Vide la file d'attente pour un propriétaire
  Future<void> clearQueue(String ownerPhone) async {
    try {
      _operations.removeWhere((op) => op.ownerPhone == ownerPhone);
    } catch (e) {
      print('Error clearing queue: $e');
    }
  }

  /// Ferme la queue
  Future<void> close() async {
    _operations.clear();
  }
}
