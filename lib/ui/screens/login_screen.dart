// lib/ui/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

// Создаем глобальный экземпляр ApiService для доступа к методам API
final apiService = ApiService();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  bool _isRegistering = false;

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);

    try {
      final user = _isRegistering
          ? await apiService.register(_usernameController.text, _passwordController.text, _selectedLanguage)
          : await apiService.login(_usernameController.text, _passwordController.text);
      
      await authService.saveUser(user);

      if (mounted) {
        // For new users (registration), go to new assessment screen
        // For existing users (login), go to dashboard
        if (_isRegistering) {
          Navigator.of(context).pushReplacementNamed('/assessment');
        } else {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('welcome'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _usernameController, decoration: InputDecoration(labelText: localizations.get('username'))),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: localizations.get('password')), obscureText: true),
            if (_isRegistering) ...[
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(labelText: localizations.get('selectLanguage'), border: const OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ru', child: Text('Русский')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ],
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(onPressed: _handleAuth, child: Text(_isRegistering ? localizations.get('register') : localizations.get('login'))),
                  TextButton(
                    onPressed: () => setState(() => _isRegistering = !_isRegistering),
                    child: Text(_isRegistering ? localizations.get('login') : localizations.get('register')),
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}