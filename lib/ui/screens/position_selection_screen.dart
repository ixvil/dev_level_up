// lib/ui/screens/position_selection_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/app_models.dart';
import '../widgets/loading_widget.dart';
import 'assessment/adaptive_test_screen.dart';

class PositionSelectionScreen extends StatefulWidget {
  final int userId;
  
  const PositionSelectionScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<PositionSelectionScreen> createState() => _PositionSelectionScreenState();
}

class _PositionSelectionScreenState extends State<PositionSelectionScreen> {
  List<String> _positions = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final positions = await apiService.getAvailablePositions();
      setState(() {
        _positions = positions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startAssessment(String position) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await apiService.startPositionAssessment(widget.userId, position);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdaptiveTestScreen(
              skillName: position,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }


  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки позиций',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadPositions,
            icon: const Icon(Icons.refresh),
            label: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsList() {
    if (_positions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Позиции не найдены',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _positions.length,
      itemBuilder: (context, index) {
        final position = _positions[index];
        final isSelected = _selectedPosition == position;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: isSelected ? 8 : 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? Colors.blue[600] : Colors.grey[300],
              child: Icon(
                _getPositionIcon(position),
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              position,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue[600] : null,
              ),
            ),
            subtitle: Text(
              _getPositionDescription(position),
              style: TextStyle(
                color: isSelected ? Colors.blue[500] : Colors.grey[600],
              ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[600],
                  )
                : const Icon(Icons.arrow_forward_ios),
            onTap: () {
              setState(() {
                _selectedPosition = position;
              });
            },
            onLongPress: () {
              _showPositionDetails(position);
            },
          ),
        );
      },
    );
  }

  IconData _getPositionIcon(String position) {
    switch (position.toLowerCase()) {
      case 'php developer':
        return Icons.code;
      case 'python developer':
        return Icons.code;
      case 'full stack developer':
        return Icons.devices;
      case 'data engineer':
        return Icons.analytics;
      default:
        return Icons.work;
    }
  }

  String _getPositionDescription(String position) {
    switch (position.toLowerCase()) {
      case 'php developer':
        return 'Разработка веб-приложений на PHP с MySQL';
      case 'python developer':
        return 'Разработка приложений на Python с PostgreSQL';
      case 'full stack developer':
        return 'Полноценная разработка фронтенда и бэкенда';
      case 'data engineer':
        return 'Работа с данными и аналитикой';
      default:
        return 'IT позиция';
    }
  }

  void _showPositionDetails(String position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(position),
        content: FutureBuilder<PositionSkills>(
          future: apiService.getPositionSkills(position),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            
            if (snapshot.hasError) {
              return Text('Ошибка: ${snapshot.error}');
            }
            
            final skills = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (skills.required.isNotEmpty) ...[
                    const Text(
                      'Обязательные навыки:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._buildSkillsList(skills.required),
                    const SizedBox(height: 16),
                  ],
                  if (skills.optional.isNotEmpty) ...[
                    const Text(
                      'Дополнительные навыки:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._buildSkillsList(skills.optional),
                  ],
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startAssessment(position);
            },
            child: const Text('Начать оценку'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSkillsList(Map<String, Map<String, Map<String, List<String>>>> skills) {
    List<Widget> widgets = [];
    
    skills.forEach((category, subcategories) {
      widgets.add(Text(
        '• $category',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ));
      
      subcategories.forEach((subcategory, skillMap) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text('  - $subcategory'),
        ));
        
        skillMap.forEach((skill, subskills) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text('    * $skill'),
          ));
        });
      });
    });
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите позицию'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : _buildPositionsList(),
      floatingActionButton: _selectedPosition != null
          ? FloatingActionButton.extended(
              onPressed: () => _startAssessment(_selectedPosition!),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Начать оценку'),
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}

