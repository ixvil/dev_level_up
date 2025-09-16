// lib/ui/screens/assessment/adaptive_test_screen.dart
import 'package:flutter/material.dart';
import '../../../models/app_models.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../widgets/dialogue_widgets.dart';

class AdaptiveTestScreen extends StatefulWidget {
  final String skillName;
  const AdaptiveTestScreen({super.key, required this.skillName});
  @override
  State<AdaptiveTestScreen> createState() => _AdaptiveTestScreenState();
}

class _AdaptiveTestScreenState extends State<AdaptiveTestScreen> {
  Future<Map<String, dynamic>>? _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = apiService.startOrResumeTest(widget.skillName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${authService.localizations.get('assessmentFor')} ${widget.skillName}')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sessionFuture = apiService.startOrResumeTest(widget.skillName);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasData) {
            final initialData = snapshot.data!;
            final sessionId = initialData['session_id'] as int?;
            final historyData = initialData['history'] as List?;
            
            if (sessionId == null || historyData == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    const Text('Invalid data received from server'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _sessionFuture = apiService.startOrResumeTest(widget.skillName);
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            final history = historyData
                .map((q) => Question.fromJson(q as Map<String, dynamic>))
                .toList();

            return AssessmentDialogueView(
              sessionId: sessionId,
              initialHistory: history,
              skillName: widget.skillName,
              onCompleted: () => Navigator.of(context).pop(true),
            );
          }
          return const Center(child: Text("Could not load test."));
        },
      ),
    );
  }
}

class AssessmentDialogueView extends StatefulWidget {
  final int sessionId;
  final List<Question> initialHistory;
  final String skillName;
  final VoidCallback onCompleted;

  const AssessmentDialogueView({
    super.key,
    required this.sessionId,
    required this.initialHistory,
    required this.skillName,
    required this.onCompleted,
  });

  @override
  State<AssessmentDialogueView> createState() => _AssessmentDialogueViewState();
}

class _AssessmentDialogueViewState extends State<AssessmentDialogueView> {
  late List<Question> _history;
  String? _multipleChoiceSelection;
  final _textAnswerController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _history = widget.initialHistory;
  }

  Question get _currentQuestion => _history.last;

  Future<void> _submitAnswer() async {
    String? answer;
    if (_currentQuestion.type == 'multiple-choice') {
      answer = _multipleChoiceSelection;
    } else {
      answer = _textAnswerController.text;
    }

    if (answer == null || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide an answer.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = await apiService.submitAssessmentAnswer(widget.sessionId, answer);

      if (body != null && body['status'] == 'completed') {
        final result = FinalResult.fromJson(body);
        _showCompletionDialog(result);
      } else if (body != null) {
        setState(() {
          _history = (body['history'] as List)
              .map((q) => Question.fromJson(q))
              .toList();
          _multipleChoiceSelection = null;
          _textAnswerController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _showCompletionDialog(FinalResult result) {
    final localizations = authService.localizations;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(localizations.get('assessmentComplete')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основной результат
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ваш уровень:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.progressDescription ?? '${result.level} (${result.score}%)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  if (result.progressToNext != null && result.nextLevel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Прогресс до ${result.nextLevel}: ${result.progressToNext}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCompleted();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = authService.localizations;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index];
              bool isLast = index == _history.length - 1;
              return Column(
                children: [
                  QuestionBubble(question: item),
                  if (item.userAnswer != null)
                    AnswerBubble(answer: item.userAnswer!),
                  if (isLast)
                    AnswerInput(
                      question: item,
                      onMcqSelected: (val) =>
                          setState(() => _multipleChoiceSelection = val),
                      mcqSelection: _multipleChoiceSelection,
                      textController: _textAnswerController,
                    )
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _submitAnswer,
                  child: Text(localizations.get('submitAnswer'))),
        ),
      ],
    );
  }
}