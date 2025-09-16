// lib/ui/widgets/dialogue_widgets.dart
import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class QuestionBubble extends StatelessWidget {
  final Question question;
  const QuestionBubble({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.question,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          if (question.codeSnippet != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              color: Colors.black87,
              child: Text(
                question.codeSnippet!,
                style:
                    const TextStyle(fontFamily: 'monospace', color: Colors.white),
              ),
            )
          ],
          // Показываем варианты ответов для multiple-choice вопросов
          if (question.type == 'multiple-choice' && question.options.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Варианты ответов:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            ...question.options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                option,
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ]
        ],
      ),
    );
  }
}

class AnswerBubble extends StatelessWidget {
  final String answer;
  const AnswerBubble({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
        ),
        child: Text(answer),
      ),
    );
  }
}

class AnswerInput extends StatelessWidget {
  final Question question;
  final Function(String) onMcqSelected;
  final String? mcqSelection;
  final TextEditingController textController;

  const AnswerInput({
    super.key,
    required this.question,
    required this.onMcqSelected,
    this.mcqSelection,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    if (question.type == 'multiple-choice') {
      return Column(
        children: question.options
            .map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: mcqSelection,
                  onChanged: (val) => onMcqSelected(val!),
                ))
            .toList(),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextField(
          controller: textController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Your answer...',
            border: OutlineInputBorder(),
          ),
        ),
      );
    }
  }
}