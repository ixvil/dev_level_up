// lib/ui/screens/dynamic_skills_generation_screen.dart

import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../../services/api_service.dart';

class DynamicSkillsGenerationScreen extends StatefulWidget {
  const DynamicSkillsGenerationScreen({Key? key}) : super(key: key);

  @override
  State<DynamicSkillsGenerationScreen> createState() => _DynamicSkillsGenerationScreenState();
}

class _DynamicSkillsGenerationScreenState extends State<DynamicSkillsGenerationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _careerGoalController = TextEditingController();
  final _experienceController = TextEditingController();
  final _learningStyleController = TextEditingController();
  
  bool _isGenerating = false;
  bool _isLoadingMatrices = false;
  String? _errorMessage;
  DynamicSkillMatrix? _generatedMatrix;
  List<DynamicSkillMatrix> _existingMatrices = [];


  final List<String> _learningStyleOptions = [
    'Hands-on projects',
    'Theoretical study',
    'Video tutorials',
    'Reading documentation',
    'Interactive coding',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingMatrices();
  }

  @override
  void dispose() {
    _careerGoalController.dispose();
    _experienceController.dispose();
    _learningStyleController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMatrices() async {
    setState(() => _isLoadingMatrices = true);
    
    try {
      final matrices = await apiService.getUserSkillMatrices();
      setState(() {
        _existingMatrices = matrices;
        _isLoadingMatrices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMatrices = false;
      });
      // Не показываем ошибку, если нет матриц - это нормально
    }
  }

  void _openExistingMatrix(DynamicSkillMatrix matrix) {
    Navigator.pushNamed(
      context,
      '/dynamic-skills-matrix',
      arguments: matrix,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _generateSkillMatrix() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final userContext = {
        'current_experience': _experienceController.text,
        'learning_preferences': _learningStyleController.text,
        'current_level': 'Intermediate', // Можно добавить выбор уровня
      };

      final matrix = await apiService.generateSkillMatrix(
        careerGoal: _careerGoalController.text,
        userContext: userContext,
      );

      setState(() {
        _generatedMatrix = matrix;
        _isGenerating = false;
      });

      // Переходим к экрану просмотра матрицы
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/dynamic-skills-matrix',
          arguments: matrix,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Генерация матрицы навыков'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.blue[600], size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI-генерация матрицы навыков',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Расскажите о вашей карьерной цели, и ИИ создаст персонализированную матрицу навыков с планом обучения.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Существующие матрицы
              if (_existingMatrices.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history, color: Colors.green[600], size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Ваши матрицы навыков',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Выберите существующую матрицу для продолжения обучения или создайте новую.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...(_isLoadingMatrices 
                          ? [const Center(child: CircularProgressIndicator())]
                          : _existingMatrices.map((matrix) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Icon(Icons.auto_awesome, color: Colors.green[600]),
                              ),
                              title: Text(
                                matrix.careerGoal,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Создана: ${_formatDate(matrix.generatedAt)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _openExistingMatrix(matrix),
                            ),
                          )).toList()
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Форма
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Создать новую матрицу навыков',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Карьерная цель
                      TextFormField(
                        controller: _careerGoalController,
                        decoration: const InputDecoration(
                          labelText: 'Карьерная цель *',
                          hintText: 'Например: Senior Python Developer, Data Scientist, Frontend Developer',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Пожалуйста, укажите карьерную цель';
                          }
                          return null;
                        },
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Опыт
                      TextFormField(
                        controller: _experienceController,
                        decoration: const InputDecoration(
                          labelText: 'Текущий опыт *',
                          hintText: 'Например: 2 года Python разработки, изучаю веб-разработку',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.school),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Пожалуйста, опишите ваш текущий опыт';
                          }
                          return null;
                        },
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Стиль обучения
                      DropdownButtonFormField<String>(
                        value: _learningStyleController.text.isNotEmpty 
                            ? _learningStyleController.text 
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Предпочитаемый стиль обучения',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.style),
                        ),
                        items: _learningStyleOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _learningStyleController.text = value ?? '';
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Ошибка
              if (_errorMessage != null)
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),

              // Кнопка генерации
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateSkillMatrix,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isGenerating
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Генерируем матрицу...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome),
                            SizedBox(width: 8),
                            Text(
                              'Сгенерировать матрицу навыков',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Информация о процессе
              if (_isGenerating)
                Card(
                  color: Colors.blue[50],
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
                              'Генерация матрицы навыков',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ИИ анализирует вашу цель и создает персонализированную матрицу навыков с планом обучения. Это может занять несколько секунд.',
                          style: TextStyle(color: Colors.blue[700]),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
