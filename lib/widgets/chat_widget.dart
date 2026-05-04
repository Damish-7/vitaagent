import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import '../theme/app_theme.dart';

class ChatFab extends StatefulWidget {
  const ChatFab({super.key});

  @override
  State<ChatFab> createState() => _ChatFabState();
}

class _ChatFabState extends State<ChatFab> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_open) ChatPanel(onClose: () => setState(() => _open = false)),
        FloatingActionButton(
          onPressed: () => setState(() => _open = !_open),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          child: Icon(_open ? Icons.close : Icons.chat_bubble_outline),
        ),
      ],
    );
  }
}

class ChatPanel extends StatefulWidget {
  final VoidCallback onClose;

  const ChatPanel({super.key, required this.onClose});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 70,
      right: 0,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 340,
          height: 480,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppTheme.primary,
                      child: Text('V',
                          style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vijay',
                              style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w500, fontSize: 14)),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                    color: AppTheme.success, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text('Online',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11, color: AppTheme.success)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chat, _) {
                    _scrollToBottom();
                    return ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == chat.messages.length) {
                          return _buildTyping();
                        }
                        final msg = chat.messages[i];
                        return _buildMessage(msg);
                      },
                    );
                  },
                ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        style: GoogleFonts.dmSans(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Ask Vijay anything...',
                          hintStyle: GoogleFonts.dmSans(
                              fontSize: 13, color: AppTheme.textMuted),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppTheme.primary),
                          ),
                          filled: true,
                          fillColor: AppTheme.background,
                        ),
                        onSubmitted: _send,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<ChatProvider>(
                      builder: (context, chat, _) => GestureDetector(
                        onTap: chat.isLoading ? null : () => _send(_ctrl.text),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: chat.isLoading
                                ? AppTheme.textMuted
                                : AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: msg.isUser ? AppTheme.primary : AppTheme.primaryLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(msg.isUser ? 12 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 12),
          ),
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            height: 1.55,
            color: msg.isUser ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTyping() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(
          'Vijay is thinking...',
          style: GoogleFonts.dmSans(
              fontSize: 13, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _ctrl.clear();
  }
}