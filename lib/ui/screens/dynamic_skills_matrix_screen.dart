// lib/ui/screens/dynamic_skills_matrix_screen.dart

import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';

class DynamicSkillsMatrixScreen extends StatefulWidget {
  final DynamicSkillMatrix matrix;

  const DynamicSkillsMatrixScreen({
    Key? key,
    required this.matrix,
  }) : super(key: key);

  @override
  State<DynamicSkillsMatrixScreen> createState() => _DynamicSkillsMatrixScreenState();
}

class _DynamicSkillsMatrixScreenState extends State<DynamicSkillsMatrixScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SkillProgress? _skillProgress;
  List<SkillRecommendation>? _recommendations;
  LearningRoadmap? _roadmap;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final progress = await apiService.getSkillProgress(widget.matrix.id);
      final recommendations = await apiService.getSkillRecommendations(widget.matrix.id);
      final roadmap = await apiService.getLearningRoadmap(widget.matrix.id);
      
      setState(() {
        _skillProgress = progress;
        _recommendations = recommendations;
        _roadmap = roadmap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки данных: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matrix.careerGoal),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.grid_view), text: 'Навыки'),
            Tab(icon: Icon(Icons.trending_up), text: 'Прогресс'),
            Tab(icon: Icon(Icons.lightbulb), text: 'Рекомендации'),
            Tab(icon: Icon(Icons.route), text: 'Дорожная карта'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSkillsTab(),
                _buildProgressTab(),
                _buildRecommendationsTab(),
                _buildRoadmapTab(),
              ],
            ),
    );
  }

  Widget _buildSkillsTab() {
    final skills = widget.matrix.skillMatrixData.skills;
    final groupedSkills = _groupSkillsByCategory(skills);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общая информация
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600]),
                      const SizedBox(width: 12),
                      Text(
                        'Информация о матрице',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Всего навыков', '${skills.length}'),
                  _buildInfoRow('Время обучения', widget.matrix.skillMatrixData.estimatedTotalTime),
                  _buildInfoRow('Версия', widget.matrix.version),
                  _buildInfoRow('Создано', _formatDate(widget.matrix.generatedAt)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Навыки по категориям
          ...groupedSkills.entries.map((entry) {
            return _buildSkillCategory(entry.key, entry.value);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_skillProgress == null) {
      return const Center(child: Text('Прогресс не загружен'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общий прогресс
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.green[600]),
                      const SizedBox(width: 12),
                      Text(
                        'Общий прогресс',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: double.tryParse(_skillProgress!.overallProgressPercentage) ?? 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_skillProgress!.overallProgressPercentage}% завершено',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Прогресс по навыкам
          ..._skillProgress!.skillProgress.entries.map((entry) {
            final skillId = entry.key;
            final progress = entry.value;
            final skill = widget.matrix.skillMatrixData.skills
                .firstWhere((s) => s.id == skillId, orElse: () => DynamicSkill(
                      id: skillId,
                      name: 'Unknown Skill',
                      description: '',
                      category: 'Core',
                      priority: 'Medium',
                      levels: [],
                      dependencies: [],
                      learningResources: [],
                    ));
            
            return _buildSkillProgressCard(skill, progress);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    if (_recommendations == null || _recommendations!.isEmpty) {
      return const Center(child: Text('Рекомендации не найдены'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _recommendations!.length,
      itemBuilder: (context, index) {
        final recommendation = _recommendations![index];
        return _buildRecommendationCard(recommendation);
      },
    );
  }

  Widget _buildRoadmapTab() {
    if (_roadmap == null || _roadmap!.phases.isEmpty) {
      return const Center(child: Text('Дорожная карта не найдена'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _roadmap!.phases.length,
      itemBuilder: (context, index) {
        final phase = _roadmap!.phases[index];
        return _buildRoadmapPhaseCard(phase, index);
      },
    );
  }

  Map<String, List<DynamicSkill>> _groupSkillsByCategory(List<DynamicSkill> skills) {
    final Map<String, List<DynamicSkill>> grouped = {};
    for (final skill in skills) {
      if (!grouped.containsKey(skill.category)) {
        grouped[skill.category] = [];
      }
      grouped[skill.category]!.add(skill);
    }
    return grouped;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCategory(String category, List<DynamicSkill> skills) {
    Color categoryColor;
    IconData categoryIcon;
    
    switch (category) {
      case 'Core':
        categoryColor = Colors.red[600]!;
        categoryIcon = Icons.star;
        break;
      case 'Supporting':
        categoryColor = Colors.orange[600]!;
        categoryIcon = Icons.support;
        break;
      case 'Emerging':
        categoryColor = Colors.purple[600]!;
        categoryIcon = Icons.trending_up;
        break;
      default:
        categoryColor = Colors.grey[600]!;
        categoryIcon = Icons.category;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryIcon, color: categoryColor),
                const SizedBox(width: 12),
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${skills.length}'),
                  backgroundColor: categoryColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: categoryColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...skills.map((skill) => _buildSkillCard(skill)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard(DynamicSkill skill) {
    Color priorityColor;
    switch (skill.priority) {
      case 'High':
        priorityColor = Colors.red[600]!;
        break;
      case 'Medium':
        priorityColor = Colors.orange[600]!;
        break;
      case 'Low':
        priorityColor = Colors.green[600]!;
        break;
      default:
        priorityColor = Colors.grey[600]!;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(
          skill.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(skill.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(skill.priority),
                  backgroundColor: priorityColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: priorityColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${skill.levels.length} уровней',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Показываем диалог выбора действия
                  _showSkillActionDialog(skill);
                },
      ),
    );
  }

  Widget _buildSkillProgressCard(DynamicSkill skill, SkillProgressRecord progress) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    skill.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  progress.currentLevel,
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.progressPercentage / 100.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.progressPercentage.toStringAsFixed(1)}% завершено',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(SkillRecommendation recommendation) {
    Color priorityColor;
    switch (recommendation.priority) {
      case 'High':
        priorityColor = Colors.red[600]!;
        break;
      case 'Medium':
        priorityColor = Colors.orange[600]!;
        break;
      case 'Low':
        priorityColor = Colors.green[600]!;
        break;
      default:
        priorityColor = Colors.grey[600]!;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: priorityColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recommendation.skillName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(recommendation.priority),
                  backgroundColor: priorityColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: priorityColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(recommendation.reason),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapPhaseCard(RoadmapPhase phase, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: phase.isCompleted 
                      ? Colors.green[600] 
                      : phase.isCurrent 
                          ? Colors.blue[600] 
                          : Colors.grey[400],
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.phase,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        phase.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (phase.isCompleted)
                  Icon(Icons.check_circle, color: Colors.green[600])
                else if (phase.isCurrent)
                  Icon(Icons.play_circle, color: Colors.blue[600]),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.school, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${phase.skills.length} навыков',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  void _showSkillActionDialog(DynamicSkill skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(skill.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Что вы хотите сделать с этим навыком?',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/skill-progress',
                arguments: {
                  'matrixId': widget.matrix.id,
                  'skillId': skill.id,
                },
              );
            },
            child: const Text('Просмотр прогресса'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                '/start-learning',
                arguments: {
                  'matrix': widget.matrix,
                  'skill': skill,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Начать обучение'),
          ),
        ],
      ),
    );
  }
}
