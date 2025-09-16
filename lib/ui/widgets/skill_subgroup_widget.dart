// lib/ui/widgets/skill_subgroup_widget.dart
import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class SkillSubgroupWidget extends StatelessWidget {
  final String subcategory;
  final List<SkillToAssess> skills;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(SkillToAssess) onSkillTap;

  const SkillSubgroupWidget({
    super.key,
    required this.subcategory,
    required this.skills,
    required this.isExpanded,
    required this.onToggle,
    required this.onSkillTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Заголовок подгруппы
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getSubcategoryIcon(subcategory),
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subcategory,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Text(
                    '${skills.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          
          // Список навыков в подгруппе
          if (isExpanded)
            ...skills.map((skill) => _buildSkillTile(context, skill)),
        ],
      ),
    );
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            _getSkillIcon(skill.name),
            color: Theme.of(context).primaryColor,
            size: 16,
          ),
        ),
        title: Text(
          skill.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: skill.subskills.isNotEmpty
            ? Wrap(
                spacing: 4,
                runSpacing: 2,
                children: skill.subskills.take(2).map((subskill) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      subskill,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ).toList(),
              )
            : null,
        trailing: ElevatedButton(
          onPressed: () => onSkillTap(skill),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            textStyle: const TextStyle(fontSize: 10),
            minimumSize: const Size(60, 28),
          ),
          child: const Text('Тест'),
        ),
      ),
    );
  }

  IconData _getSubcategoryIcon(String subcategory) {
    switch (subcategory.toLowerCase()) {
      case 'backend languages':
        return Icons.dns;
      case 'frontend languages':
        return Icons.web;
      case 'relational databases':
        return Icons.table_chart;
      case 'nosql databases':
        return Icons.cloud_queue;
      case 'data structures':
        return Icons.account_tree;
      case 'algorithms':
        return Icons.psychology;
      case 'architecture patterns':
        return Icons.architecture;
      case 'scalability':
        return Icons.trending_up;
      case 'rest apis':
        return Icons.api;
      case 'graphql':
        return Icons.query_stats;
      default:
        return Icons.folder;
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
