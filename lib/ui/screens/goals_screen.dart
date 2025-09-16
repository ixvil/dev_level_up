// lib/ui/screens/goals_screen.dart
import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  Future<UserProfile>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() {
    setState(() {
      _profileFuture = apiService.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.get('myGoals')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoals,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading goals: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadGoals,
                    child: Text(localizations.get('retry')),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data available.'));
          }

          final profile = snapshot.data!;
          final goals = profile.goals;

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    localizations.get('noGoalsYet'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.get('createFirstGoal'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/assessment');
                    },
                    icon: const Icon(Icons.add),
                    label: Text(localizations.get('createGoal')),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadGoals(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getMatchColor(goal.matchPercentage),
                      child: Text(
                        '${goal.matchPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      goal.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${localizations.get('match')}: ${goal.matchPercentage}%',
                    ),
                    trailing: Icon(
                      _getMatchIcon(goal.matchPercentage),
                      color: _getMatchColor(goal.matchPercentage),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${localizations.get('goalDetails')}: ${goal.name}'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/assessment');
        },
        child: const Icon(Icons.add),
        tooltip: localizations.get('createGoal'),
      ),
    );
  }

  Color _getMatchColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getMatchIcon(int percentage) {
    if (percentage >= 80) return Icons.check_circle;
    if (percentage >= 60) return Icons.warning;
    return Icons.error;
  }
}
