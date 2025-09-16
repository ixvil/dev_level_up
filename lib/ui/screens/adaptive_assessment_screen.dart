// lib/ui/screens/adaptive_assessment_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class AdaptiveAssessmentScreen extends StatefulWidget {
  final String userGoal;
  final String experienceLevel;

  const AdaptiveAssessmentScreen({
    super.key,
    required this.userGoal,
    required this.experienceLevel,
  });

  @override
  State<AdaptiveAssessmentScreen> createState() => _AdaptiveAssessmentScreenState();
}

class _AdaptiveAssessmentScreenState extends State<AdaptiveAssessmentScreen> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _assessmentResult;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _startAssessment();
  }

  void _startAssessment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Start goal assessment with Gemini
      final result = await _apiService.startGoalAssessmentSimple(widget.userGoal);
      if (result != null) {
        setState(() {
          _assessmentResult = result;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to start assessment';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;

    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment: ${widget.userGoal}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _buildBody(localizations),
    );
  }

  Widget _buildBody(dynamic localizations) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Starting assessment...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startAssessment,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_assessmentResult != null) {
      return _buildAssessmentResult(localizations);
    }

    return const Center(
      child: Text('No assessment data available'),
    );
  }

  Widget _buildAssessmentResult(dynamic localizations) {
    final goalName = _assessmentResult!['goal_name'] ?? 'Unknown Goal';
    final skillsToAssess = _assessmentResult!['skills_to_assess'] as List? ?? [];
    final primarySkill = _assessmentResult!['primary_skill'] ?? 'Unknown';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assessment Complete!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Goal: $goalName',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Primary Skill: $primarySkill',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Skills to Assess
          Text(
            'Skills to Assess',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...skillsToAssess.map((skill) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(
                  Icons.psychology_outlined,
                  color: Colors.blue[600],
                ),
              ),
              title: Text(skill['name'] ?? 'Unknown Skill'),
              subtitle: Text('Group: ${skill['group'] ?? 'General'}'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Navigate to skill assessment
                  Navigator.pushNamed(
                    context,
                    '/assessment',
                    arguments: {'skill_name': skill['name']},
                  );
                },
                child: const Text('Assess'),
              ),
            ),
          )),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/dashboard');
                  },
                  icon: const Icon(Icons.dashboard_outlined),
                  label: const Text('Go to Dashboard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/goals');
                  },
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('View Goals'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}