// lib/ui/screens/placeholder_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: Center(
        child: Text(
          'This is the $title screen.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}