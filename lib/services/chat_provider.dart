import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hi! I'm Vijay, your AI health assistant. Ask me anything about your fitness, nutrition, or wellness goals! 💪",
      isUser: false,
    ),
  ];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    final response = await ApiService.sendMessage(text);

    _messages.add(ChatMessage(
      text: response.displayText,
      isUser: false,
    ));
    _isLoading = false;
    notifyListeners();
  }
}