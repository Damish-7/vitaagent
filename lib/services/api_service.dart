import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Change to your machine's LAN IP when testing on a real device.
/// e.g. 'http://192.168.1.100:5000'
const String _baseUrl = 'http://localhost:5000';

// ── Token storage ──────────────────────────────────────────────────────────

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
}

// ── Base helpers ───────────────────────────────────────────────────────────

Future<Map<String, String>> _authHeaders() async {
  final token = await getToken();
  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

Future<http.Response> _get(String path) async =>
    http.get(Uri.parse('$_baseUrl$path'), headers: await _authHeaders());

Future<http.Response> _post(String path, Map<String, dynamic> body) async =>
    http.post(Uri.parse('$_baseUrl$path'),
        headers: await _authHeaders(), body: jsonEncode(body));

Future<http.Response> _patch(String path, Map<String, dynamic> body) async =>
    http.patch(Uri.parse('$_baseUrl$path'),
        headers: await _authHeaders(), body: jsonEncode(body));

// ── Auth ───────────────────────────────────────────────────────────────────

class AuthResult {
  final String? token;
  final int? userId;
  final String? name;
  final String? plan;
  final String? error;
  AuthResult({this.token, this.userId, this.name, this.plan, this.error});
}

class AuthService {
  static Future<AuthResult> login(String email, String password) async {
    try {
      final res =
          await _post('/api/auth/login', {'email': email, 'password': password});
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        await saveToken(d['access_token']);
        return AuthResult(
            token: d['access_token'],
            userId: d['user_id'],
            name: d['name'],
            plan: d['plan']);
      }
      return AuthResult(
          error: jsonDecode(res.body)['detail'] ?? 'Login failed');
    } catch (e) {
      return AuthResult(error: 'Connection error: $e');
    }
  }

  static Future<AuthResult> register(
      String name, String email, String password) async {
    try {
      final res = await _post('/api/auth/register',
          {'name': name, 'email': email, 'password': password});
      if (res.statusCode == 201) {
        final d = jsonDecode(res.body);
        await saveToken(d['access_token']);
        return AuthResult(
            token: d['access_token'],
            userId: d['user_id'],
            name: d['name'],
            plan: d['plan']);
      }
      return AuthResult(
          error: jsonDecode(res.body)['detail'] ?? 'Registration failed');
    } catch (e) {
      return AuthResult(error: 'Connection error: $e');
    }
  }

  static Future<void> logout() => clearToken();
}

// ── Chat ───────────────────────────────────────────────────────────────────

class ChatResponse {
  final String? error;
  final dynamic response;
  ChatResponse({this.error, this.response});
  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      ChatResponse(error: json['error'], response: json['response']);

  String get displayText {
    if (error != null) return 'Error: $error';
    if (response == null) return 'Sorry, I could not process that.';
    if (response is String) return _fmt(response as String);
    if (response is Map) {
      final r = response as Map;
      if (r['diet_plan'] != null) {
        final p = r['diet_plan'];
        final sb = StringBuffer('🍽️ Diet plan!\n\n🌅 Breakfast:\n');
        for (var i in (p['breakfast'] as List)) sb.write('  • $i\n');
        sb.write('\n☀️ Lunch:\n');
        for (var i in (p['lunch'] as List)) sb.write('  • $i\n');
        sb.write('\n🌙 Dinner:\n');
        for (var i in (p['dinner'] as List)) sb.write('  • $i\n');
        return sb.toString();
      }
      if (r['exercise_plan'] != null) {
        final p = r['exercise_plan'];
        final sb = StringBuffer('💪 Exercise plan!\n\n🌅 Morning:\n');
        for (var i in (p['morning'] as List)) sb.write('  • $i\n');
        sb.write('\n🌆 Evening:\n');
        for (var i in (p['evening'] as List)) sb.write('  • $i\n');
        if (r['advice'] != null) sb.write('\n💡 ${r['advice']}');
        return sb.toString();
      }
      if (r['advice'] != null) return '💡 ${r['advice']}';
      return jsonEncode(r);
    }
    return response.toString();
  }

  String _fmt(String t) => t
      .replaceAll(RegExp(r'###\s*'), '')
      .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
      .replaceAll(RegExp(r'^\s*[-–]\s*', multiLine: true), '• ')
      .trim();
}

// ── Main API service ───────────────────────────────────────────────────────

class ApiService {
  // Chat
  static Future<ChatResponse> sendMessage(String message) async {
    try {
      final res = await _post('/api/chat', {'message': message});
      if (res.statusCode == 200) return ChatResponse.fromJson(jsonDecode(res.body));
      return ChatResponse(error: 'Server error ${res.statusCode}');
    } catch (e) {
      return ChatResponse(
          error: 'Backend not reachable.\n'
              'Run: uvicorn main:app --port 5000 --reload');
    }
  }

  // Today metrics
  static Future<HealthMetrics?> getHealthMetrics() async {
    try {
      final res = await _get('/api/metrics/today');
      if (res.statusCode == 200) return HealthMetrics.fromJson(jsonDecode(res.body));
    } catch (_) {}
    return null;
  }

  // Weekly steps
  static Future<List<int>> getWeeklySteps() async {
    try {
      final res = await _get('/api/metrics/weekly');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return (data['days'] as List)
            .map<int>((d) => (d['steps'] as num).toInt())
            .toList();
      }
    } catch (_) {}
    return [7200, 9800, 6500, 10200, 8800, 4500, 8240];
  }

  // Update today's metrics
  static Future<bool> updateMetrics(Map<String, dynamic> metrics) async {
    try {
      final res = await _post('/api/metrics', metrics);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Dashboard
  static Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final res = await _get('/api/dashboard');
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  // Reports list
  static Future<List<dynamic>> getReports() async {
    try {
      final res = await _get('/api/reports');
      if (res.statusCode == 200) return jsonDecode(res.body) as List;
    } catch (_) {}
    return [];
  }

  // Upload report file
  static Future<bool> uploadReport(
      File file, String title, String? reportDate) async {
    try {
      final token = await getToken();
      final req = http.MultipartRequest(
          'POST', Uri.parse('$_baseUrl/api/reports/upload'));
      if (token != null) req.headers['Authorization'] = 'Bearer $token';
      req.files.add(await http.MultipartFile.fromPath('file', file.path));
      req.fields['title'] = title;
      if (reportDate != null) req.fields['report_date'] = reportDate;
      final res = await req.send();
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // Clinical history
  static Future<List<dynamic>> getClinicalHistory() async {
    try {
      final res = await _get('/api/history');
      if (res.statusCode == 200) return jsonDecode(res.body) as List;
    } catch (_) {}
    return [];
  }

  // Diet plan
  static Future<Map<String, dynamic>?> getDietPlan() async {
    try {
      final res = await _get('/api/plans/diet');
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  // Exercise plan
  static Future<Map<String, dynamic>?> getExercisePlan() async {
    try {
      final res = await _get('/api/plans/exercise');
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }
}

// ── Models ─────────────────────────────────────────────────────────────────

class HealthMetrics {
  final int steps;
  final int stepsGoal;
  final int caloriesBurned;
  final int caloriesConsumed;
  final double waterIntake;
  final double waterGoal;

  HealthMetrics({
    required this.steps,
    required this.stepsGoal,
    required this.caloriesBurned,
    required this.caloriesConsumed,
    required this.waterIntake,
    required this.waterGoal,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) => HealthMetrics(
        steps:            (json['steps']             as num?)?.toInt()    ?? 0,
        stepsGoal:        10000,
        caloriesBurned:   (json['calories_burned']   as num?)?.toInt()    ?? 0,
        caloriesConsumed: (json['calories_consumed'] as num?)?.toInt()    ?? 0,
        waterIntake:      (json['water_intake_l']    as num?)?.toDouble() ?? 0.0,
        waterGoal:        2.5,
      );
}