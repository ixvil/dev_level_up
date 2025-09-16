// lib/ui/widgets/skill_group_widget.dart
import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import 'skill_subgroup_widget.dart';

class SkillGroupWidget extends StatelessWidget {
  final String groupName;
  final List<SkillToAssess> skills;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(SkillToAssess) onSkillTap;

  const SkillGroupWidget({
    super.key,
    required this.groupName,
    required this.skills,
    required this.isExpanded,
    required this.onToggle,
    required this.onSkillTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Заголовок группы
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getGroupIcon(groupName),
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          '${skills.length} навыков',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          
          // Список навыков в группе
          if (isExpanded)
            _buildSkillsContent(context),
        ],
      ),
    );
  }

  Widget _buildSkillsContent(BuildContext context) {
    // Группируем навыки по подкатегориям
    Map<String, List<SkillToAssess>> subgroups = {};
    List<SkillToAssess> skillsWithoutSubcategory = [];
    
    for (var skill in skills) {
      if (skill.subcategory != null && skill.subcategory!.isNotEmpty) {
        if (!subgroups.containsKey(skill.subcategory)) {
          subgroups[skill.subcategory!] = [];
        }
        subgroups[skill.subcategory!]!.add(skill);
      } else {
        skillsWithoutSubcategory.add(skill);
      }
    }
    
    List<Widget> widgets = [];
    
    // Добавляем подгруппы
    for (var entry in subgroups.entries) {
      widgets.add(
        SkillSubgroupWidget(
          subcategory: entry.key,
          skills: entry.value,
          isExpanded: true, // Можно сделать настраиваемым
          onToggle: () {}, // Можно добавить логику сворачивания
          onSkillTap: onSkillTap,
        ),
      );
    }
    
    // Добавляем навыки без подкатегории
    for (var skill in skillsWithoutSubcategory) {
      widgets.add(_buildSkillTile(context, skill));
    }
    
    return Column(children: widgets);
  }

  Widget _buildSkillTile(BuildContext context, SkillToAssess skill) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getSkillIcon(skill.name),
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          skill.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (skill.subcategory != null)
              Text(
                skill.subcategory!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            if (skill.subskills.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: skill.subskills.take(3).map((subskill) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      subskill,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ).toList(),
              ),
          ],
        ),
        trailing: ElevatedButton.icon(
          onPressed: () => onSkillTap(skill),
          icon: const Icon(Icons.play_arrow, size: 16),
          label: const Text('Начать тест'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  IconData _getGroupIcon(String groupName) {
    switch (groupName.toLowerCase()) {
      case 'programming languages':
        return Icons.code;
      case 'databases':
        return Icons.storage;
      case 'algorithms & data structures':
        return Icons.psychology;
      case 'system design & architecture':
        return Icons.architecture;
      case 'apis & integration':
        return Icons.api;
      default:
        return Icons.category;
    }
  }

  IconData _getSkillIcon(String skillName) {
    switch (skillName.toLowerCase()) {
      case 'python':
        return Icons.code;
      case 'javascript':
        return Icons.javascript;
      case 'java':
        return Icons.code;
      case 'php':
        return Icons.php;
      case 'c#':
        return Icons.code;
      case 'typescript':
        return Icons.code;
      case 'mysql':
        return Icons.storage;
      case 'postgresql':
        return Icons.storage;
      case 'mongodb':
        return Icons.storage;
      case 'redis':
        return Icons.storage;
      case 'elasticsearch':
        return Icons.search;
      case 'basic structures':
        return Icons.account_tree;
      case 'advanced structures':
        return Icons.account_tree;
      case 'sorting':
        return Icons.sort;
      case 'searching':
        return Icons.search;
      case 'dynamic programming':
        return Icons.psychology;
      case 'monolithic':
        return Icons.home;
      case 'microservices':
        return Icons.apps;
      case 'serverless':
        return Icons.cloud;
      case 'horizontal scaling':
        return Icons.trending_up;
      case 'performance':
        return Icons.speed;
      case 'rest apis design':
        return Icons.api;
      case 'rest apis implementation':
        return Icons.api;
      case 'graphql':
        return Icons.query_stats;
      default:
        return Icons.extension;
    }
  }
}
