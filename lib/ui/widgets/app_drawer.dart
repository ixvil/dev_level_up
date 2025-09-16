// lib/ui/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text('DevLevelUp User'),
            accountEmail: Text(localizations.get('welcome')),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("D"),
            ),
          ),
          ListTile(leading: const Icon(Icons.dashboard_outlined), title: Text(localizations.get('dashboard')), onTap: () => Navigator.pushReplacementNamed(context, '/dashboard')),
          ListTile(leading: const Icon(Icons.quiz_outlined), title: Text(localizations.get('newAssessment')), onTap: () => Navigator.pushReplacementNamed(context, '/assessment')),
          const Divider(),
          ListTile(leading: const Icon(Icons.psychology_outlined), title: Text(localizations.get('mySkills')), onTap: () => Navigator.pushReplacementNamed(context, '/skills')),
          ListTile(leading: const Icon(Icons.flag_outlined), title: Text(localizations.get('myGoals')), onTap: () => Navigator.pushReplacementNamed(context, '/goals')),
          ListTile(leading: const Icon(Icons.auto_awesome), title: const Text('AI Skill Matrix'), onTap: () => Navigator.pushReplacementNamed(context, '/dynamic-skills-generation')),
          const Divider(),
        ],
      ),
    );
  }
}