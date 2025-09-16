// lib/ui/screens/skills_profile_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'assessment/adaptive_test_screen.dart';

class SkillsProfileScreen extends StatefulWidget {
  const SkillsProfileScreen({super.key});
  @override
  State<SkillsProfileScreen> createState() => _SkillsProfileScreenState();
}

class _SkillsProfileScreenState extends State<SkillsProfileScreen> {
  Future<UserProfile>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = apiService.fetchProfile();
    });
  }

  Future<void> _startSkillTest(String skillName) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdaptiveTestScreen(skillName: skillName)),
    );
    if (result == true && mounted) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('mySkillsProfileTitle'))),
      drawer: const AppDrawer(),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async => _loadProfile(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (profile.skillGroups.isEmpty)
                    Center(child: Text(localizations.get('noSkillsTested'))),
                  ...profile.skillGroups.map((group) => ExpansionTile(
                        title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        initiallyExpanded: true,
                        children: group.skills.map((skill) => Card(
                              child: ListTile(
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${skill.score}%', style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text(
                                      skill.progressDescription ?? skill.level, 
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                title: Text(skill.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${localizations.get('lastTested')} ${skill.lastTested ?? localizations.get('never')}'),
                                    if (skill.progressToNext != null && skill.nextLevel != null)
                                      Text(
                                        'Прогресс до ${skill.nextLevel}: ${skill.progressToNext}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: TextButton(
                                  child: Text(localizations.get('retest')),
                                  onPressed: () => _startSkillTest(skill.name),
                                ),
                              ),
                            )).toList(),
                      )),
                ],
              ),
            );
          }
          return const Center(child: Text('No profile data.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/assessment'),
        label: Text(localizations.get('newAssessment')),
        icon: const Icon(Icons.add),
      ),
    );
  }
}