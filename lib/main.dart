// lib/main.dart
import 'package:flutter/material.dart'; // <-- ИСПРАВЛЕНИЕ: package:
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}