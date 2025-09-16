// lib/app.dart
import 'package:flutter/material.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/skills_profile_screen.dart';
import 'ui/screens/assessment/goal_screen.dart';
import 'ui/screens/welcome_screen.dart';
import 'ui/screens/goals_screen.dart';
import 'ui/screens/quick_assessment_screen.dart';
import 'ui/screens/adaptive_assessment_screen.dart';
import 'ui/screens/position_selection_screen.dart';
import 'ui/screens/dynamic_skills_generation_screen.dart';
import 'ui/screens/dynamic_skills_matrix_screen.dart';
import 'ui/screens/skill_progress_screen.dart';
import 'ui/screens/start_learning_screen.dart';
import 'ui/screens/interactive_learning_screen.dart';
import 'models/app_models.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevLevelUp',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true, scaffoldBackgroundColor: Colors.grey[50]),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/skills': (context) => const SkillsProfileScreen(),
        '/assessment': (context) => const GoalScreen(),
        '/dashboard': (context) => const WelcomeScreen(),
        '/goals': (context) => const GoalsScreen(),
        '/quick-assessment': (context) => const QuickAssessmentScreen(),
        '/adaptive-assessment': (context) => const AdaptiveAssessmentScreen(
          userGoal: 'Learn programming',
          experienceLevel: 'Beginner',
        ),
        '/position-selection': (context) => const PositionSelectionScreen(userId: 1),
        '/dynamic-skills-generation': (context) => const DynamicSkillsGenerationScreen(),
        '/dynamic-skills-matrix': (context) {
          final matrix = ModalRoute.of(context)!.settings.arguments as DynamicSkillMatrix;
          return DynamicSkillsMatrixScreen(matrix: matrix);
        },
        '/skill-progress': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return SkillProgressScreen(
            matrixId: args['matrixId']!,
            skillId: args['skillId']!,
          );
        },
        '/start-learning': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return StartLearningScreen(
            matrix: args['matrix'] as DynamicSkillMatrix,
            skill: args['skill'] as DynamicSkill,
          );
        },
        '/interactive-learning': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return InteractiveLearningScreen(
            sessionId: args['sessionId'] as int,
            question: args['question'] as Map<String, dynamic>,
            matrix: args['matrix'] as DynamicSkillMatrix,
            skill: args['skill'] as DynamicSkill,
          );
        },
      },
    );
  }
}