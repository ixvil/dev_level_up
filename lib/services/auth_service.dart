// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../l10n/app_localizations.dart';

class AuthService {
  AuthUser? currentUser;
  late AppLocalizations localizations;

  AuthUser? get user => currentUser;

  AuthService() {
    localizations = AppLocalizations('en'); // Default language
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      return false;
    }
    currentUser = AuthUser(
      id: userId,
      username: prefs.getString('username')!,
      language: prefs.getString('language')!,
    );
    localizations = AppLocalizations(currentUser!.language);                                
    return true;
  }

  Future<void> saveUser(AuthUser user) async {
    currentUser = user;
    localizations = AppLocalizations(user.language);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('language', user.language);
  }

  Future<void> logout() async {
    currentUser = null;
    localizations = AppLocalizations('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// Создаем глобальный экземпляр для легкого доступа из любого виджета
final authService = AuthService();