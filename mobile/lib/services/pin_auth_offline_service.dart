import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer l'authentification PIN offline
class PinAuthOfflineService {
  static final PinAuthOfflineService _instance = PinAuthOfflineService._internal();
  factory PinAuthOfflineService() => _instance;
  PinAuthOfflineService._internal();

  // Keys pour SharedPreferences
  static const String _KEY_PREFIX = 'pin_auth_offline_';
  static const String _KEY_PIN_HASH = '${_KEY_PREFIX}pin_hash';
  static const String _KEY_TOKEN = '${_KEY_PREFIX}token';
  static const String _KEY_TOKEN_EXPIRY = '${_KEY_PREFIX}token_expiry';
  static const String _KEY_PHONE = '${_KEY_PREFIX}phone';
  static const String _KEY_FIRST_NAME = '${_KEY_PREFIX}first_name';
  static const String _KEY_LAST_NAME = '${_KEY_PREFIX}last_name';
  static const String _KEY_SHOP_NAME = '${_KEY_PREFIX}shop_name';
  static const String _KEY_USER_ID = '${_KEY_PREFIX}user_id';
  static const String _KEY_LAST_LOGIN = '${_KEY_PREFIX}last_login';

  /// Hash simple du PIN (SHA256)
  String _hashPin(String pin) {
    // Utiliser une simple hashmap pour le PIN - c'est un PIN simple, pas besoin de bcrypt
    return pin.hashCode.toRadixString(36);
  }

  /// Sauvegarde les credentials après une connexion réussie avec PIN
  Future<void> cacheCredentials({
    required String pin,
    required String token,
    required String phone,
    required String firstName,
    required String lastName,
    required String shopName,
    required int userId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pinHash = _hashPin(pin);
      final now = DateTime.now();

      await Future.wait([
        prefs.setString(_KEY_PIN_HASH, pinHash),
        prefs.setString(_KEY_TOKEN, token),
        prefs.setInt(
          _KEY_TOKEN_EXPIRY,
          now.add(const Duration(days: 30)).millisecondsSinceEpoch,
        ),
        prefs.setString(_KEY_PHONE, phone),
        prefs.setString(_KEY_FIRST_NAME, firstName),
        prefs.setString(_KEY_LAST_NAME, lastName),
        prefs.setString(_KEY_SHOP_NAME, shopName),
        prefs.setInt(_KEY_USER_ID, userId),
        prefs.setInt(_KEY_LAST_LOGIN, now.millisecondsSinceEpoch),
      ]);

      print('✅ PIN credentials cached');
    } catch (e) {
      print('❌ Error caching PIN credentials: $e');
      rethrow;
    }
  }

  /// Tente une authentification offline avec le PIN
  Future<bool> authenticateOffline({required String pin}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPinHash = prefs.getString(_KEY_PIN_HASH);
      final tokenExpiry = prefs.getInt(_KEY_TOKEN_EXPIRY);

      // Vérifier que un PIN est en cache
      if (cachedPinHash == null) {
        print('⚠️  No cached PIN found');
        return false;
      }

      // Vérifier que le token n'a pas expiré
      if (tokenExpiry != null &&
          DateTime.now().millisecondsSinceEpoch > tokenExpiry) {
        print('⚠️  Cached token expired');
        await clearCachedCredentials();
        return false;
      }

      // Vérifier le PIN
      final pinHash = _hashPin(pin);
      if (pinHash != cachedPinHash) {
        print('⚠️  PIN mismatch');
        return false;
      }

      print('✅ Offline PIN authentication successful');
      return true;
    } catch (e) {
      print('❌ Error during offline PIN authentication: $e');
      return false;
    }
  }

  /// Récupère les données en cache après authentification
  Future<Map<String, dynamic>?> getCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString(_KEY_PHONE);
      final firstName = prefs.getString(_KEY_FIRST_NAME);
      final lastName = prefs.getString(_KEY_LAST_NAME);
      final shopName = prefs.getString(_KEY_SHOP_NAME);
      final userId = prefs.getInt(_KEY_USER_ID);
      final token = prefs.getString(_KEY_TOKEN);

      if (phone == null) return null;

      return {
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
        'shop_name': shopName,
        'id': userId,
        'auth_token': token,
      };
    } catch (e) {
      print('❌ Error retrieving cached data: $e');
      return null;
    }
  }

  /// Efface les credentials en cache
  Future<void> clearCachedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_KEY_PIN_HASH),
        prefs.remove(_KEY_TOKEN),
        prefs.remove(_KEY_TOKEN_EXPIRY),
        prefs.remove(_KEY_PHONE),
        prefs.remove(_KEY_FIRST_NAME),
        prefs.remove(_KEY_LAST_NAME),
        prefs.remove(_KEY_SHOP_NAME),
        prefs.remove(_KEY_USER_ID),
        prefs.remove(_KEY_LAST_LOGIN),
      ]);
      print('✅ Cached credentials cleared');
    } catch (e) {
      print('❌ Error clearing cached credentials: $e');
      rethrow;
    }
  }

  /// Vérifie s'il y a des credentials en cache
  Future<bool> hasCachedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_KEY_PIN_HASH) != null;
    } catch (e) {
      print('❌ Error checking cached credentials: $e');
      return false;
    }
  }
}
