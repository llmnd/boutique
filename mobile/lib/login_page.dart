import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_settings.dart';

class LoginPage extends StatefulWidget {
  final void Function(String phone, String? shop, int? id, String? firstName, String? lastName) onLogin;
  const LoginPage({super.key, required this.onLogin});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneCtl = TextEditingController();
  final passCtl = TextEditingController();
  bool loading = false;

  String get apiHost {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  Future doLogin() async {
    setState(() {
      loading = true;
    });
    try {
      final body = {'phone': phoneCtl.text.trim(), 'password': passCtl.text};
      final res = await http.post(
          Uri.parse('$apiHost/auth/login'.replaceFirst('\u007f', '')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final id = data['id'] is int
            ? data['id'] as int
            : (data['id'] is String ? int.tryParse(data['id']) : null);
        
        // Save auth token
        if (data['auth_token'] != null) {
          final settings = AppSettings();
          await settings.initForOwner(data['phone']);
          await settings.setAuthToken(data['auth_token']);
        }
        
        widget.onLogin(data['phone'], data['shop_name'], id, data['first_name'], data['last_name']);
      } else {
        final body = res.body;
        final lower = body.toLowerCase();
        String friendly;
        if (res.statusCode == 401 || lower.contains('invalid') || lower.contains('incorrect') || lower.contains('credentials') || lower.contains('wrong')) {
          friendly = 'Identifiants incorrects. Vérifiez le numéro et le mot de passe.';
        } else if (res.statusCode == 404 || lower.contains('not found')) {
          friendly = 'Compte introuvable. Vérifiez le numéro ou créez un compte.';
        } else {
          // try to show server message if available
          try {
            final parsed = json.decode(body);
            if (parsed is Map && parsed['message'] != null) {
              friendly = parsed['message'].toString();
            } else {
              friendly = 'Connexion échouée (${res.statusCode}).';
            }
          } catch (_) {
            friendly = 'Connexion échouée (${res.statusCode}).';
          }
        }
        await _showMinimalDialog('Erreur', friendly);
      }
    } catch (e) {
      await _showMinimalDialog('Erreur', 'Erreur de connexion: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _showMinimalDialog(String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black26;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Form(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  child: Icon(
                                    Icons.receipt_long,
                                    color: isDark ? Colors.black : Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'GESTION DE DETTES',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Application Boutique',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: textColorSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 60),

                          // Login Form
                          Text(
                            'CONNEXION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: textColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Phone Field
                          TextField(
                            controller: phoneCtl,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextField(
                            controller: passCtl,
                            obscureText: true,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: loading ? null : doLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : Colors.black,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                disabledBackgroundColor: isDark ? Colors.white24 : Colors.black26,
                                disabledForegroundColor: isDark ? Colors.black38 : Colors.white54,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      'SE CONNECTER',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Links Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                                ),
                                child: Text(
                                  'MOT DE PASSE OUBLIÉ?',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    color: textColorSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RegisterPage(
                                      onRegister: (phone, shop, id, firstName, lastName) {
                                        widget.onLogin(phone, shop, id, firstName, lastName);
                                      },
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'CRÉER UN COMPTE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  final void Function(String phone, String? shop, int? id, String? firstName, String? lastName) onRegister;
  const RegisterPage({super.key, required this.onRegister});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final phoneCtl = TextEditingController();
  final passCtl = TextEditingController();
  final firstNameCtl = TextEditingController();
  final lastNameCtl = TextEditingController();
  final shopCtl = TextEditingController();
  final securityQuestionCtl = TextEditingController();
  final securityAnswerCtl = TextEditingController();
  bool loading = false;

  String get apiHost {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  Future doRegister() async {
    setState(() => loading = true);
    try {
      final body = {
        'phone': phoneCtl.text.trim(),
        'password': passCtl.text,
        'first_name': firstNameCtl.text.trim(),
        'last_name': lastNameCtl.text.trim(),
        'shop_name': shopCtl.text.trim(),
        'security_question': securityQuestionCtl.text.trim(),
        'security_answer': securityAnswerCtl.text.trim()
      };
      final res = await http.post(
          Uri.parse('$apiHost/auth/register'.replaceFirst('\u007f', '')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 201) {
        final data = json.decode(res.body);
        final id = data['id'] is int
            ? data['id'] as int
            : (data['id'] is String ? int.tryParse(data['id']) : null);
        
        // Save auth token
        if (data['auth_token'] != null) {
          final settings = AppSettings();
          await settings.initForOwner(data['phone']);
          await settings.setAuthToken(data['auth_token']);
        }
        
        widget.onRegister(data['phone'], data['shop_name'], id, data['first_name'], data['last_name']);
        Navigator.of(context).pop();
      } else {
        await _showMinimalDialog('Erreur', 'Inscription échouée: ${res.statusCode}\n${res.body}');
      }
    } catch (e) {
      await _showMinimalDialog('Erreur', 'Erreur inscription: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _showMinimalDialog(String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black26;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'NOUVEAU COMPTE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'INSCRIPTION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: textColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // First Name
                          TextField(
                            controller: firstNameCtl,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Prénom',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Last Name
                          TextField(
                            controller: lastNameCtl,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Phone
                          TextField(
                            controller: phoneCtl,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password
                          TextField(
                            controller: passCtl,
                            obscureText: true,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Shop Name
                          TextField(
                            controller: shopCtl,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Nom de la boutique (optionnel)',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Security Question
                          TextField(
                            controller: securityQuestionCtl,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Question secrète',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Security Answer
                          TextField(
                            controller: securityAnswerCtl,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Réponse secrète',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: loading ? null : doRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.white : Colors.black,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                                disabledBackgroundColor: isDark ? Colors.white24 : Colors.black26,
                                disabledForegroundColor: isDark ? Colors.black38 : Colors.white54,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      'CRÉER LE COMPTE',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                        color: isDark ? Colors.black : Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'DÉJÀ UN COMPTE? SE CONNECTER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: textColorSecondary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final phoneCtl = TextEditingController();
  final answerCtl = TextEditingController();
  final newPasswordCtl = TextEditingController();
  String? securityQuestion;
  bool loading = false;
  bool showAnswerField = false;

  String get apiHost {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  Future getSecurityQuestion() async {
    setState(() => loading = true);
    try {
      final res = await http.get(
          Uri.parse('$apiHost/auth/forgot-password/${phoneCtl.text.trim()}'.replaceFirst('\u007f', '')),
          headers: {'Content-Type': 'application/json'}
      ).timeout(const Duration(seconds: 8));
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          securityQuestion = data['security_question'];
          showAnswerField = true;
        });
      } else {
        await _showMinimalDialog('Erreur', 'Compte introuvable avec ce numéro.');
      }
    } catch (e) {
      await _showMinimalDialog('Erreur', 'Erreur: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future resetPassword() async {
    setState(() => loading = true);
    try {
      final body = {
        'phone': phoneCtl.text.trim(),
        'security_answer': answerCtl.text.trim(),
        'new_password': newPasswordCtl.text
      };
      final res = await http.post(
          Uri.parse('$apiHost/auth/reset-password'.replaceFirst('\u007f', '')),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body)).timeout(const Duration(seconds: 8));
      
      if (res.statusCode == 200) {
        await _showMinimalDialog('Succès', 'Mot de passe réinitialisé avec succès!');
        Navigator.of(context).pop();
      } else {
        final body = res.body;
        String friendly = 'Erreur lors de la réinitialisation.';
        try {
          final parsed = json.decode(body);
          if (parsed is Map && parsed['message'] != null) {
            friendly = parsed['message'].toString();
          }
        } catch (_) {}
        
        await _showMinimalDialog('Erreur', friendly);
      }
    } catch (e) {
      await _showMinimalDialog('Erreur', 'Erreur: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _showMinimalDialog(String title, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).cardColor,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColorSecondary = isDark ? Colors.white70 : Colors.black54;
    final borderColor = isDark ? Colors.white24 : Colors.black26;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'MOT DE PASSE OUBLIÉ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'RÉINITIALISATION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: textColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Phone Field
                          TextField(
                            controller: phoneCtl,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: textColor, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: textColorSecondary,
                              ),
                              border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: borderColor, width: 0.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: textColor, width: 1),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (securityQuestion != null) ...[
                            // Security Question Display
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor, width: 0.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'QUESTION SÉCURITÉ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.5,
                                      color: textColorSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    securityQuestion!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Security Answer
                            TextField(
                              controller: answerCtl,
                              style: TextStyle(color: textColor, fontSize: 15),
                              decoration: InputDecoration(
                                labelText: 'Réponse secrète',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: textColorSecondary,
                                ),
                                border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor, width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: textColor, width: 1),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // New Password
                            TextField(
                              controller: newPasswordCtl,
                              obscureText: true,
                              style: TextStyle(color: textColor, fontSize: 15),
                              decoration: InputDecoration(
                                labelText: 'Nouveau mot de passe',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: textColorSecondary,
                                ),
                                border: const OutlineInputBorder(borderSide: BorderSide(width: 0.5)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: borderColor, width: 0.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: textColor, width: 1),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Reset Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: loading ? null : resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.white : Colors.black,
                                  foregroundColor: isDark ? Colors.black : Colors.white,
                                  disabledBackgroundColor: isDark ? Colors.white24 : Colors.black26,
                                  disabledForegroundColor: isDark ? Colors.black38 : Colors.white54,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        'RÉINITIALISER',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                          color: isDark ? Colors.black : Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ] else ...[
                            // Continue Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: loading ? null : getSecurityQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.white : Colors.black,
                                  foregroundColor: isDark ? Colors.black : Colors.white,
                                  disabledBackgroundColor: isDark ? Colors.white24 : Colors.black26,
                                  disabledForegroundColor: isDark ? Colors.black38 : Colors.white54,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                ),
                                child: loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        'CONTINUER',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                          color: isDark ? Colors.black : Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}