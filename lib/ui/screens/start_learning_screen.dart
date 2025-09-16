// lib/ui/screens/start_learning_screen.dart

import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';

class StartLearningScreen extends StatefulWidget {
  final DynamicSkillMatrix matrix;
  final DynamicSkill skill;

  const StartLearningScreen({
    Key? key,
    required this.matrix,
    required this.skill,
  }) : super(key: key);

  @override
  State<StartLearningScreen> createState() => _StartLearningScreenState();
}

class _StartLearningScreenState extends State<StartLearningScreen> {
  String _selectedTargetLevel = 'Intermediate';
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _availableLevels = [
    'Beginner',
    'Intermediate', 
    'Advanced',
    'Expert'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Начать обучение'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о навыке
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getSkillIcon(widget.skill.category),
                          size: 32,
                          color: _getCategoryColor(widget.skill.category),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.skill.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.skill.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Chip(
                          label: Text(widget.skill.category),
                          backgroundColor: _getCategoryColor(widget.skill.category).withOpacity(0.1),
                          labelStyle: TextStyle(color: _getCategoryColor(widget.skill.category)),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(widget.skill.priority),
                          backgroundColor: _getPriorityColor(widget.skill.priority).withOpacity(0.1),
                          labelStyle: TextStyle(color: _getPriorityColor(widget.skill.priority)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Выбор целевого уровня
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Выберите целевой уровень',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'До какого уровня вы хотите развить этот навык?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Уровни навыков
                    ..._availableLevels.map((level) {
                      final isSelected = _selectedTargetLevel == level;
                      final isCurrentLevel = widget.skill.levels.any((l) => l.level == level);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedTargetLevel = level;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected ? Colors.blue[50] : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  color: isSelected ? Colors.blue[600] : Colors.grey[400],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        level,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.blue[600] : Colors.black87,
                                        ),
                                      ),
                                      if (isCurrentLevel)
                                        Text(
                                          'Текущий уровень',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.blue[600],
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Информация о процессе обучения
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.purple[600],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Как работает обучение',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildFeatureItem(
                      Icons.psychology,
                      'AI-генерация заданий',
                      'Система создает персонализированные задания на основе вашего уровня и целей',
                    ),
                    
                    _buildFeatureItem(
                      Icons.trending_up,
                      'Адаптивная сложность',
                      'Сложность заданий автоматически подстраивается под ваш прогресс',
                    ),
                    
                    _buildFeatureItem(
                      Icons.feedback,
                      'Мгновенная обратная связь',
                      'Получайте детальную обратную связь и рекомендации после каждого ответа',
                    ),
                    
                    _buildFeatureItem(
                      Icons.analytics,
                      'Отслеживание прогресса',
                      'Ваши навыки обновляются в реальном времени на основе результатов',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Кнопка начала обучения
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _startLearning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_arrow, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Начать обучение',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startLearning() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await apiService.startLearningSession(
        matrixId: widget.matrix.id,
        skillId: widget.skill.id,
        targetLevel: _selectedTargetLevel,
      );

      if (mounted) {
        // Переходим к экрану обучения
        Navigator.pushReplacementNamed(
          context,
          '/interactive-learning',
          arguments: {
            'sessionId': result['session_id'],
            'question': result['question'],
            'matrix': widget.matrix,
            'skill': widget.skill,
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  IconData _getSkillIcon(String category) {
    switch (category) {
      case 'Core':
        return Icons.code;
      case 'Supporting':
        return Icons.build;
      case 'Emerging':
        return Icons.trending_up;
      default:
        return Icons.school;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Core':
        return Colors.red[600]!;
      case 'Supporting':
        return Colors.orange[600]!;
      case 'Emerging':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red[600]!;
      case 'Medium':
        return Colors.orange[600]!;
      case 'Low':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
