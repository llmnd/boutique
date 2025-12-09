import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:boutique_mobile/config/api_config.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  String _locale = 'fr_FR';
  String _currency = 'XOF';
  Map<String, double> _rates = {'XOF': 1.0, 'EUR': 0.0015, 'USD': 0.0017};
  String? _ownerPhone;
  bool _lightMode = false;
  bool _showAmounts = true;
  
  // User profile information
  String? _firstName;
  String? _lastName;
  String? _shopName;
  bool _boutiqueModeEnabled = false;
  
  // Authentication token
  String? _authToken;
  String? _deviceId;

  String get locale => _locale;
  String get currency => _currency;
  Map<String, double> get rates => _rates;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get shopName => _shopName;
  String? get ownerPhone => _ownerPhone;
  String? get authToken => _authToken;
  String? get deviceId => _deviceId;
  bool get boutiqueModeEnabled => _boutiqueModeEnabled;

  Future<void> initForOwner(String ownerPhone) async {
    _ownerPhone = ownerPhone;
    final prefs = await SharedPreferences.getInstance();
    final l = prefs.getString('locale_$ownerPhone');
    final c = prefs.getString('currency_$ownerPhone');
    final r = prefs.getString('rates_$ownerPhone');
    final lm = prefs.getBool('light_mode_$ownerPhone');
    final sa = prefs.getBool('show_amounts_$ownerPhone');
    final fn = prefs.getString('first_name_$ownerPhone');
    final ln = prefs.getString('last_name_$ownerPhone');
    final sn = prefs.getString('shop_name_$ownerPhone');
    final bm = prefs.getBool('boutique_mode_$ownerPhone');
    final at = prefs.getString('auth_token_$ownerPhone');
    final di = prefs.getString('device_id_$ownerPhone');
    
    if (l != null) _locale = l;
    if (c != null) _currency = c;
    if (r != null) {
      try {
        final Map parsed = json.decode(r) as Map;
        _rates = parsed.map((k, v) => MapEntry(k as String, (v as num).toDouble()));
      } catch (_) {}
    }
    if (lm != null) _lightMode = lm;
    if (sa != null) _showAmounts = sa;
    if (fn != null) _firstName = fn;
    if (ln != null) _lastName = ln;
    if (sn != null) _shopName = sn;
    if (bm != null) _boutiqueModeEnabled = bm;
    if (at != null) _authToken = at;
    if (di != null) _deviceId = di;
    notifyListeners();
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setString('locale_$_ownerPhone', locale);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setString('currency_$_ownerPhone', currency);
    notifyListeners();
  }

  Future<void> setRates(Map<String, double> rates) async {
    _rates = rates;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setString('rates_$_ownerPhone', json.encode(rates));
    notifyListeners();
  }

  bool get lightMode => _lightMode;
  bool get showAmounts => _showAmounts;

  Future<void> setLightMode(bool light) async {
    _lightMode = light;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setBool('light_mode_$_ownerPhone', light);
    notifyListeners();
  }

  Future<void> setShowAmounts(bool show) async {
    _showAmounts = show;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setBool('show_amounts_$_ownerPhone', show);
    notifyListeners();
  }

  Future<void> setFirstName(String firstName) async {
    _firstName = firstName;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setString('first_name_$_ownerPhone', firstName);
    notifyListeners();
  }

  Future<void> setLastName(String lastName) async {
    _lastName = lastName;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setString('last_name_$_ownerPhone', lastName);
    notifyListeners();
  }

  Future<void> setShopName(String shopName) async {
    _shopName = shopName;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setString('shop_name_$_ownerPhone', shopName);
    notifyListeners();
  }

  Future<void> setBoutiqueModeEnabled(bool enabled) async {
    _boutiqueModeEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) await prefs.setBool('boutique_mode_$_ownerPhone', enabled);
    notifyListeners();
  }

  Future<void> setProfileInfo(String firstName, String lastName, String shopName) async {
    _firstName = firstName;
    _lastName = lastName;
    _shopName = shopName;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) {
      await prefs.setString('first_name_$_ownerPhone', firstName);
      await prefs.setString('last_name_$_ownerPhone', lastName);
      await prefs.setString('shop_name_$_ownerPhone', shopName);
    }
    notifyListeners();
  }

  Future<void> setAuthToken(String token, {String? deviceId}) async {
    _authToken = token;
    if (deviceId != null) _deviceId = deviceId;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) {
      await prefs.setString('auth_token_$_ownerPhone', token);
      if (deviceId != null) await prefs.setString('device_id_$_ownerPhone', deviceId);
    }
    notifyListeners();
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    _deviceId = null;
    final prefs = await SharedPreferences.getInstance();
    if (_ownerPhone != null) {
      await prefs.remove('auth_token_$_ownerPhone');
      await prefs.remove('device_id_$_ownerPhone');
    }
    notifyListeners();
  }

  String get apiHost => ApiConfig.getBaseUrl();

  Future<void> syncBoutiqueModeToServer(bool enabled) async {
    if (_authToken == null || _authToken!.isEmpty) {
      // No token, just update locally
      await setBoutiqueModeEnabled(enabled);
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('$apiHost/auth/update-boutique-mode'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'auth_token': _authToken,
          'boutique_mode_enabled': enabled,
        }),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        // Update locally
        await setBoutiqueModeEnabled(enabled);
      }
    } catch (e) {
      // Fallback: update locally if server fails
      await setBoutiqueModeEnabled(enabled);
    }
  }

  double convertFromXof(num amount) {
    final rate = _rates[_currency] ?? 1.0;
    return (amount.toDouble()) * rate;
  }

  String formatCurrency(dynamic value) {
    if (value == null) return '-';
    final num? parsed = (value is num) ? value : num.tryParse(value.toString());
    if (parsed == null) return value.toString();
    final converted = convertFromXof(parsed);
    // For XOF (FCFA) we want format like "500 F" (no decimals, currency after amount)
    if (_currency == 'XOF') {
      return '${converted.toStringAsFixed(0)} F';
    }

    // For other currencies (EUR, USD) use locale-aware formatting with 2 decimals
    final symbol = _currency == 'EUR' ? '€' : r'$';
    try {
      final fmt = NumberFormat.currency(locale: _locale, symbol: symbol, name: _currency, decimalDigits: 2);
      return fmt.format(converted);
    } catch (_) {
      return '${converted.toStringAsFixed(2)} $symbol';
    }
  }
}
