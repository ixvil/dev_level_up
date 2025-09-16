// lib/ui/screens/interactive_learning_screen.dart

import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';

class InteractiveLearningScreen extends StatefulWidget {
  final int sessionId;
  final Map<String, dynamic> question;
  final DynamicSkillMatrix matrix;
  final DynamicSkill skill;

  const InteractiveLearningScreen({
    Key? key,
    required this.sessionId,
    required this.question,
    required this.matrix,
    required this.skill,
  }) : super(key: key);

  @override
  State<InteractiveLearningScreen> createState() => _InteractiveLearningScreenState();
}

class _InteractiveLearningScreenState extends State<InteractiveLearningScreen> {
  Map<String, dynamic>? _currentQuestion;
  Map<String, dynamic>? _lastEvaluation;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _userAnswer = '';
  String? _selectedOption;
  final _answerController = TextEditingController();

  // Статистика сессии
  int _totalQuestions = 0;
  int _correctAnswers = 0;
  int _currentStreak = 0;
  int _maxStreak = 0;
  String _currentLevel = 'Beginner';

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.question;
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.skill.name),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: _pauseSession,
            tooltip: 'Приостановить',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showProgress,
            tooltip: 'Прогресс',
          ),
        ],
      ),
      body: Column(
        children: [
          // Прогресс-бар
          _buildProgressBar(),
          
          // Основной контент
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentQuestion != null
                    ? _buildQuestionContent()
                    : _buildCompletionScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalQuestions > 0 ? (_correctAnswers / _totalQuestions) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Прогресс: ${_currentLevel}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_correctAnswers}/${_totalQuestions} правильных',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Серия: $_currentStreak',
                style: TextStyle(
                  color: _currentStreak > 0 ? Colors.green[600] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Лучшая серия: $_maxStreak',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    if (_lastEvaluation != null) {
      return _buildEvaluationScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о вопросе
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getQuestionTypeIcon(_currentQuestion!['question_type']),
                        color: Colors.blue[600],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getQuestionTypeTitle(_currentQuestion!['question_type']),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(_currentQuestion!['difficulty_level']),
                        backgroundColor: _getDifficultyColor(_currentQuestion!['difficulty_level']).withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: _getDifficultyColor(_currentQuestion!['difficulty_level']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_currentQuestion!['skill_focus'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Фокус: ${_currentQuestion!['skill_focus']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Текст вопроса
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Вопрос',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentQuestion!['question_text'],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Поле для ответа
          _buildAnswerInput(),

          const SizedBox(height: 24),

          // Кнопка отправки
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting || _userAnswer.trim().isEmpty ? null : _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Отправить ответ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildAnswerInput() {
    final questionType = _currentQuestion!['question_type'];
    
    if (questionType == 'multiple_choice') {
      return _buildMultipleChoiceInput();
    } else {
      return _buildTextInput();
    }
  }

  Widget _buildMultipleChoiceInput() {
    final options = _currentQuestion!['question_data']['options'] as List<dynamic>? ?? [];
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите правильный ответ:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              final isSelected = _selectedOption == option;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedOption = option;
                      _userAnswer = option;
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
                          child: Text(
                            option,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.blue[600] : Colors.black87,
                            ),
                          ),
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
    );
  }

  Widget _buildTextInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ваш ответ:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Введите ваш ответ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _userAnswer = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationScreen() {
    final evaluation = _lastEvaluation!;
    final isCorrect = evaluation['is_correct'] == true;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Результат ответа
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    size: 64,
                    color: isCorrect ? Colors.green[600] : Colors.red[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isCorrect ? 'Правильно!' : 'Не совсем',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green[600] : Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Уровень навыка: ${evaluation['skill_level_demonstrated']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Обратная связь
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Обратная связь',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    evaluation['feedback'] ?? 'Спасибо за ответ!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          // Сильные стороны
          if (evaluation['strengths'] != null && (evaluation['strengths'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Ваши сильные стороны',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(evaluation['strengths'] as List).map((strength) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colors.green[600], size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(strength)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],

          // Рекомендации по улучшению
          if (evaluation['improvement_suggestions'] != null && (evaluation['improvement_suggestions'] as List).isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Рекомендации',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(evaluation['improvement_suggestions'] as List).map((suggestion) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward, color: Colors.blue[600], size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(suggestion)),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Кнопка следующего вопроса
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _loadNextQuestion,
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
                      'Следующий вопрос',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.celebration,
              size: 80,
              color: Colors.green[600],
            ),
            const SizedBox(height: 24),
            Text(
              'Поздравляем!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Вы достигли целевого уровня в навыке "${widget.skill.name}"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Вернуться к матрице навыков',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitAnswer() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final result = await apiService.submitAnswer(
        sessionId: widget.sessionId,
        questionId: _currentQuestion!['question_id'] as int,
        userAnswer: _userAnswer,
        answerData: {
          'time_spent': 0, // TODO: Добавить отслеживание времени
        },
      );

      setState(() {
        _lastEvaluation = result['evaluation'];
        _totalQuestions = result['session_stats']['total_questions'];
        _correctAnswers = result['session_stats']['correct_answers'];
        _currentStreak = result['session_stats']['current_streak'];
        _maxStreak = result['session_stats']['max_streak'];
        _currentLevel = result['session_stats']['current_level'];
      });

      // Если сессия завершена, показываем экран завершения
      if (result['session_completed'] == true) {
        setState(() {
          _currentQuestion = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _loadNextQuestion() async {
    setState(() {
      _isLoading = true;
      _lastEvaluation = null;
      _userAnswer = '';
      _selectedOption = null;
      _answerController.clear();
    });

    try {
      // Здесь должен быть вызов API для получения следующего вопроса
      // Пока используем mock данные
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _currentQuestion = {
          'question_id': 2,
          'question_type': 'practical_task',
          'question_text': 'Напишите функцию для вычисления факториала числа',
          'question_data': {},
          'difficulty_level': 'Intermediate',
          'skill_focus': 'Функции Python',
        };
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pauseSession() async {
    try {
      await apiService.pauseLearningSession(widget.sessionId);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при приостановке: $e')),
      );
    }
  }

  void _showProgress() {
    // TODO: Показать детальный прогресс
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Прогресс обучения'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Текущий уровень: $_currentLevel'),
            Text('Правильных ответов: $_correctAnswers/$_totalQuestions'),
            Text('Текущая серия: $_currentStreak'),
            Text('Лучшая серия: $_maxStreak'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'multiple_choice':
        return Icons.quiz;
      case 'code_review':
        return Icons.code;
      case 'practical_task':
        return Icons.build;
      case 'concept_explanation':
        return Icons.lightbulb;
      default:
        return Icons.help;
    }
  }

  String _getQuestionTypeTitle(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Выбор ответа';
      case 'code_review':
        return 'Анализ кода';
      case 'practical_task':
        return 'Практическое задание';
      case 'concept_explanation':
        return 'Объяснение концепции';
      default:
        return 'Вопрос';
    }
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green[600]!;
      case 'Intermediate':
        return Colors.orange[600]!;
      case 'Advanced':
        return Colors.red[600]!;
      case 'Expert':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
