// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_models.dart';
import '../utils/get_host.dart';
import 'device_service.dart';

class ApiService {
  final String _baseUrl = 'http://${getHost()}:5000';
  final _headers = {'Content-Type': 'application/json'};

  // --- Auth ---
  Future<AuthUser> register(String username, String password, String language) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: _headers,
      body: json.encode({'username': username, 'password': password, 'language': language}),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return AuthUser(id: data['user_id'], username: data['username'], language: data['language']);
    } else {
      throw Exception('Failed to register: ${json.decode(response.body)['error']}');
    }
  }

  Future<AuthUser> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: _headers,
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AuthUser(id: data['user_id'], username: data['username'], language: data['language']);
    } else {
      throw Exception('Failed to login: ${json.decode(response.body)['error']}');
    }
  }

  // --- Assessment ---
  Future<GoalAssessmentIntro> startGoalAssessment(String goal) async {
    final deviceId = await DeviceService.getDeviceId();
    final response = await http.post(
      Uri.parse('$_baseUrl/start-goal-assessment'),
      headers: _headers,
      body: json.encode({'device_id': deviceId, 'goal': goal}),
    );
    if (response.statusCode == 200) {
      return GoalAssessmentIntro.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to start goal assessment: ${json.decode(response.body)['error']}');
    }
  }

  // New method for adaptive assessment
  Future<Map<String, dynamic>?> startGoalAssessmentSimple(String goal) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/start-goal-assessment'),
        headers: _headers,
        body: json.encode({'device_id': deviceId, 'goal': goal}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to start goal assessment: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> startOrResumeTest(String skillName) async {
    final deviceId = await DeviceService.getDeviceId();
    final response = await http.post(
      Uri.parse('$_baseUrl/assessment/start'),
      headers: _headers,
      body: json.encode({'device_id': deviceId, 'skill_name': skillName}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to start assessment: ${json.decode(response.body)['error']}');
    }
  }

  // New method for adaptive assessment
  Future<Map<String, dynamic>?> startSkillTestSimple(String skillName) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/assessment/start'),
        headers: _headers,
        body: json.encode({'device_id': deviceId, 'skill_name': skillName}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to start skill test: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>?> submitAssessmentAnswer(int sessionId, String answer) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/assessment/submit-answer'),
        headers: _headers,
        body: json.encode({'session_id': sessionId, 'answer': answer}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- User Data ---
  Future<UserProfile> fetchProfile() async {
    final deviceId = await DeviceService.getDeviceId();
    final response = await http.get(Uri.parse('$_baseUrl/profile/$deviceId'));
    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<DashboardData> fetchDashboard() async {
    final deviceId = await DeviceService.getDeviceId();
    final response = await http.get(Uri.parse('$_baseUrl/dashboard/$deviceId'));
    if (response.statusCode == 200) {
      return DashboardData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load dashboard');
    }
  }

  // --- Skill Matrix ---
  Future<List<String>> getAvailablePositions() async {
    final response = await http.get(Uri.parse('$_baseUrl/positions'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['positions'] ?? []);
    } else {
      throw Exception('Failed to get positions: ${json.decode(response.body)['error']}');
    }
  }

  Future<PositionSkills> getPositionSkills(String position) async {
    final response = await http.get(Uri.parse('$_baseUrl/positions/$position/skills'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PositionSkills.fromJson(data['skills']);
    } else {
      throw Exception('Failed to get position skills: ${json.decode(response.body)['error']}');
    }
  }

  Future<Map<String, dynamic>> getSkillCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/categories'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['categories'] ?? {};
    } else {
      throw Exception('Failed to get skill categories: ${json.decode(response.body)['error']}');
    }
  }

  Future<Map<String, dynamic>> getSkillDetails(String category, String subcategory, String skill) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/skill-details?category=$category&subcategory=$subcategory&skill=$skill')
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['skill_details'] ?? {};
    } else {
      throw Exception('Failed to get skill details: ${json.decode(response.body)['error']}');
    }
  }

  Future<PositionAssessment> startPositionAssessment(int userId, String position) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/assess-position'),
      headers: _headers,
      body: json.encode({'user_id': userId, 'position': position}),
    );
    if (response.statusCode == 200) {
      return PositionAssessment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to start position assessment: ${json.decode(response.body)['error']}');
    }
  }

  // ===== DYNAMIC SKILLS API METHODS =====

  /// Получает все матрицы навыков пользователя
  Future<List<DynamicSkillMatrix>> getUserSkillMatrices() async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/dynamic-skills/user-matrices'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> matricesJson = data['data'];
        return matricesJson.map((json) => DynamicSkillMatrix.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user matrices: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get user matrices: ${errorData['error']}');
    }
  }

  /// Генерирует новую матрицу навыков для карьерной цели
  Future<DynamicSkillMatrix> generateSkillMatrix({
    required String careerGoal,
    required Map<String, dynamic> userContext,
  }) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/dynamic-skills/generate'),
      headers: headers,
      body: json.encode({
        'career_goal': careerGoal,
        'user_context': userContext,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return DynamicSkillMatrix.fromJson(data['data']);
      } else {
        throw Exception('Failed to generate skill matrix: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to generate skill matrix: ${errorData['error']}');
    }
  }

  /// Получает матрицу навыков по ID
  Future<DynamicSkillMatrix> getSkillMatrix(String matrixId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/dynamic-skills/matrix/$matrixId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return DynamicSkillMatrix.fromJson(data['data']);
      } else {
        throw Exception('Failed to get skill matrix: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get skill matrix: ${errorData['error']}');
    }
  }

  /// Обновляет матрицу навыков
  Future<DynamicSkillMatrix> updateSkillMatrix({
    required String matrixId,
    required Map<String, dynamic> progressData,
  }) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.put(
      Uri.parse('$_baseUrl/api/dynamic-skills/update/$matrixId'),
      headers: headers,
      body: json.encode(progressData),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return DynamicSkillMatrix.fromJson(data['data']);
      } else {
        throw Exception('Failed to update skill matrix: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to update skill matrix: ${errorData['error']}');
    }
  }

  /// Получает прогресс по навыкам
  Future<SkillProgress> getSkillProgress(String matrixId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/dynamic-skills/matrix/$matrixId/progress'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return SkillProgress.fromJson(data['data']);
      } else {
        throw Exception('Failed to get skill progress: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get skill progress: ${errorData['error']}');
    }
  }

  /// Получает рекомендации по навыкам
  Future<List<SkillRecommendation>> getSkillRecommendations(String matrixId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/dynamic-skills/matrix/$matrixId/recommendations'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final recommendations = data['data']['recommendations'] as List? ?? [];
        return recommendations.map((r) => SkillRecommendation.fromJson(r)).toList();
      } else {
        throw Exception('Failed to get skill recommendations: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get skill recommendations: ${errorData['error']}');
    }
  }

  /// Получает дорожную карту обучения
  Future<LearningRoadmap> getLearningRoadmap(String matrixId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/dynamic-skills/matrix/$matrixId/roadmap'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return LearningRoadmap.fromJson(data['data']);
      } else {
        throw Exception('Failed to get learning roadmap: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get learning roadmap: ${errorData['error']}');
    }
  }

  /// Получает детали навыка из динамической матрицы
  Future<Map<String, dynamic>> getDynamicSkillDetails(String matrixId, String skillId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/dynamic-skills/matrix/$matrixId/skills/$skillId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception('Failed to get skill details: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get skill details: ${errorData['error']}');
    }
  }

  /// Обновляет прогресс навыка
  Future<SkillProgressRecord> updateSkillProgress({
    required String matrixId,
    required String skillId,
    required String newLevel,
    required List<String> completedCriteria,
    String? notes,
  }) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.put(
      Uri.parse('$_baseUrl/api/dynamic-skills/matrix/$matrixId/skills/$skillId/update'),
      headers: headers,
      body: json.encode({
        'new_level': newLevel,
        'completed_criteria': completedCriteria,
        'notes': notes,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return SkillProgressRecord.fromJson(data['data']);
      } else {
        throw Exception('Failed to update skill progress: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to update skill progress: ${errorData['error']}');
    }
  }

  // ===== INTERACTIVE LEARNING API METHODS =====

  /// Начинает новую сессию обучения
  Future<Map<String, dynamic>> startLearningSession({
    required String matrixId,
    required String skillId,
    required String targetLevel,
  }) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/interactive-learning/start-session'),
      headers: headers,
      body: json.encode({
        'matrix_id': matrixId,
        'skill_id': skillId,
        'target_level': targetLevel,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception('Failed to start learning session: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to start learning session: ${errorData['error']}');
    }
  }

  /// Отправляет ответ пользователя на вопрос
  Future<Map<String, dynamic>> submitAnswer({
    required int sessionId,
    required int questionId,
    required String userAnswer,
    Map<String, dynamic>? answerData,
  }) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/interactive-learning/submit-answer'),
      headers: headers,
      body: json.encode({
        'session_id': sessionId,
        'question_id': questionId,
        'user_answer': userAnswer,
        'answer_data': answerData ?? {},
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception('Failed to submit answer: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to submit answer: ${errorData['error']}');
    }
  }

  /// Получает детали сессии обучения
  Future<Map<String, dynamic>> getLearningSessionDetails(int sessionId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/interactive-learning/session/$sessionId'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception('Failed to get session details: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get session details: ${errorData['error']}');
    }
  }

  /// Получает прогресс сессии обучения
  Future<LearningSessionProgress> getLearningSessionProgress(int sessionId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/interactive-learning/session/$sessionId/progress'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return LearningSessionProgress.fromJson(data['data']);
      } else {
        throw Exception('Failed to get session progress: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get session progress: ${errorData['error']}');
    }
  }

  /// Приостанавливает сессию обучения
  Future<void> pauseLearningSession(int sessionId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/interactive-learning/session/$sessionId/pause'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return;
      } else {
        throw Exception('Failed to pause session: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to pause session: ${errorData['error']}');
    }
  }

  /// Возобновляет приостановленную сессию обучения
  Future<Map<String, dynamic>> resumeLearningSession(int sessionId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.post(
      Uri.parse('$_baseUrl/api/interactive-learning/session/$sessionId/resume'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception('Failed to resume session: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to resume session: ${errorData['error']}');
    }
  }

  /// Получает все сессии обучения пользователя
  Future<List<LearningSession>> getUserLearningSessions(int userId) async {
    final deviceId = await DeviceService.getDeviceId();
    final headers = {
      ..._headers,
      'X-User-ID': deviceId,
    };
    
    final response = await http.get(
      Uri.parse('$_baseUrl/api/interactive-learning/user/$userId/sessions'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final sessions = data['data']['sessions'] as List;
        return sessions.map((session) => LearningSession.fromJson(session)).toList();
      } else {
        throw Exception('Failed to get user sessions: ${data['error']}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception('Failed to get user sessions: ${errorData['error']}');
    }
  }

}

final apiService = ApiService();