// lib/ui/screens/assessment/goal_skills_list_screen.dart
import 'package:flutter/material.dart';
import '../../../models/app_models.dart';
import '../../../services/auth_service.dart';
import '../../widgets/skill_group_widget.dart';
import 'adaptive_test_screen.dart';

class GoalSkillsListScreen extends StatefulWidget {
  final GoalAssessmentIntro intro;
  const GoalSkillsListScreen({super.key, required this.intro});

  @override
  State<GoalSkillsListScreen> createState() => _GoalSkillsListScreenState();
}

class _GoalSkillsListScreenState extends State<GoalSkillsListScreen> {
  final Map<String, bool> _expandedGroups = {};
  final Map<String, bool> _expandedSubgroups = {};

  @override
  void initState() {
    super.initState();
    // Инициализируем все группы как свернутые
    for (String group in widget.intro.groupedSkills.keys) {
      _expandedGroups[group] = false;
    }
    
    // Инициализируем подгруппы
    for (var skill in widget.intro.skillsToAssess) {
      if (skill.subcategory != null) {
        _expandedSubgroups[skill.subcategory!] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;
    final groupedSkills = widget.intro.groupedSkills;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations.get('skillsForGoal')}: ${widget.intro.goalName}'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Заголовок с основной информацией
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.get('assessSkillsPrompt'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.intro.primarySkill.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${localizations.get('primarySkill')}: ${widget.intro.primarySkill}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${widget.intro.skillsToAssess.length} ${localizations.get('skillsToAssess')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Список навыков с группировкой
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedSkills.length,
              itemBuilder: (context, index) {
                final groupName = groupedSkills.keys.elementAt(index);
                final skills = groupedSkills[groupName]!;
                final isExpanded = _expandedGroups[groupName] ?? false;
                
                return SkillGroupWidget(
                  groupName: groupName,
                  skills: skills,
                  isExpanded: isExpanded,
                  onToggle: () {
                    setState(() {
                      _expandedGroups[groupName] = !isExpanded;
                    });
                  },
                  onSkillTap: (skill) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AdaptiveTestScreen(skillName: skill.name),
                    ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}