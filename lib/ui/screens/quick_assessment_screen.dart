// lib/ui/screens/quick_assessment_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class QuickAssessmentScreen extends StatefulWidget {
  const QuickAssessmentScreen({super.key});

  @override
  State<QuickAssessmentScreen> createState() => _QuickAssessmentScreenState();
}

class _QuickAssessmentScreenState extends State<QuickAssessmentScreen> {
  int _currentQuestionIndex = 0;
  List<String> _answers = [];
  bool _isLoading = false;
  
  final List<QuickQuestion> _questions = [
    QuickQuestion(
      question: "What's your primary programming language?",
      options: ["Python", "JavaScript", "Java", "Go", "C++", "Other"],
      type: "single",
    ),
    QuickQuestion(
      question: "What's your experience level?",
      options: ["Beginner (0-1 years)", "Junior (1-3 years)", "Mid-level (3-5 years)", "Senior (5+ years)"],
      type: "single",
    ),
    QuickQuestion(
      question: "What are your main interests? (Select all that apply)",
      options: ["Web Development", "Mobile Development", "Data Science", "DevOps", "Machine Learning", "Backend Development"],
      type: "multiple",
    ),
    QuickQuestion(
      question: "What's your career goal?",
      options: ["Get a promotion", "Learn new technologies", "Start a side project", "Change career path", "Improve current skills"],
      type: "single",
    ),
    QuickQuestion(
      question: "How much time can you dedicate to learning per week?",
      options: ["1-3 hours", "4-6 hours", "7-10 hours", "10+ hours"],
      type: "single",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.get('quickAssessment')),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                // Question counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
                // Question content
                Expanded(
                  child: _buildQuestionContent(),
                ),
                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
    );
  }

  Widget _buildQuestionContent() {
    final question = _questions[_currentQuestionIndex];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: question.type == "single"
                ? _buildSingleChoiceOptions(question)
                : _buildMultipleChoiceOptions(question),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleChoiceOptions(QuickQuestion question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        // final isSelected = _answers.length > _currentQuestionIndex &&
        //     _answers[_currentQuestionIndex] == option;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(option),
            leading: Radio<String>(
              value: option,
              groupValue: _answers.length > _currentQuestionIndex
                  ? _answers[_currentQuestionIndex]
                  : null,
              onChanged: (value) {
                setState(() {
                  if (_answers.length <= _currentQuestionIndex) {
                    _answers.addAll(List.filled(_currentQuestionIndex - _answers.length + 1, ""));
                  }
                  _answers[_currentQuestionIndex] = value!;
                });
              },
            ),
            onTap: () {
              setState(() {
                if (_answers.length <= _currentQuestionIndex) {
                  _answers.addAll(List.filled(_currentQuestionIndex - _answers.length + 1, ""));
                }
                _answers[_currentQuestionIndex] = option;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildMultipleChoiceOptions(QuickQuestion question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final selectedAnswers = _answers.length > _currentQuestionIndex
            ? _answers[_currentQuestionIndex].split(',').where((a) => a.isNotEmpty).toList()
            : <String>[];
        final isSelected = selectedAnswers.contains(option);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(option),
            leading: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (_answers.length <= _currentQuestionIndex) {
                    _answers.addAll(List.filled(_currentQuestionIndex - _answers.length + 1, ""));
                  }
                  
                  final currentAnswers = _answers[_currentQuestionIndex].split(',').where((a) => a.isNotEmpty).toList();
                  
                  if (value == true) {
                    currentAnswers.add(option);
                  } else {
                    currentAnswers.remove(option);
                  }
                  
                  _answers[_currentQuestionIndex] = currentAnswers.join(',');
                });
              },
            ),
            onTap: () {
              setState(() {
                if (_answers.length <= _currentQuestionIndex) {
                  _answers.addAll(List.filled(_currentQuestionIndex - _answers.length + 1, ""));
                }
                
                final currentAnswers = _answers[_currentQuestionIndex].split(',').where((a) => a.isNotEmpty).toList();
                
                if (currentAnswers.contains(option)) {
                  currentAnswers.remove(option);
                } else {
                  currentAnswers.add(option);
                }
                
                _answers[_currentQuestionIndex] = currentAnswers.join(',');
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    final localizations = authService.localizations;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentQuestionIndex > 0)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentQuestionIndex--;
                });
              },
              child: Text(localizations.get('previous')),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _canProceed() ? _handleNext : null,
            child: Text(
              _currentQuestionIndex == _questions.length - 1
                  ? localizations.get('finish')
                  : localizations.get('next'),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    if (_answers.length <= _currentQuestionIndex) return false;
    return _answers[_currentQuestionIndex].isNotEmpty;
  }

  void _handleNext() {
    if (_currentQuestionIndex == _questions.length - 1) {
      _finishAssessment();
    } else {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _finishAssessment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        // Show completion dialog first
        _showCompletionDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              authService.localizations.get('assessmentComplete'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great job! We\'ve analyzed your responses and completed your assessment.',
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(authService.localizations.get('dashboard')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickQuestion {
  final String question;
  final List<String> options;
  final String type; // "single" or "multiple"

  QuickQuestion({
    required this.question,
    required this.options,
    required this.type,
  });
}
