// lib/ui/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<DashboardData>? _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    setState(() {
      _dashboardFuture = apiService.fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('dashboard'))),
      drawer: const AppDrawer(),
      body: FutureBuilder<DashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading dashboard: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No dashboard data available.'));
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionCard(
                  context,
                  title: localizations.get('strongestSkills'),
                  icon: Icons.star,
                  color: Colors.amber,
                  items: data.strongestSkills
                      .map((s) => s.progressDescription ?? '${s.name} (${s.score}%)')
                      .toList(),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  context,
                  title: localizations.get('weakestSkills'),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                  items: data.weakestSkills
                      .map((s) => s.progressDescription ?? '${s.name} (${s.score}%)')
                      .toList(),
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  context,
                  title: localizations.get('latestGoals'),
                  icon: Icons.flag,
                  color: Colors.green,
                  items: data.latestGoals
                      .map((g) =>
                          '${g.name} (${g.matchPercentage}% ${localizations.get('match')})')
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required List<String> items}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(height: 20),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No data yet.',
                    style: TextStyle(color: Colors.grey[600])),
              ),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child:
                      Text('• $item', style: Theme.of(context).textTheme.bodyMedium),
                )),
          ],
        ),
      ),
    );
  }
}