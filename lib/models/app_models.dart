// lib/models/app_models.dart

class AuthUser {
  final int id;
  final String username;
  final String language;
  AuthUser({required this.id, required this.username, required this.language});
}

class GoalAssessmentIntro {
  final int goalId;
  final String goalName;
  final String primarySkill;
  final List<SkillToAssess> skillsToAssess;
  
  GoalAssessmentIntro({
    required this.goalId, 
    required this.goalName, 
    required this.primarySkill,
    required this.skillsToAssess
  });
  
  factory GoalAssessmentIntro.fromJson(Map<String, dynamic> json) {
    try {
      List<SkillToAssess> skills = [];
      if (json['skills_to_assess'] != null) {
        final skillsList = json['skills_to_assess'] as List;
        skills = skillsList.map((s) {
          try {
            return SkillToAssess.fromJson(s as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing skill: $e, data: $s');
            return SkillToAssess(
              name: s['name']?.toString() ?? 'Unknown Skill',
              group: s['group']?.toString() ?? 'General',
              subcategory: s['subcategory']?.toString(),
              subskills: [],
            );
          }
        }).toList();
      }
      
      return GoalAssessmentIntro(
        goalId: json['goal_id'] ?? 0, 
        goalName: json['goal_name']?.toString() ?? '', 
        primarySkill: json['primary_skill']?.toString() ?? '',
        skillsToAssess: skills
      );
    } catch (e) {
      print('Error parsing GoalAssessmentIntro: $e, json: $json');
      return GoalAssessmentIntro(
        goalId: 0,
        goalName: 'Unknown Goal',
        primarySkill: '',
        skillsToAssess: [],
      );
    }
  }
  
  // Группировка навыков по категориям
  Map<String, List<SkillToAssess>> get groupedSkills {
    Map<String, List<SkillToAssess>> groups = {};
    for (var skill in skillsToAssess) {
      if (!groups.containsKey(skill.group)) {
        groups[skill.group] = [];
      }
      groups[skill.group]!.add(skill);
    }
    return groups;
  }
}

class SkillToAssess {
  final String name;
  final String group;
  final String? subcategory;
  final List<String> subskills;
  
  SkillToAssess({
    required this.name,
    required this.group,
    this.subcategory,
    required this.subskills,
  });
  
  factory SkillToAssess.fromJson(Map<String, dynamic> json) {
    try {
      return SkillToAssess(
        name: json['name']?.toString() ?? '',
        group: json['group']?.toString() ?? '',
        subcategory: json['subcategory']?.toString(),
        subskills: json['subskills'] != null 
            ? List<String>.from(json['subskills'].map((s) => s.toString()))
            : [],
      );
    } catch (e) {
      print('Error parsing SkillToAssess: $e, json: $json');
      return SkillToAssess(
        name: json['name']?.toString() ?? 'Unknown Skill',
        group: json['group']?.toString() ?? 'General',
        subcategory: null,
        subskills: [],
      );
    }
  }
}

class Question {
  final String type;
  final String question;
  final String? codeSnippet;
  final List<String> options;
  final String? correctAnswer;
  String? userAnswer;
  Question({required this.type, required this.question, this.codeSnippet, required this.options, this.correctAnswer, this.userAnswer});
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(type: json['type'] ?? 'open-ended', question: json['question'] ?? '', codeSnippet: json['code_snippet'], options: List<String>.from(json['options'] as List? ?? []), correctAnswer: json['correct_answer']);
  }
}

class FinalResult {
  final String level;
  final int score;
  final String? progressDescription;
  final String? currentLevel;
  final String? nextLevel;
  final int? progressToNext;
  
  FinalResult({
    required this.level, 
    required this.score,
    this.progressDescription,
    this.currentLevel,
    this.nextLevel,
    this.progressToNext,
  });
  
  factory FinalResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'] ?? {};
    return FinalResult(
      level: result['final_level'] ?? 'Unranked', 
      score: result['final_score'] ?? 0,
      progressDescription: result['progress_description'],
      currentLevel: result['current_level'],
      nextLevel: result['next_level'],
      progressToNext: result['progress_to_next'],
    );
  }
}

class UserProfile {
  final String username;
  final List<SkillGroupModel> skillGroups;
  final List<GoalSummary> goals;
  UserProfile({required this.username, required this.skillGroups, required this.goals});
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var groupsFromJson = json['skill_groups'] as List? ?? [];
    List<SkillGroupModel> groupList = groupsFromJson.map((s) => SkillGroupModel.fromJson(s)).toList();
    var goalsFromJson = json['goals'] as List? ?? [];
    List<GoalSummary> goalList = goalsFromJson.map((g) => GoalSummary.fromJson(g)).toList();
    return UserProfile(username: json['username'] ?? 'Unknown User', skillGroups: groupList, goals: goalList);
  }
}

class SkillGroupModel {
  final String name;
  final List<UserSkillModel> skills;
  SkillGroupModel({required this.name, required this.skills});
  factory SkillGroupModel.fromJson(Map<String, dynamic> json) {
    var skillsFromJson = json['skills'] as List? ?? [];
    List<UserSkillModel> skillList = skillsFromJson.map((s) => UserSkillModel.fromJson(s)).toList();
    return SkillGroupModel(name: json['name'] ?? 'General', skills: skillList);
  }
}

class UserSkillModel {
  final String name;
  final int score;
  final String level;
  final String? lastTested;
  final String? progressDescription;
  final String? currentLevel;
  final String? nextLevel;
  final int? progressToNext;
  
  UserSkillModel({
    required this.name, 
    required this.score, 
    required this.level, 
    this.lastTested,
    this.progressDescription,
    this.currentLevel,
    this.nextLevel,
    this.progressToNext,
  });
  
  factory UserSkillModel.fromJson(Map<String, dynamic> json) {
    return UserSkillModel(
      name: json['name'] ?? 'Unknown Skill', 
      score: json['score'] ?? 0, 
      level: json['level'] ?? 'Unranked', 
      lastTested: json['last_tested'],
      progressDescription: json['progress_description'],
      currentLevel: json['current_level'],
      nextLevel: json['next_level'],
      progressToNext: json['progress_to_next'],
    );
  }
}

class GoalSummary {
  final String name;
  final int matchPercentage;
  GoalSummary({required this.name, required this.matchPercentage});
  factory GoalSummary.fromJson(Map<String, dynamic> json) {
    return GoalSummary(name: json['name'] ?? 'Unknown Goal', matchPercentage: json['match_percentage'] ?? 0);
  }
}

class DashboardData {
  final List<SkillSummary> strongestSkills;
  final List<SkillSummary> weakestSkills;
  final List<GoalSummary> latestGoals;
  DashboardData({ required this.strongestSkills, required this.weakestSkills, required this.latestGoals });
  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      strongestSkills: (json['strongest_skills'] as List? ?? []).map((s) => SkillSummary.fromJson(s)).toList(),
      weakestSkills: (json['weakest_skills'] as List? ?? []).map((s) => SkillSummary.fromJson(s)).toList(),
      latestGoals: (json['latest_goals'] as List? ?? []).map((g) => GoalSummary.fromJson(g)).toList(),
    );
  }
}


class SkillSummary {
  final String name;
  final int score;
  final String? level;
  final String? progressDescription;
  final String? currentLevel;
  final String? nextLevel;
  final int? progressToNext;
  
  SkillSummary({
    required this.name, 
    required this.score,
    this.level,
    this.progressDescription,
    this.currentLevel,
    this.nextLevel,
    this.progressToNext,
  });
  
  factory SkillSummary.fromJson(Map<String, dynamic> json) {
    return SkillSummary(
      name: json['name'], 
      score: json['score'],
      level: json['level'],
      progressDescription: json['progress_description'],
      currentLevel: json['current_level'],
      nextLevel: json['next_level'],
      progressToNext: json['progress_to_next'],
    );
  }
}


// Models for Welcome Screen
class WelcomeData {
  final AuthUser user;
  final bool isNewUser;
  final bool hasCompletedAssessment;
  final dynamic recentProgress; // Removed progress tracking
  final List<Recommendation> recommendations;
  final List<QuickAction> quickActions;
  
  WelcomeData({
    required this.user,
    required this.isNewUser,
    required this.hasCompletedAssessment,
    this.recentProgress,
    required this.recommendations,
    required this.quickActions,
  });
}

class Recommendation {
  final String title;
  final String description;
  final String type;
  final String priority;
  final String action;
  
  Recommendation({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.action,
  });
}

class QuickAction {
  final String title;
  final String description;
  final dynamic icon;
  final dynamic color;
  final String route;
  
  QuickAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

// Models for Skill Matrix
class Position {
  final String name;
  final String description;
  
  Position({required this.name, required this.description});
  
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class SkillCategory {
  final String name;
  final String description;
  final Map<String, SkillSubcategory> subcategories;
  
  SkillCategory({
    required this.name,
    required this.description,
    required this.subcategories,
  });
  
  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    Map<String, SkillSubcategory> subcategories = {};
    if (json['subcategories'] != null) {
      json['subcategories'].forEach((key, value) {
        subcategories[key] = SkillSubcategory.fromJson(value);
      });
    }
    
    return SkillCategory(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subcategories: subcategories,
    );
  }
}

class SkillSubcategory {
  final String name;
  final String description;
  final Map<String, Skill> skills;
  
  SkillSubcategory({
    required this.name,
    required this.description,
    required this.skills,
  });
  
  factory SkillSubcategory.fromJson(Map<String, dynamic> json) {
    Map<String, Skill> skills = {};
    if (json['skills'] != null) {
      json['skills'].forEach((key, value) {
        skills[key] = Skill.fromJson(value);
      });
    }
    
    return SkillSubcategory(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      skills: skills,
    );
  }
}

class Skill {
  final String name;
  final String description;
  final Map<String, List<String>> subskills;
  
  Skill({
    required this.name,
    required this.description,
    required this.subskills,
  });
  
  factory Skill.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>> subskills = {};
    if (json['subskills'] != null) {
      json['subskills'].forEach((key, value) {
        subskills[key] = List<String>.from(value ?? []);
      });
    }
    
    return Skill(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subskills: subskills,
    );
  }
}

class PositionSkills {
  final String position;
  final Map<String, Map<String, Map<String, List<String>>>> required;
  final Map<String, Map<String, Map<String, List<String>>>> optional;
  
  PositionSkills({
    required this.position,
    required this.required,
    required this.optional,
  });
  
  factory PositionSkills.fromJson(Map<String, dynamic> json) {
    return PositionSkills(
      position: json['position'] ?? '',
      required: Map<String, Map<String, Map<String, List<String>>>>.from(
        json['required'] ?? {}
      ),
      optional: Map<String, Map<String, Map<String, List<String>>>>.from(
        json['optional'] ?? {}
      ),
    );
  }
}

class PositionAssessment {
  final String position;
  final int userId;
  final PositionSkills skillsToAssess;
  final String message;
  
  PositionAssessment({
    required this.position,
    required this.userId,
    required this.skillsToAssess,
    required this.message,
  });
  
  factory PositionAssessment.fromJson(Map<String, dynamic> json) {
    return PositionAssessment(
      position: json['position'] ?? '',
      userId: json['user_id'] ?? 0,
      skillsToAssess: PositionSkills.fromJson(json['skills_to_assess'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

// ===== DYNAMIC SKILLS MODELS =====

class DynamicSkillMatrix {
  final String id;
  final String userId;
  final String careerGoal;
  final String version;
  final DynamicSkillMatrixData skillMatrixData;
  final DateTime generatedAt;
  final DateTime updatedAt;
  final DateTime? nextUpdate;
  final String updateFrequency;
  final bool isActive;
  final bool isFallback;
  
  DynamicSkillMatrix({
    required this.id,
    required this.userId,
    required this.careerGoal,
    required this.version,
    required this.skillMatrixData,
    required this.generatedAt,
    required this.updatedAt,
    this.nextUpdate,
    required this.updateFrequency,
    required this.isActive,
    required this.isFallback,
  });
  
  factory DynamicSkillMatrix.fromJson(Map<String, dynamic> json) {
    return DynamicSkillMatrix(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      careerGoal: json['career_goal'] ?? '',
      version: json['version'] ?? '1.0',
      skillMatrixData: DynamicSkillMatrixData.fromJson(json['skill_matrix_data'] ?? {}),
      generatedAt: DateTime.tryParse(json['generated_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      nextUpdate: json['next_update'] != null ? DateTime.tryParse(json['next_update']) : null,
      updateFrequency: json['update_frequency'] ?? 'monthly',
      isActive: json['is_active'] ?? true,
      isFallback: json['is_fallback'] ?? false,
    );
  }
}

class DynamicSkillMatrixData {
  final String careerGoal;
  final DateTime generatedAt;
  final String version;
  final List<DynamicSkill> skills;
  final List<LearningPhase> learningPath;
  final String? nextUpdate;
  final String updateFrequency;
  final Map<String, dynamic> userContext;
  final int totalSkills;
  final String estimatedTotalTime;
  
  DynamicSkillMatrixData({
    required this.careerGoal,
    required this.generatedAt,
    required this.version,
    required this.skills,
    required this.learningPath,
    this.nextUpdate,
    required this.updateFrequency,
    required this.userContext,
    required this.totalSkills,
    required this.estimatedTotalTime,
  });
  
  factory DynamicSkillMatrixData.fromJson(Map<String, dynamic> json) {
    return DynamicSkillMatrixData(
      careerGoal: json['career_goal'] ?? '',
      generatedAt: DateTime.tryParse(json['generated_at'] ?? '') ?? DateTime.now(),
      version: json['version'] ?? '1.0',
      skills: (json['skills'] as List? ?? []).map((s) => DynamicSkill.fromJson(s)).toList(),
      learningPath: (json['learning_path'] as List? ?? []).map((p) => LearningPhase.fromJson(p)).toList(),
      nextUpdate: json['next_update'],
      updateFrequency: json['update_frequency'] ?? 'monthly',
      userContext: Map<String, dynamic>.from(json['user_context'] ?? {}),
      totalSkills: json['total_skills'] ?? 0,
      estimatedTotalTime: json['estimated_total_time'] ?? '',
    );
  }
}

class DynamicSkill {
  final String id;
  final String name;
  final String description;
  final String category; // Core, Supporting, Emerging
  final String priority; // High, Medium, Low
  final List<SkillLevel> levels;
  final List<String> dependencies;
  final List<String> learningResources;
  
  DynamicSkill({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.priority,
    required this.levels,
    required this.dependencies,
    required this.learningResources,
  });
  
  factory DynamicSkill.fromJson(Map<String, dynamic> json) {
    return DynamicSkill(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Core',
      priority: json['priority'] ?? 'Medium',
      levels: (json['levels'] as List? ?? []).map((l) => SkillLevel.fromJson(l)).toList(),
      dependencies: List<String>.from(json['dependencies'] ?? []),
      learningResources: List<String>.from(json['learning_resources'] ?? []),
    );
  }
}

class SkillLevel {
  final String level; // Beginner, Intermediate, Advanced, Expert
  final String description;
  final List<String> criteria;
  
  SkillLevel({
    required this.level,
    required this.description,
    required this.criteria,
  });
  
  factory SkillLevel.fromJson(Map<String, dynamic> json) {
    return SkillLevel(
      level: json['level'] ?? 'Beginner',
      description: json['description'] ?? '',
      criteria: List<String>.from(json['criteria'] ?? []),
    );
  }
}

class LearningPhase {
  final String phase;
  final String description;
  final List<String> skills;
  
  LearningPhase({
    required this.phase,
    required this.description,
    required this.skills,
  });
  
  factory LearningPhase.fromJson(Map<String, dynamic> json) {
    return LearningPhase(
      phase: json['phase'] ?? '',
      description: json['description'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}

class SkillProgress {
  final String overallProgressPercentage;
  final Map<String, SkillProgressRecord> skillProgress;
  final List<String> nextRecommendedSkills;
  
  SkillProgress({
    required this.overallProgressPercentage,
    required this.skillProgress,
    required this.nextRecommendedSkills,
  });
  
  factory SkillProgress.fromJson(Map<String, dynamic> json) {
    Map<String, SkillProgressRecord> skillProgressMap = {};
    if (json['skill_progress'] != null) {
      (json['skill_progress'] as Map).forEach((key, value) {
        skillProgressMap[key] = SkillProgressRecord.fromJson(value);
      });
    }
    
    return SkillProgress(
      overallProgressPercentage: json['overall_progress_percentage']?.toString() ?? '0',
      skillProgress: skillProgressMap,
      nextRecommendedSkills: List<String>.from(json['next_recommended_skills'] ?? []),
    );
  }
}

class SkillProgressRecord {
  final String id;
  final String matrixId;
  final String skillId;
  final String userId;
  final String currentLevel;
  final double progressPercentage;
  final List<String> completedCriteria;
  final DateTime startedAt;
  final DateTime lastUpdated;
  final DateTime? completedAt;
  final String? notes;
  
  SkillProgressRecord({
    required this.id,
    required this.matrixId,
    required this.skillId,
    required this.userId,
    required this.currentLevel,
    required this.progressPercentage,
    required this.completedCriteria,
    required this.startedAt,
    required this.lastUpdated,
    this.completedAt,
    this.notes,
  });
  
  factory SkillProgressRecord.fromJson(Map<String, dynamic> json) {
    return SkillProgressRecord(
      id: json['id'] ?? '',
      matrixId: json['matrix_id'] ?? '',
      skillId: json['skill_id'] ?? '',
      userId: json['user_id'] ?? '',
      currentLevel: json['current_level'] ?? 'Beginner',
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
      completedCriteria: List<String>.from(json['completed_criteria'] ?? []),
      startedAt: DateTime.tryParse(json['started_at'] ?? '') ?? DateTime.now(),
      lastUpdated: DateTime.tryParse(json['last_updated'] ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      notes: json['notes'],
    );
  }
}

class SkillRecommendation {
  final String skillId;
  final String skillName;
  final String reason;
  final String priority;
  final List<String> prerequisites;
  
  SkillRecommendation({
    required this.skillId,
    required this.skillName,
    required this.reason,
    required this.priority,
    required this.prerequisites,
  });
  
  factory SkillRecommendation.fromJson(Map<String, dynamic> json) {
    return SkillRecommendation(
      skillId: json['skill_id'] ?? '',
      skillName: json['skill_name'] ?? '',
      reason: json['reason'] ?? '',
      priority: json['priority'] ?? 'Medium',
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
    );
  }
}

class LearningRoadmap {
  final String matrixId;
  final List<RoadmapPhase> phases;
  
  LearningRoadmap({
    required this.matrixId,
    required this.phases,
  });
  
  factory LearningRoadmap.fromJson(Map<String, dynamic> json) {
    return LearningRoadmap(
      matrixId: json['matrix_id'] ?? '',
      phases: (json['phases'] as List? ?? []).map((p) => RoadmapPhase.fromJson(p)).toList(),
    );
  }
}

class RoadmapPhase {
  final String phase;
  final String description;
  final List<RoadmapSkill> skills;
  final bool isCompleted;
  final bool isCurrent;
  
  RoadmapPhase({
    required this.phase,
    required this.description,
    required this.skills,
    required this.isCompleted,
    required this.isCurrent,
  });
  
  factory RoadmapPhase.fromJson(Map<String, dynamic> json) {
    return RoadmapPhase(
      phase: json['phase'] ?? '',
      description: json['description'] ?? '',
      skills: (json['skills'] as List? ?? []).map((s) => RoadmapSkill.fromJson(s)).toList(),
      isCompleted: json['is_completed'] ?? false,
      isCurrent: json['is_current'] ?? false,
    );
  }
}

class RoadmapSkill {
  final String skillId;
  final String skillName;
  final String category;
  final String priority;
  final String currentLevel;
  final String targetLevel;
  final double progress;
  final bool isCompleted;
  
  RoadmapSkill({
    required this.skillId,
    required this.skillName,
    required this.category,
    required this.priority,
    required this.currentLevel,
    required this.targetLevel,
    required this.progress,
    required this.isCompleted,
  });
  
  factory RoadmapSkill.fromJson(Map<String, dynamic> json) {
    return RoadmapSkill(
      skillId: json['skill_id'] ?? '',
      skillName: json['skill_name'] ?? '',
      category: json['category'] ?? 'Core',
      priority: json['priority'] ?? 'Medium',
      currentLevel: json['current_level'] ?? 'Beginner',
      targetLevel: json['target_level'] ?? 'Intermediate',
      progress: (json['progress'] ?? 0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

// ===== МОДЕЛИ ИНТЕРАКТИВНОГО ОБУЧЕНИЯ =====

class LearningSession {
  final int id;
  final int userId;
  final int matrixId;
  final String skillId;
  final String status; // 'active', 'completed', 'paused'
  final String currentLevel;
  final String targetLevel;
  final int totalQuestions;
  final int correctAnswers;
  final int currentStreak;
  final int maxStreak;
  final DateTime startedAt;
  final DateTime lastActivity;
  final DateTime? completedAt;
  final Map<String, dynamic> sessionData;

  LearningSession({
    required this.id,
    required this.userId,
    required this.matrixId,
    required this.skillId,
    required this.status,
    required this.currentLevel,
    required this.targetLevel,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.currentStreak,
    required this.maxStreak,
    required this.startedAt,
    required this.lastActivity,
    this.completedAt,
    required this.sessionData,
  });

  factory LearningSession.fromJson(Map<String, dynamic> json) {
    return LearningSession(
      id: json['id'],
      userId: json['user_id'],
      matrixId: json['matrix_id'],
      skillId: json['skill_id'],
      status: json['status'],
      currentLevel: json['current_level'],
      targetLevel: json['target_level'],
      totalQuestions: json['total_questions'],
      correctAnswers: json['correct_answers'],
      currentStreak: json['current_streak'],
      maxStreak: json['max_streak'],
      startedAt: DateTime.parse(json['started_at']),
      lastActivity: DateTime.parse(json['last_activity']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      sessionData: json['session_data'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'matrix_id': matrixId,
      'skill_id': skillId,
      'status': status,
      'current_level': currentLevel,
      'target_level': targetLevel,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'current_streak': currentStreak,
      'max_streak': maxStreak,
      'started_at': startedAt.toIso8601String(),
      'last_activity': lastActivity.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'session_data': sessionData,
    };
  }

  double get accuracy => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
  double get progressPercentage => accuracy;

  @override
  String toString() {
    return 'LearningSession{id: $id, skillId: $skillId, status: $status, currentLevel: $currentLevel, accuracy: ${accuracy.toStringAsFixed(1)}%}';
  }
}

class LearningQuestion {
  final int id;
  final int sessionId;
  final String questionType; // 'multiple_choice', 'code_review', 'practical_task', 'concept_explanation'
  final String questionText;
  final Map<String, dynamic> questionData;
  final String difficultyLevel;
  final String? skillFocus;
  final String? expectedAnswer;
  final Map<String, dynamic> evaluationCriteria;
  final String status; // 'pending', 'answered', 'evaluated'
  final DateTime createdAt;

  LearningQuestion({
    required this.id,
    required this.sessionId,
    required this.questionType,
    required this.questionText,
    required this.questionData,
    required this.difficultyLevel,
    this.skillFocus,
    this.expectedAnswer,
    required this.evaluationCriteria,
    required this.status,
    required this.createdAt,
  });

  factory LearningQuestion.fromJson(Map<String, dynamic> json) {
    return LearningQuestion(
      id: json['id'],
      sessionId: json['session_id'],
      questionType: json['question_type'],
      questionText: json['question_text'],
      questionData: json['question_data'] ?? {},
      difficultyLevel: json['difficulty_level'],
      skillFocus: json['skill_focus'],
      expectedAnswer: json['expected_answer'],
      evaluationCriteria: json['evaluation_criteria'] ?? {},
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'question_type': questionType,
      'question_text': questionText,
      'question_data': questionData,
      'difficulty_level': difficultyLevel,
      'skill_focus': skillFocus,
      'expected_answer': expectedAnswer,
      'evaluation_criteria': evaluationCriteria,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'LearningQuestion{id: $id, questionType: $questionType, difficultyLevel: $difficultyLevel, status: $status}';
  }
}

class LearningAnswer {
  final int id;
  final int questionId;
  final int sessionId;
  final String userAnswer;
  final Map<String, dynamic> answerData;
  final bool? isCorrect;
  final double? confidenceScore;
  final String? skillLevelDemonstrated;
  final String? feedbackText;
  final List<String> improvementSuggestions;
  final List<String> strengthsIdentified;
  final DateTime answeredAt;
  final DateTime? evaluatedAt;

  LearningAnswer({
    required this.id,
    required this.questionId,
    required this.sessionId,
    required this.userAnswer,
    required this.answerData,
    this.isCorrect,
    this.confidenceScore,
    this.skillLevelDemonstrated,
    this.feedbackText,
    required this.improvementSuggestions,
    required this.strengthsIdentified,
    required this.answeredAt,
    this.evaluatedAt,
  });

  factory LearningAnswer.fromJson(Map<String, dynamic> json) {
    return LearningAnswer(
      id: json['id'],
      questionId: json['question_id'],
      sessionId: json['session_id'],
      userAnswer: json['user_answer'],
      answerData: json['answer_data'] ?? {},
      isCorrect: json['is_correct'],
      confidenceScore: json['confidence_score']?.toDouble(),
      skillLevelDemonstrated: json['skill_level_demonstrated'],
      feedbackText: json['feedback_text'],
      improvementSuggestions: List<String>.from(json['improvement_suggestions'] ?? []),
      strengthsIdentified: List<String>.from(json['strengths_identified'] ?? []),
      answeredAt: DateTime.parse(json['answered_at']),
      evaluatedAt: json['evaluated_at'] != null ? DateTime.parse(json['evaluated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'session_id': sessionId,
      'user_answer': userAnswer,
      'answer_data': answerData,
      'is_correct': isCorrect,
      'confidence_score': confidenceScore,
      'skill_level_demonstrated': skillLevelDemonstrated,
      'feedback_text': feedbackText,
      'improvement_suggestions': improvementSuggestions,
      'strengths_identified': strengthsIdentified,
      'answered_at': answeredAt.toIso8601String(),
      'evaluated_at': evaluatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'LearningAnswer{id: $id, isCorrect: $isCorrect, confidenceScore: $confidenceScore}';
  }
}

class LearningSessionProgress {
  final int sessionId;
  final String skillId;
  final String currentLevel;
  final String targetLevel;
  final double progressPercentage;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final int currentStreak;
  final int maxStreak;
  final String status;
  final SkillProgressSnapshot? latestSnapshot;

  LearningSessionProgress({
    required this.sessionId,
    required this.skillId,
    required this.currentLevel,
    required this.targetLevel,
    required this.progressPercentage,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.currentStreak,
    required this.maxStreak,
    required this.status,
    this.latestSnapshot,
  });

  factory LearningSessionProgress.fromJson(Map<String, dynamic> json) {
    return LearningSessionProgress(
      sessionId: json['session_id'],
      skillId: json['skill_id'],
      currentLevel: json['current_level'],
      targetLevel: json['target_level'],
      progressPercentage: json['progress_percentage'].toDouble(),
      totalQuestions: json['total_questions'],
      correctAnswers: json['correct_answers'],
      accuracy: json['accuracy'].toDouble(),
      currentStreak: json['current_streak'],
      maxStreak: json['max_streak'],
      status: json['status'],
      latestSnapshot: json['latest_snapshot'] != null 
          ? SkillProgressSnapshot.fromJson(json['latest_snapshot']) 
          : null,
    );
  }

  @override
  String toString() {
    return 'LearningSessionProgress{sessionId: $sessionId, skillId: $skillId, currentLevel: $currentLevel, progressPercentage: ${progressPercentage.toStringAsFixed(1)}%}';
  }
}

class SkillProgressSnapshot {
  final int id;
  final int userId;
  final int matrixId;
  final String skillId;
  final int? sessionId;
  final String currentLevel;
  final double progressPercentage;
  final double confidenceScore;
  final List<String> completedCriteria;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final Map<String, dynamic> learningContext;
  final DateTime createdAt;

  SkillProgressSnapshot({
    required this.id,
    required this.userId,
    required this.matrixId,
    required this.skillId,
    this.sessionId,
    required this.currentLevel,
    required this.progressPercentage,
    required this.confidenceScore,
    required this.completedCriteria,
    required this.strengths,
    required this.areasForImprovement,
    required this.learningContext,
    required this.createdAt,
  });

  factory SkillProgressSnapshot.fromJson(Map<String, dynamic> json) {
    return SkillProgressSnapshot(
      id: json['id'],
      userId: json['user_id'],
      matrixId: json['matrix_id'],
      skillId: json['skill_id'],
      sessionId: json['session_id'],
      currentLevel: json['current_level'],
      progressPercentage: json['progress_percentage'].toDouble(),
      confidenceScore: json['confidence_score'].toDouble(),
      completedCriteria: List<String>.from(json['completed_criteria'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      areasForImprovement: List<String>.from(json['areas_for_improvement'] ?? []),
      learningContext: json['learning_context'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  String toString() {
    return 'SkillProgressSnapshot{id: $id, skillId: $skillId, currentLevel: $currentLevel, progressPercentage: ${progressPercentage.toStringAsFixed(1)}%}';
  }
}