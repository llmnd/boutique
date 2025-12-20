/// 🔌 Service API pour les appels réseau
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  /// Récupère la liste des clients
  Future<List> fetchClients(String ownerPhone) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clients?owner_phone=$ownerPhone'),
        headers: {'x-owner': ownerPhone},
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body) as List;
        return parsed.map((c) => c as Map).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching clients: $e');
      return [];
    }
  }

  /// Récupère la liste des dettes
  Future<List> fetchDebts(
    String ownerPhone, {
    String? query,
  }) async {
    try {
      var url = '$baseUrl/debts?owner_phone=$ownerPhone';
      if (query != null && query.isNotEmpty) {
        url += '&q=$query';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'x-owner': ownerPhone},
      );

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body) as List;
        return parsed.map((d) => d as Map).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching debts: $e');
      return [];
    }
  }

  /// Crée une nouvelle dette
  Future<Map?> createDebt({
    required String ownerPhone,
    required int clientId,
    required double amount,
    String? dueDate,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/debts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_phone': ownerPhone,
          'client_id': clientId,
          'total_debt': amount,
          'remaining': amount,
          'due_date': dueDate,
          'description': description,
          'type': 'debt',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map;
      }
      return null;
    } catch (e) {
      print('Error creating debt: $e');
      return null;
    }
  }

  /// Crée un nouvel emprunt
  Future<Map?> createLoan({
    required String ownerPhone,
    required int clientId,
    required double amount,
    String? dueDate,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/debts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'owner_phone': ownerPhone,
          'client_id': clientId,
          'total_debt': amount,
          'remaining': amount,
          'due_date': dueDate,
          'description': description,
          'type': 'loan',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map;
      }
      return null;
    } catch (e) {
      print('Error creating loan: $e');
      return null;
    }
  }
}
