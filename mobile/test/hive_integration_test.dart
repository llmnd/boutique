import 'package:flutter_test/flutter_test.dart';
import 'package:boutique_mobile/hive/hive_integration.dart';
import 'package:boutique_mobile/hive/models/index.dart';
import 'package:boutique_mobile/hive/services/hive_service.dart';

void main() {
  // Initialiser le binding Flutter avant tous les tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hive Local Cache Tests', () {
    late HiveService hiveService;
    const String testOwnerPhone = '+33123456789';
    const String apiBaseUrl = 'http://localhost:3000/api';

    setUp(() async {
      hiveService = await HiveIntegration.init(
        apiBaseUrl: apiBaseUrl,
        ownerPhone: testOwnerPhone,
      );
    });

    tearDown(() async {
      await hiveService.clearLocalData(testOwnerPhone);
      await hiveService.close();
    });

    test('Test 1: Create and Cache Debt', () async {
      final debt = HiveDebt(
        id: 1,
        creditor: 'Test Creditor',
        amount: 100.0,
        type: 'debt',
        clientId: 1,
        fromUser: 'user1',
        toUser: 'user2',
        balance: 100.0,
        paid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerPhone: testOwnerPhone,
        needsSync: true,
      );

      await hiveService.saveDebt(debt);
      final retrieved = hiveService.getDebt(1);

      expect(retrieved, isNotNull);
      expect(retrieved!.creditor, 'Test Creditor');
      expect(retrieved.amount, 100.0);
      print('✅ Test 1 passed: Debt cached correctly');
    });

    test('Test 2: Multiple Debts Cache', () async {
      for (int i = 1; i <= 5; i++) {
        await hiveService.saveDebt(HiveDebt(
          id: i,
          creditor: 'Creditor $i',
          amount: (i * 50.0),
          type: i % 2 == 0 ? 'loan' : 'debt',
          clientId: i,
          fromUser: 'user1',
          toUser: 'user$i',
          balance: (i * 50.0),
          paid: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ownerPhone: testOwnerPhone,
          needsSync: true,
        ));
      }

      final debts = hiveService.getDebts(testOwnerPhone);
      expect(debts.length, 5);
      expect(debts[4].type, 'loan');
      print('✅ Test 2 passed: Multiple debts cached');
    });

    test('Test 3: Add Payment and Track', () async {
      final debt = HiveDebt(
        id: 1,
        creditor: 'Test',
        amount: 100.0,
        type: 'debt',
        clientId: 1,
        fromUser: 'user1',
        toUser: 'user2',
        balance: 100.0,
        paid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerPhone: testOwnerPhone,
        needsSync: true,
      );
      await hiveService.saveDebt(debt);

      final payment = HivePayment(
        id: 1,
        debtId: 1,
        amount: 30.0,
        paidAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerPhone: testOwnerPhone,
        needsSync: true,
      );
      await hiveService.savePayment(payment);

      final payments = hiveService.getDebtPayments(1);
      expect(payments.length, 1);
      expect(payments[0].amount, 30.0);
      print('✅ Test 3 passed: Payment tracked');
    });

    test('Test 4: Client Caching', () async {
      for (int i = 1; i <= 3; i++) {
        final client = HiveClient(
          id: i,
          name: 'Client $i',
          phone: '+33$i',
          ownerPhone: testOwnerPhone,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          needsSync: true,
        );
        await hiveService.saveClient(client);
      }

      final clients = hiveService.getClients(testOwnerPhone);
      expect(clients.length, 3);
      expect(clients[0].name, 'Client 1');
      print('✅ Test 4 passed: Clients cached');
    });

    test('Test 5: Debt Additions Tracking', () async {
      final debt = HiveDebt(
        id: 1,
        creditor: 'Test',
        amount: 100.0,
        type: 'debt',
        clientId: 1,
        fromUser: 'user1',
        toUser: 'user2',
        balance: 100.0,
        paid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerPhone: testOwnerPhone,
        needsSync: true,
      );
      await hiveService.saveDebt(debt);

      for (int i = 1; i <= 3; i++) {
        final addition = HiveDebtAddition(
          id: i,
          debtId: 1,
          amount: (i * 10.0),
          addedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ownerPhone: testOwnerPhone,
          needsSync: true,
        );
        await hiveService.saveDebtAddition(addition);
      }

      final additions = hiveService.getDebtAdditionsByDebtId(1);
      expect(additions.length, 3);
      print('✅ Test 5 passed: Additions tracked');
    });

    test('Test 6: Sync Status Initialization', () async {
      final debt = HiveDebt(
        id: 1,
        creditor: 'Test',
        amount: 100.0,
        type: 'debt',
        clientId: 1,
        fromUser: 'user1',
        toUser: 'user2',
        balance: 100.0,
        paid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerPhone: testOwnerPhone,
        needsSync: true,
      );
      await hiveService.saveDebt(debt);

      final syncStatus = hiveService.getSyncStatus(testOwnerPhone);
      expect(syncStatus, isNotNull);
      expect(syncStatus!.ownerPhone, testOwnerPhone);
      expect(syncStatus.pendingOperationsCount, greaterThan(0));
      print('✅ Test 6 passed: Sync status initialized');
    });

    test('Test 7: Online Status Tracking', () async {
      final isOnline = hiveService.isOnline;
      expect(isOnline, isA<bool>());

      final syncStatus = hiveService.getSyncStatus(testOwnerPhone);
      expect(syncStatus!.isOnline, isA<bool>());
      print('✅ Test 7 passed: Online status tracked');
    });
  });
}
