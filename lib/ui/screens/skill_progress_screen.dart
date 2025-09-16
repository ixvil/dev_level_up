// lib/ui/screens/skill_progress_screen.dart

import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';

class SkillProgressScreen extends StatefulWidget {
  final String matrixId;
  final String skillId;

  const SkillProgressScreen({
    Key? key,
    required this.matrixId,
    required this.skillId,
  }) : super(key: key);

  @override
  State<SkillProgressScreen> createState() => _SkillProgressScreenState();
}

class _SkillProgressScreenState extends State<SkillProgressScreen> {
  DynamicSkill? _skill;
  SkillProgressRecord? _currentProgress;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
  String _selectedLevel = 'Beginner';
  final List<String> _selectedCriteria = [];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSkillData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSkillData() async {
    setState(() => _isLoading = true);
    
    try {
      final skillDetails = await apiService.getDynamicSkillDetails(widget.matrixId, widget.skillId);
      
      if (skillDetails['skill'] == null) {
        throw Exception('Skill data is null');
      }
      
      final skill = DynamicSkill.fromJson(skillDetails['skill']);
      final progress = skillDetails['progress'] != null 
          ? SkillProgressRecord.fromJson(skillDetails['progress'])
          : null;
      
      setState(() {
        _skill = skill;
        _currentProgress = progress;
        if (progress != null) {
          _selectedLevel = progress.currentLevel;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProgress() async {
    if (_skill == null) return;

    setState(() => _isLoading = true);
    
    try {
      await apiService.updateSkillProgress(
        matrixId: widget.matrixId,
        skillId: widget.skillId,
        newLevel: _selectedLevel,
        completedCriteria: _selectedCriteria,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Прогресс обновлен успешно!')),
        );
        Navigator.pop(context, true); // Возвращаем true для обновления
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _skill == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ошибка')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[600]),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadSkillData,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_skill == null) {
      return const Scaffold(
        body: Center(child: Text('Навык не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_skill!.name),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о навыке
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _skill!.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_skill!.description),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text(_skill!.category),
                          backgroundColor: _getCategoryColor(_skill!.category).withOpacity(0.1),
                          labelStyle: TextStyle(color: _getCategoryColor(_skill!.category)),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(_skill!.priority),
                          backgroundColor: _getPriorityColor(_skill!.priority).withOpacity(0.1),
                          labelStyle: TextStyle(color: _getPriorityColor(_skill!.priority)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Текущий прогресс
            if (_currentProgress != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Текущий прогресс',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Уровень: '),
                          Text(
                            _currentProgress!.currentLevel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _currentProgress!.progressPercentage / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                      const SizedBox(height: 4),
                      Text('${_currentProgress!.progressPercentage.toStringAsFixed(1)}% завершено'),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),

            // Обновление прогресса
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Обновить прогресс',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Выбор уровня
                    Text('Новый уровень:'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLevel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _levels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value!;
                          _selectedCriteria.clear(); // Очищаем критерии при смене уровня
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Критерии для выбранного уровня
                    Text('Выполненные критерии:'),
                    const SizedBox(height: 8),
                    ..._getCriteriaForLevel(_selectedLevel).map((criterion) {
                      return CheckboxListTile(
                        title: Text(criterion),
                        value: _selectedCriteria.contains(criterion),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedCriteria.add(criterion);
                            } else {
                              _selectedCriteria.remove(criterion);
                            }
                          });
                        },
                      );
                    }).toList(),
                    
                    const SizedBox(height: 16),
                    
                    // Заметки
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Заметки (необязательно)',
                        border: OutlineInputBorder(),
                        hintText: 'Добавьте заметки о прогрессе...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),

            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProgress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Сохранить прогресс',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCriteriaForLevel(String level) {
    if (_skill == null) return [];
    
    final levelData = _skill!.levels.firstWhere(
      (l) => l.level == level,
      orElse: () =>       SkillLevel(
        level: level,
        description: '',
        criteria: [],
      ),
    );
    
    return levelData.criteria;
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
