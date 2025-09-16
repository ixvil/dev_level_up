// lib/ui/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/auth_service.dart';
import '../widgets/app_drawer.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<WelcomeData>? _welcomeDataFuture;

  @override
  void initState() {
    super.initState();
    _loadWelcomeData();
  }

  void _loadWelcomeData() {
    setState(() {
      _welcomeDataFuture = _fetchWelcomeData();
    });
  }

  Future<WelcomeData> _fetchWelcomeData() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return WelcomeData(
      user: AuthUser(id: 1, username: 'DevLevelUp User', language: 'en'),
      isNewUser: true, // Always new user for device-based auth
      hasCompletedAssessment: false, // Mock check
      recentProgress: null, // Removed progress tracking
      recommendations: _getMockRecommendations(),
      quickActions: _getMockQuickActions(),
    );
  }

  List<Recommendation> _getMockRecommendations() {
    return [
      Recommendation(
        title: "Complete your Python assessment",
        description: "You're 80% ready for the next level",
        type: "assessment",
        priority: "high",
        action: "Start Assessment",
      ),
    ];
  }

  List<QuickAction> _getMockQuickActions() {
    return [
      QuickAction(
        title: "AI Skill Matrix",
        description: "Generate personalized skill matrix",
        icon: Icons.auto_awesome,
        color: Colors.purple,
        route: '/dynamic-skills-generation',
      ),
      QuickAction(
        title: "Position Assessment",
        description: "Test skills for specific position",
        icon: Icons.work_outline,
        color: Colors.green,
        route: '/position-selection',
      ),
      QuickAction(
        title: "New Assessment",
        description: "Test your skills",
        icon: Icons.quiz_outlined,
        color: Colors.blue,
        route: '/assessment',
      ),
      QuickAction(
        title: "Quick Test",
        description: "5-minute skill check",
        icon: Icons.flash_on_outlined,
        color: Colors.orange,
        route: '/quick-assessment',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.get('dashboard')),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<WelcomeData>(
        future: _welcomeDataFuture,
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
                  Text('Error loading data: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWelcomeData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
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
                        'Welcome back, DevLevelUp User!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.isNewUser 
                          ? 'Let\'s start your learning journey!'
                          : 'Ready to continue learning?',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: data.quickActions.length,
                  itemBuilder: (context, index) {
                    final action = data.quickActions[index];
                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, action.route),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                action.icon,
                                size: 32,
                                color: action.color,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                action.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                action.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Recommendations
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...data.recommendations.map((rec) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: rec.priority == 'high' 
                        ? Colors.red[100] 
                        : Colors.blue[100],
                      child: Icon(
                        rec.type == 'assessment' 
                          ? Icons.quiz_outlined 
                          : Icons.school_outlined,
                        color: rec.priority == 'high' 
                          ? Colors.red[600] 
                          : Colors.blue[600],
                      ),
                    ),
                    title: Text(rec.title),
                    subtitle: Text(rec.description),
                    trailing: TextButton(
                      onPressed: () {
                        // Handle action
                      },
                      child: Text(rec.action),
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}