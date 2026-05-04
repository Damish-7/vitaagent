import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:5000';

  static Future<ChatResponse> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        return ChatResponse(
          error: 'Server error: ${response.statusCode}',
          response: null,
        );
      }
    } catch (e) {
      return ChatResponse(
        error: 'Connection failed. Is the backend running?\ncd backend && node server.js',
        response: null,
      );
    }
  }

  static Future<HealthMetrics?> getHealthMetrics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/metrics'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return HealthMetrics.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> uploadReport(String filePath, String fileName) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/reports/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['fileName'] = fileName;
      final response = await request.send();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ChatResponse {
  final String? error;
  final dynamic response;

  ChatResponse({this.error, this.response});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      error: json['error'],
      response: json['response'],
    );
  }

  String get displayText {
    if (error != null) return 'Error: $error';
    if (response == null) return 'Sorry, I could not process that.';

    if (response is String) return _formatText(response as String);

    if (response is Map) {
      final r = response as Map;
      if (r['diet_plan'] != null) {
        final plan = r['diet_plan'];
        final sb = StringBuffer('🍽️ Here\'s your diet plan!\n\n');
        sb.write('🌅 Breakfast:\n');
        for (var item in (plan['breakfast'] as List)) sb.write('  • $item\n');
        sb.write('\n☀️ Lunch:\n');
        for (var item in (plan['lunch'] as List)) sb.write('  • $item\n');
        sb.write('\n🌙 Dinner:\n');
        for (var item in (plan['dinner'] as List)) sb.write('  • $item\n');
        return sb.toString();
      } else if (r['exercise_plan'] != null) {
        final plan = r['exercise_plan'];
        final sb = StringBuffer('💪 Here\'s your exercise plan!\n\n');
        sb.write('🌅 Morning:\n');
        for (var item in (plan['morning'] as List)) sb.write('  • $item\n');
        sb.write('\n🌆 Evening:\n');
        for (var item in (plan['evening'] as List)) sb.write('  • $item\n');
        if (r['advice'] != null) sb.write('\n💡 Advice:\n  ${r['advice']}');
        return sb.toString();
      } else if (r['advice'] != null) {
        return '💡 ${r['advice']}';
      }
      return jsonEncode(r);
    }
    return response.toString();
  }

  String _formatText(String text) {
    return text
        .replaceAll(RegExp(r'###\s*'), '')
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
        .replaceAll(RegExp(r'^\s*[-–]\s*', multiLine: true), '• ')
        .trim();
  }
}

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

  factory HealthMetrics.fromJson(Map<String, dynamic> json) {
    return HealthMetrics(
      steps: json['steps'] ?? 8240,
      stepsGoal: json['stepsGoal'] ?? 10000,
      caloriesBurned: json['caloriesBurned'] ?? 420,
      caloriesConsumed: json['caloriesConsumed'] ?? 1840,
      waterIntake: (json['waterIntake'] ?? 1.8).toDouble(),
      waterGoal: (json['waterGoal'] ?? 2.5).toDouble(),
    );
  }
}