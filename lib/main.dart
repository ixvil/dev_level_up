import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- Localization Class ---
class AppLocalizations {
  final String locale;
  AppLocalizations(this.locale);
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome to DevLevelUp', 'username': 'Username', 'password': 'Password', 'login': 'Login', 'register': 'Register', 'networkError': 'Network error', 'welcomeUser': 'Welcome,',
      'dashboard': 'Dashboard', 'newAssessment': 'New Assessment', 'mySkills': 'My Skills', 'myGoals': 'My Goals', 'myPlans': 'My Plans', 'logout': 'Logout',
      'activePlans': 'Active Learning Plans', 'strongestSkills': 'Strongest Skills', 'weakestSkills': 'Weakest Skills', 'latestGoals': 'Latest Goals',
      'goalHint': 'e.g., "Senior Go Developer"', 'generateTest': 'Define Skills', 'assessmentFor': 'Assessment for', 'submitAndGetAnalysis': 'Submit & Get Analysis',
      'yourTestAnalysis': 'Your Test Analysis', 'strengths': 'Strengths', 'areasForImprovement': 'Areas for Improvement', 'generateLearningPlan': 'Generate My Learning Plan',
      'viewFullSkillProfile': 'View My Full Skill Profile', 'yourLearningPlan': 'Your Learning Plan', 'mySkillsProfileTitle': 'My Skills Profile',
      'competencyMatrix': 'Competency Matrix', 'noSkillsTested': 'You have not been tested on any skills yet.', 'lastTested': 'Last tested:', 'retest': 'Retest', 'never': 'Never',
      'selectLanguage': 'Select Language', 'startLearning': 'Start Learning', 'goalName': 'Goal Name', 'match': 'Match', 'noGoals': 'You haven\'t set any goals yet.',
      'planTitle': 'Plan Title', 'progress': 'Progress', 'noPlans': 'You don\'t have any learning plans yet.', 'planDetails': 'Plan Details', 'allGoals': 'All Career Goals',
      'whatToTest': 'What is your career goal?', 'pleaseDescribeGoal': 'Please describe your goal.',
      'noGoalsPrompt': 'Let\'s set your first career goal!', 'skillsForGoal': 'Skills for Goal', 'assessSkillsPrompt': 'Assess the following skills to calculate your match percentage for this goal.', 'startTest': 'Start Test',
      'finishAssessment': 'Finish Assessment', 'submitAndContinue': 'Submit & Continue', 'assessmentComplete': 'Assessment Complete!', 'yourNewLevel': 'Your new level for this skill is', 'submitAnswer': 'Submit Answer'
    },
    'ru': {
      'welcome': 'Добро пожаловать в DevLevelUp', 'username': 'Имя пользователя', 'password': 'Пароль', 'login': 'Войти', 'register': 'Регистрация', 'networkError': 'Сетевая ошибка', 'welcomeUser': 'Привет,',
      'dashboard': 'Дашборд', 'newAssessment': 'Новый тест', 'mySkills': 'Мои навыки', 'myGoals': 'Мои цели', 'myPlans': 'Мои планы', 'logout': 'Выйти',
      'activePlans': 'Активные планы обучения', 'strongestSkills': 'Самые сильные навыки', 'weakestSkills': 'Самые слабые навыки', 'latestGoals': 'Последние цели',
      'goalHint': 'Например, "Senior Go Developer"', 'generateTest': 'Определить навыки', 'assessmentFor': 'Тест для', 'submitAndGetAnalysis': 'Отправить и получить анализ',
      'yourTestAnalysis': 'Анализ вашего теста', 'strengths': 'Сильные стороны', 'areasForImprovement': 'Зоны для улучшения', 'generateLearningPlan': 'Сгенерировать мой план обучения',
      'viewFullSkillProfile': 'Посмотреть полный профиль навыков', 'yourLearningPlan': 'Ваш план обучения', 'mySkillsProfileTitle': 'Мой профиль навыков',
      'competencyMatrix': 'Матрица компетенций', 'noSkillsTested': 'Вы еще не проходили тесты.', 'lastTested': 'Последний тест:', 'retest': 'Пересдать', 'never': 'Никогда',
      'selectLanguage': 'Выберите язык', 'startLearning': 'Начать обучение', 'goalName': 'Название цели', 'match': 'Соответствие', 'noGoals': 'У вас еще нет целей.',
      'planTitle': 'Название плана', 'progress': 'Прогресс', 'noPlans': 'У вас еще нет планов обучения.', 'planDetails': 'Детали плана', 'allGoals': 'Все карьерные цели',
      'whatToTest': 'Какая у вас карьерная цель?', 'pleaseDescribeGoal': 'Пожалуйста, опишите вашу цель.',
      'noGoalsPrompt': 'Давайте поставим вашу первую карьерную цель!', 'skillsForGoal': 'Навыки для цели', 'assessSkillsPrompt': 'Оцените следующие навыки, чтобы рассчитать ваше соответствие этой цели.', 'startTest': 'Начать тест',
      'finishAssessment': 'Завершить тест', 'submitAndContinue': 'Ответить и продолжить', 'assessmentComplete': 'Тест завершен!', 'yourNewLevel': 'Ваш новый уровень по этому навыку', 'submitAnswer': 'Отправить ответ'
    },
  };
  String get(String key) { return _localizedValues[locale]?[key] ?? _localizedValues['en']![key]!; }
}

// --- Global State & Models ---
class AuthUser { final int id; final String username; final String language; AuthUser({required this.id, required this.username, required this.language}); }
AuthUser? loggedInUser;
AppLocalizations localizations = AppLocalizations('en');

// --- Data Models ---
class GoalAssessmentIntro { final int goalId; final String goalName; final List<dynamic> skillsToAssess; GoalAssessmentIntro({required this.goalId, required this.goalName, required this.skillsToAssess}); factory GoalAssessmentIntro.fromJson(Map<String, dynamic> json) { return GoalAssessmentIntro(goalId: json['goal_id'] ?? 0, goalName: json['goal_name'] ?? '', skillsToAssess: json['skills_to_assess'] ?? []); } }
class Question { final String type; final String question; final String? codeSnippet; final List<String> options; final String? correctAnswer; String? userAnswer; Question({required this.type, required this.question, this.codeSnippet, required this.options, this.correctAnswer, this.userAnswer}); factory Question.fromJson(Map<String, dynamic> json) { return Question(type: json['type'] ?? 'open-ended', question: json['question'] ?? '', codeSnippet: json['code_snippet'], options: List<String>.from(json['options'] as List? ?? []), correctAnswer: json['correct_answer']); } }
class FinalResult { final String level; final int score; FinalResult({required this.level, required this.score}); factory FinalResult.fromJson(Map<String, dynamic> json) { return FinalResult(level: json['result']['final_level'] ?? 'Unranked', score: json['result']['final_score'] ?? 0);}}
class UserProfile { final String username; final List<SkillGroupModel> skillGroups; final List<GoalSummary> goals; UserProfile({required this.username, required this.skillGroups, required this.goals}); factory UserProfile.fromJson(Map<String, dynamic> json) { var groupsFromJson = json['skill_groups'] as List? ?? []; List<SkillGroupModel> groupList = groupsFromJson.map((s) => SkillGroupModel.fromJson(s)).toList(); var goalsFromJson = json['goals'] as List? ?? []; List<GoalSummary> goalList = goalsFromJson.map((g) => GoalSummary.fromJson(g)).toList(); return UserProfile(username: json['username'] ?? 'Unknown User', skillGroups: groupList, goals: goalList); } }
class SkillGroupModel { final String name; final List<UserSkillModel> skills; SkillGroupModel({required this.name, required this.skills}); factory SkillGroupModel.fromJson(Map<String, dynamic> json) { var skillsFromJson = json['skills'] as List? ?? []; List<UserSkillModel> skillList = skillsFromJson.map((s) => UserSkillModel.fromJson(s)).toList(); return SkillGroupModel(name: json['name'] ?? 'General', skills: skillList); } }
class UserSkillModel { final String name; final int score; final String level; final String? lastTested; UserSkillModel({required this.name, required this.score, required this.level, this.lastTested}); factory UserSkillModel.fromJson(Map<String, dynamic> json) { return UserSkillModel(name: json['name'] ?? 'Unknown Skill', score: json['score'] ?? 0, level: json['level'] ?? 'Unranked', lastTested: json['last_tested']); } }
class GoalSummary { final String name; final int matchPercentage; GoalSummary({required this.name, required this.matchPercentage}); factory GoalSummary.fromJson(Map<String, dynamic> json) { return GoalSummary(name: json['name'] ?? 'Unknown Goal', matchPercentage: json['match_percentage'] ?? 0); } }

// --- Main Entry Point & App Shell ---
void main() async { WidgetsFlutterBinding.ensureInitialized(); runApp(const MyApp()); }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevLevelUp',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true, scaffoldBackgroundColor: Colors.grey[50]),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/assessment': (context) => const GoalScreen(),
        '/skills': (context) => const SkillsProfileScreen(),
        // Add other main routes if they exist
      },
    );
  }
}

String getHost() { if (kIsWeb) return '127.0.0.1'; return Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'; }

// --- Auth State Mixin & Base Screen ---
mixin AuthenticatedState<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    if (loggedInUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
    } else {
      onUserAuthenticated();
    }
  }
  void onUserAuthenticated();
}
class BaseScreen extends StatelessWidget { final String title; final Widget body; const BaseScreen({super.key, required this.title, required this.body}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text(title)), drawer: const AppDrawer(), body: body); } }

// --- Screens ---
class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override _SplashScreenState createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() { super.initState(); _checkAuthAndNavigate(); }
  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    if (userId == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    loggedInUser = AuthUser(id: userId, username: prefs.getString('username')!, language: prefs.getString('language')!);
    localizations = AppLocalizations(loggedInUser!.language);
    Navigator.of(context).pushReplacementNamed('/skills');
  }
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text('DevLevelUp', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])));
}

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override _LoginScreenState createState() => _LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(); final _passwordController = TextEditingController(); bool _isLoading = false; String _selectedLanguage = 'en'; bool _isRegistering = false;
  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    final endpoint = _isRegistering ? '/register' : '/login';
    final bodyPayload = {'username': _usernameController.text, 'password': _passwordController.text};
    if (_isRegistering) { bodyPayload['language'] = _selectedLanguage; }
    try {
      final response = await http.post(Uri.parse('http://${getHost()}:5000$endpoint'), headers: {'Content-Type': 'application/json'}, body: json.encode(bodyPayload));
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        loggedInUser = AuthUser(id: body['user_id'], username: body['username'], language: body['language']);
        localizations = AppLocalizations(loggedInUser!.language);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', loggedInUser!.id); await prefs.setString('username', loggedInUser!.username); await prefs.setString('language', loggedInUser!.language);
        Navigator.of(context).pushReplacementNamed('/splash');
      } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(body['error']))); }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${localizations.get('networkError')}: $e')));
    } finally { if(mounted) setState(() => _isLoading = false); }
  }
  @override
  Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text(localizations.get('welcome'))), body: Padding(padding: const EdgeInsets.all(16.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ TextField(controller: _usernameController, decoration: InputDecoration(labelText: localizations.get('username'))), TextField(controller: _passwordController, decoration: InputDecoration(labelText: localizations.get('password')), obscureText: true), if (_isRegistering) ...[ const SizedBox(height: 20), DropdownButtonFormField<String>(value: _selectedLanguage, decoration: InputDecoration(labelText: localizations.get('selectLanguage'), border: OutlineInputBorder()), items: [ DropdownMenuItem(value: 'en', child: Text('English')), DropdownMenuItem(value: 'ru', child: Text('Русский')), ], onChanged: (value) { setState(() { _selectedLanguage = value!; }); }, ), ], const SizedBox(height: 20), if (_isLoading) const CircularProgressIndicator(), if (!_isLoading) Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [ ElevatedButton(onPressed: _handleAuth, child: Text(_isRegistering ? localizations.get('register') : localizations.get('login'))), TextButton(onPressed: () => setState(() => _isRegistering = !_isRegistering), child: Text(_isRegistering ? localizations.get('login') : localizations.get('register')),) ],), ],),), ); }
}

class AppDrawer extends StatelessWidget { const AppDrawer({super.key}); @override Widget build(BuildContext context) { return Drawer(child: ListView(padding: EdgeInsets.zero, children: [ UserAccountsDrawerHeader( accountName: Text(loggedInUser?.username ?? 'Guest'), accountEmail: Text(localizations.get('welcome')), currentAccountPicture: CircleAvatar(backgroundColor: Colors.white, child: Text(loggedInUser?.username.substring(0,1).toUpperCase() ?? "G")), ), ListTile(leading: const Icon(Icons.dashboard_outlined), title: Text(localizations.get('dashboard')), onTap: () => Navigator.pushReplacementNamed(context, '/dashboard')), ListTile(leading: const Icon(Icons.quiz_outlined), title: Text(localizations.get('newAssessment')), onTap: () => Navigator.pushReplacementNamed(context, '/assessment')), const Divider(), ListTile(leading: const Icon(Icons.psychology_outlined), title: Text(localizations.get('mySkills')), onTap: () => Navigator.pushReplacementNamed(context, '/skills')), ListTile(leading: const Icon(Icons.flag_outlined), title: Text(localizations.get('myGoals')), onTap: () => Navigator.pushReplacementNamed(context, '/goals')), ListTile(leading: const Icon(Icons.model_training_outlined), title: Text(localizations.get('myPlans')), onTap: () => Navigator.pushReplacementNamed(context, '/plans')), const Divider(), ListTile(leading: const Icon(Icons.logout), title: Text(localizations.get('logout')), onTap: () async { loggedInUser = null; final prefs = await SharedPreferences.getInstance(); await prefs.clear(); localizations = AppLocalizations('en'); Navigator.of(context).pushReplacementNamed('/login'); },), ],),); } }

class SkillsProfileScreen extends StatefulWidget { const SkillsProfileScreen({super.key}); @override _SkillsProfileScreenState createState() => _SkillsProfileScreenState(); }
class _SkillsProfileScreenState extends State<SkillsProfileScreen> with AuthenticatedState<SkillsProfileScreen> {
  Future<UserProfile>? _profileFuture;
  @override
  void onUserAuthenticated() { _loadProfile(); }
  void _loadProfile() { setState(() { _profileFuture = _fetchProfile(); }); }
  Future<UserProfile> _fetchProfile() async {
    final response = await http.get(Uri.parse('http://${getHost()}:5000/profile/${loggedInUser!.id}'));
    if (response.statusCode == 200) { return UserProfile.fromJson(json.decode(response.body)); } else { throw Exception('Failed to load profile'); }
  }
  
  Future<void> _startSkillTest(String skillName) async {
    final result = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => AdaptiveTestScreen(skillName: skillName)));
    if (result == true && mounted) { _loadProfile(); }
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('mySkillsProfileTitle'))), drawer: const AppDrawer(),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { return const Center(child: CircularProgressIndicator()); }
          if (snapshot.hasError) { return Center(child: Text('Error: ${snapshot.error}')); }
          if (snapshot.hasData) {
            final profile = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async => _loadProfile(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (profile.skillGroups.isEmpty) Center(child: Text(localizations.get('noSkillsTested'))),
                  ...profile.skillGroups.map((group) => ExpansionTile(
                    title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    initiallyExpanded: true,
                    children: group.skills.map((skill) => Card(
                      child: ListTile(
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${skill.score}%', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(skill.level, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        title: Text(skill.name),
                        subtitle: Text('${localizations.get('lastTested')} ${skill.lastTested ?? localizations.get('never')}'),
                        trailing: TextButton(
                          child: Text(localizations.get('retest')),
                          onPressed: () => _startSkillTest(skill.name),
                        ),
                      )
                    )).toList(),
                  )),
                ],
              ),
            );
          }
          return const Center(child: Text('No profile data.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/assessment'),
        label: Text(localizations.get('newAssessment')),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class GoalScreen extends StatefulWidget { const GoalScreen({super.key}); @override _GoalScreenState createState() => _GoalScreenState(); }
class _GoalScreenState extends State<GoalScreen> with AuthenticatedState<GoalScreen>{
  final _goalController = TextEditingController(); 
  bool _isLoading = false;

  @override
  void onUserAuthenticated() { /* No initial data loading needed */ }

  Future<void> _startGoalAssessment() async {
    if (_goalController.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(localizations.get('pleaseDescribeGoal')))); return; }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(Uri.parse('http://${getHost()}:5000/start-goal-assessment'), headers: {'Content-Type': 'application/json'}, body: json.encode({'goal': _goalController.text, 'user_id': loggedInUser!.id}));
      if (response.statusCode == 200) {
        final intro = GoalAssessmentIntro.fromJson(json.decode(response.body));
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => GoalSkillsListScreen(intro: intro)));
      } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${json.decode(response.body)['error']}'))); }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network Error: $e')));
    } finally { if(mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) { 
    if (loggedInUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(localizations.get('newAssessment'))), 
      drawer: const AppDrawer(), 
      body: Builder(builder: (context) {
        final isFirstTime = ModalRoute.of(context)?.settings.name == '/assessment';
        return Center(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [ 
          if (isFirstTime) Text(localizations.get('noGoalsPrompt'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center),
          if (isFirstTime) const SizedBox(height: 24),
          Text(localizations.get('whatToTest'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), 
          const SizedBox(height: 16), 
          TextField(controller: _goalController, decoration: InputDecoration(hintText: localizations.get('goalHint'), border: OutlineInputBorder())), 
          const SizedBox(height: 24), 
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _startGoalAssessment, child: Text(localizations.get('generateTest'))), 
        ], )));
      }), 
    ); 
  }
}

class GoalSkillsListScreen extends StatelessWidget { final GoalAssessmentIntro intro; const GoalSkillsListScreen({super.key, required this.intro});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${localizations.get('skillsForGoal')}: ${intro.goalName}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(localizations.get('assessSkillsPrompt'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...intro.skillsToAssess.map((skill) => Card(
            child: ListTile(
              title: Text(skill['name']),
              subtitle: Text(skill['group']),
              trailing: ElevatedButton(
                child: Text(localizations.get('startTest')),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdaptiveTestScreen(skillName: skill['name'])));
                },
              ),
            ),
          )),
        ],
      )
    );
  }
}

class AdaptiveTestScreen extends StatefulWidget { final String skillName; const AdaptiveTestScreen({super.key, required this.skillName}); @override _AdaptiveTestScreenState createState() => _AdaptiveTestScreenState(); }
class _AdaptiveTestScreenState extends State<AdaptiveTestScreen> with AuthenticatedState<AdaptiveTestScreen> {
  Future<List<Question>>? _historyFuture;
  int? _sessionId;
  @override
  void onUserAuthenticated() { _historyFuture = _startOrResumeTest(); }

  Future<List<Question>> _startOrResumeTest() async {
    final response = await http.post(Uri.parse('http://${getHost()}:5000/assessment/start'), headers: {'Content-Type': 'application/json'}, body: json.encode({'user_id': loggedInUser!.id, 'skill_name': widget.skillName}));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _sessionId = data['session_id'];
      return (data['history'] as List).map((q) => Question.fromJson(q)).toList();
    } else { throw Exception('Failed to start assessment: ${json.decode(response.body)['error']}'); }
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text('${localizations.get('assessmentFor')} ${widget.skillName}')),
      body: FutureBuilder<List<Question>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.hasData) {
            return AssessmentDialogueView(
              sessionId: _sessionId!,
              initialHistory: snapshot.data!,
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
  final VoidCallback onCompleted;
  const AssessmentDialogueView({super.key, required this.sessionId, required this.initialHistory, required this.onCompleted});

  @override
  _AssessmentDialogueViewState createState() => _AssessmentDialogueViewState();
}
class _AssessmentDialogueViewState extends State<AssessmentDialogueView> with AuthenticatedState<AssessmentDialogueView> {
  late List<Question> _history;
  String? _multipleChoiceSelection;
  final _textAnswerController = TextEditingController();
  bool _isLoading = false;

  @override
  void onUserAuthenticated() {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide an answer.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://${getHost()}:5000/assessment/submit-answer'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'session_id': widget.sessionId, 'answer': answer}),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        if (body['status'] == 'completed') {
          final result = FinalResult.fromJson(body);
          _showCompletionDialog(result);
        } else {
          setState(() {
            _history = (body['history'] as List).map((q) => Question.fromJson(q)).toList();
            _multipleChoiceSelection = null;
            _textAnswerController.clear();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${body['error']}')));
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showCompletionDialog(FinalResult result) {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
        title: Text(localizations.get('assessmentComplete')),
        content: Text('${localizations.get('yourNewLevel')} ${result.level} (${result.score}%)'),
        actions: [ TextButton( child: const Text('OK'), onPressed: () { Navigator.of(context).pop(); widget.onCompleted(); },) ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) return const Center(child: CircularProgressIndicator());
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
                  _QuestionBubble(question: item),
                  if (item.userAnswer != null)
                    _AnswerBubble(answer: item.userAnswer!),
                  if (isLast)
                    _AnswerInput(
                      question: item,
                      onMcqSelected: (val) => setState(() => _multipleChoiceSelection = val),
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
              : ElevatedButton(onPressed: _submitAnswer, child: Text(localizations.get('submitAnswer'))),
        ),
      ],
    );
  }
}

// --- Widgets for Dialogue ---
class _QuestionBubble extends StatelessWidget {
  final Question question;
  const _QuestionBubble({required this.question});

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
          Text(question.question, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (question.codeSnippet != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              color: Colors.black87,
              child: Text(
                question.codeSnippet!,
                style: const TextStyle(fontFamily: 'monospace', color: Colors.white),
              ),
            )
          ]
        ],
      ),
    );
  }
}

class _AnswerBubble extends StatelessWidget {
  final String answer;
  const _AnswerBubble({required this.answer});

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

class _AnswerInput extends StatelessWidget {
  final Question question;
  final Function(String) onMcqSelected;
  final String? mcqSelection;
  final TextEditingController textController;

  const _AnswerInput({
    required this.question,
    required this.onMcqSelected,
    this.mcqSelection,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    if (question.type == 'multiple-choice') {
      return Column(
        children: question.options.map((opt) => RadioListTile<String>(
          title: Text(opt),
          value: opt,
          groupValue: mcqSelection,
          onChanged: (val) => onMcqSelected(val!),
        )).toList(),
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

