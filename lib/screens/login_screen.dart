import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneConfirmController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;
  bool _showPassword = false;
  bool _showPasswordConfirm = false;

  String _phoneToEmail(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '').replaceAll('+', '');
    return '225$cleaned@tanda.app';
  }

  bool _validatePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    return cleaned.length >= 8 && RegExp(r'^[0-9]+$').hasMatch(cleaned);
  }

  void _handleSignIn() async {
    setState(() {
      _error = null;
    });

    if (_phoneController.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez entrer votre numéro de téléphone');
      return;
    }

    if (!_validatePhone(_phoneController.text)) {
      setState(() => _error = 'Numéro de téléphone invalide');
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez entrer votre mot de passe');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _phoneToEmail(_phoneController.text.trim());
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        widget.onLoginSuccess();
      }
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('Invalid login credentials')) {
        msg = 'Numéro de téléphone ou mot de passe incorrect.';
      }
      setState(() => _error = msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleSignUp() async {
    setState(() {
      _error = null;
    });

    if (_firstNameController.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez entrer votre prénom');
      return;
    }

    if (_lastNameController.text.trim().isEmpty) {
      setState(() => _error = 'Veuillez entrer votre nom');
      return;
    }

    if (!_validatePhone(_phoneController.text)) {
      setState(() => _error = 'Numéro de téléphone invalide');
      return;
    }

    if (_phoneController.text.trim() != _phoneConfirmController.text.trim()) {
      setState(() => _error = 'Les numéros de téléphone ne correspondent pas');
      return;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      setState(() => _error = 'Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _phoneToEmail(_phoneController.text.trim());
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: _passwordController.text.trim(),
        data: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'phone': '+225${_phoneController.text.trim().replaceAll(RegExp(r'\s+'), '')}',
        },
      );

      if (mounted) {
        // Essayer de se connecter automatiquement
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: email,
            password: _passwordController.text.trim(),
          );
          widget.onLoginSuccess();
        } catch (_) {
          // Si c'est échoué, afficher login pour se connecter
          setState(() {
            _isLogin = true;
            _passwordController.clear();
            _passwordConfirmController.clear();
            _phoneConfirmController.clear();
            _firstNameController.clear();
            _lastNameController.clear();
          });
        }
      }
    } catch (e) {
      String msg = e.toString();
      if (msg.contains('already registered')) {
        msg = 'Ce numéro est déjà enregistré. Connectez-vous.';
      }
      setState(() => _error = msg);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _switchMode(bool toLogin) {
    setState(() {
      _isLogin = toLogin;
      _error = null;
      _passwordController.clear();
      _passwordConfirmController.clear();
      _phoneConfirmController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Image.asset(
                'assets/images/connexion_cargoo.png',
                fit: BoxFit.contain,
              ),
            ),

            // Welcome Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Bienvenue sur ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: 'CarGoo',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B00),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Connectez-vous pour continuer',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),

            // Tab Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchMode(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _isLogin
                                ? Border(
                                    bottom: BorderSide(
                                      color: const Color(0xFFFF6B00),
                                      width: 2,
                                    ),
                                  )
                                : null,
                            boxShadow: _isLogin
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person,
                                color: _isLogin
                                    ? const Color(0xFFFF6B00)
                                    : const Color(0xFF999999),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _isLogin
                                      ? const Color(0xFFFF6B00)
                                      : const Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchMode(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: !_isLogin
                                ? Border(
                                    bottom: BorderSide(
                                      color: const Color(0xFFFF6B00),
                                      width: 2,
                                    ),
                                  )
                                : null,
                            boxShadow: !_isLogin
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add,
                                color: !_isLogin
                                    ? const Color(0xFFFF6B00)
                                    : const Color(0xFF999999),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Inscription',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: !_isLogin
                                      ? const Color(0xFFFF6B00)
                                      : const Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Error Message
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD4D4),
                          width: 1,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ),

                  // First Name (Signup only)
                  if (!_isLogin)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEEEEEE),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Color(0xFFAAAAAA),
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                hintText: 'Prénom',
                                hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Last Name (Signup only)
                  if (!_isLogin)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEEEEEE),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Color(0xFFAAAAAA),
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                hintText: 'Nom',
                                hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Phone
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFEEEEEE),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Color(0xFFAAAAAA),
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          '+225',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              hintText: 'N° de Téléphone',
                              hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phone Confirm (Signup only)
                  if (!_isLogin)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEEEEEE),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Color(0xFFAAAAAA),
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            '+225',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _phoneConfirmController,
                              decoration: const InputDecoration(
                                hintText: 'Confirmer le N° de Téléphone',
                                hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Password
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFEEEEEE),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock,
                          color: Color(0xFFAAAAAA),
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              hintText: 'Mot de passe',
                              hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1A1A1A),
                            ),
                            obscureText: !_showPassword,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showPassword = !_showPassword),
                          child: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF999999),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Password Confirm (Signup only)
                  if (!_isLogin)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEEEEEE),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            color: Color(0xFFAAAAAA),
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _passwordConfirmController,
                              decoration: const InputDecoration(
                                hintText: 'Confirmer le mot de passe',
                                hintStyle: TextStyle(color: Color(0xFFAAAAAA)),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1A1A1A),
                              ),
                              obscureText: !_showPasswordConfirm,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(
                                () =>
                                    _showPasswordConfirm = !_showPasswordConfirm),
                            child: Icon(
                              _showPasswordConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF999999),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Forgot Password (Login only)
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 22, top: 4),
                        child: Text(
                          'Mot de passe oublié ?',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                  // Action Button
                  Container(
                    height: 58,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B00),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B00).withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading
                            ? null
                            : (_isLogin ? _handleSignIn : _handleSignUp),
                        borderRadius: BorderRadius.circular(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              Text(
                                _isLogin
                                    ? 'Se connecter'
                                    : 'Créer mon compte',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            if (!_isLoading) const SizedBox(width: 12),
                            if (!_isLoading)
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Terms
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      children: [
                        const Text(
                          'En vous connectant, vous acceptez nos',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: const [
                            Text(
                              'Conditions d\'utilisation',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFFF6B00),
                              ),
                            ),
                            Text(
                              ' et notre ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF888888),
                              ),
                            ),
                            Text(
                              'Politique de confidentialité.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFFF6B00),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneConfirmController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}