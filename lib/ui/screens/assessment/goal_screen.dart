// lib/ui/screens/assessment/goal_screen.dart
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/app_drawer.dart';
import 'goal_skills_list_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});
  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final _goalController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Больше не проверяем авторизацию - работаем с device_id
    if (mounted) {
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  Future<void> _startGoalAssessment() async {
    if (_goalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authService.localizations.get('pleaseDescribeGoal'))));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final intro = await apiService.startGoalAssessment(_goalController.text);
      if (mounted) {
        // Проверяем, что intro содержит валидные данные
        if (intro.skillsToAssess.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No skills found for this goal. Please try again.')));
          return;
        }
        
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => GoalSkillsListScreen(intro: intro)));
      }
    } catch (e) {
      if (mounted) {
        print('Error in _startGoalAssessment: $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Больше не показываем загрузку авторизации
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final localizations = authService.localizations;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('newAssessment'))),
      drawer: const AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(localizations.get('whatToTest'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                  controller: _goalController,
                  decoration: InputDecoration(
                      hintText: localizations.get('goalHint'),
                      border: const OutlineInputBorder())),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _startGoalAssessment,
                      child: Text(localizations.get('generateTest'))),
            ],
          ),
        ),
      ),
    );
  }
}