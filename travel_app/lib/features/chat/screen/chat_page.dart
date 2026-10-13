import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/features/auth/provider/auth_providers.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/travel_db_model.dart';
import '../../../core/utils.dart';
import '../models/message_model.dart';
import '../provider/chat_provider.dart';
import '../provider/group_chat_provider.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/empty_state.dart';
import 'widgets/modern_input_field.dart';
import 'widgets/modern_chat_header.dart';

// Local in-memory message model for AI chat
class _AiMessage {
  final String text;
  final bool isUser;
  _AiMessage(this.text, this.isUser);
}

class ChatPage extends ConsumerStatefulWidget {
  final TravelDbModel trip;

  const ChatPage({super.key, required this.trip});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _aiScrollController = ScrollController();
  final ScrollController _groupScrollController = ScrollController();
  final List<_AiMessage> _aiMessages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String _sanitizeAiText(String input) {
    if (input.isEmpty) return input;
    var s = input;
    s = s.replaceAll(RegExp(r'[`*_]{1,3}'), '');
    s = s.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    s = s.replaceAll(RegExp(r'<[^>]*>'), '');
    s = s.replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return s.trim();
  }

  void _scrollToBottom(ScrollController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (controller.hasClients) {
          final position = controller.position.maxScrollExtent;
          await controller.animateTo(
            position,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } catch (_) {}
    });
  }

  Future<void> _sendAiMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Lấy lịch sử chat thực tế TRƯỚC khi thêm tin nhắn mới vào list hiển thị
    final chatHistoryList = _aiMessages.asMap().entries.map((entry) {
      return {
        'id': 'msg_${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
        'text': entry.value.text,
        'sender': entry.value.isUser ? 'user' : 'ai',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }).toList();

    _textController.clear();
    setState(() {
      _aiMessages.add(_AiMessage(text, true));
    });
    _scrollToBottom(_aiScrollController);

    try {
      final aiResponse = await ref
          .read(chatProvider.notifier)
          .getAiResponse(text, widget.trip, chatHistoryList);

      setState(() {
        _aiMessages.add(_AiMessage(_sanitizeAiText(aiResponse), false));
      });
    } catch (e) {
      setState(() {
        _aiMessages.add(_AiMessage(context.l10n.chat_error, false));
      });
    } finally {
      _scrollToBottom(_aiScrollController);
    }
  }

  Future<void> _sendGroupMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(userInfoProvider);
    if (user == null) return;

    _textController.clear();
    
    final message = MessageModel(
      id: '',
      senderId: user.uid,
      senderName: user.name ?? 'Người dùng',
      senderPhoto: user.profilePic,
      text: text,
      createdAt: DateTime.now(),
    );

    await ref.read(groupChatRepositoryProvider).sendMessage(widget.trip.travelId, message);
    _scrollToBottom(_groupScrollController);
  }

  void _handleSend() {
    if (_tabController.index == 0) {
      _sendAiMessage();
    } else {
      _sendGroupMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: ModernChatHeader(
        destination: widget.trip.destination,
        subtitle: _tabController.index == 0 ? "Trợ lý AI" : "Trò chuyện nhóm",
        onBackPressed: () => Navigator.pop(context),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() {}),
          indicatorColor: Colors.blue.shade600,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: "Trợ lý AI"),
            Tab(text: "Trò chuyện nhóm"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAiView(),
                _buildGroupView(),
              ],
            ),
          ),
          ModernInputField(
            controller: _textController,
            onSend: _handleSend,
            isLoading: _tabController.index == 0 ? ref.watch(chatProvider) : false,
            onAttach: () {
              // TODO: Implement attachment picker later
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAiView() {
    final isTyping = ref.watch(chatProvider);
    if (_aiMessages.isEmpty) {
      return EmptyState(
        destination: widget.trip.destination,
        onSuggestionTap: (suggestion) {
          _textController.text = suggestion;
          _sendAiMessage();
        },
      );
    }
    return ListView.builder(
      controller: _aiScrollController,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _aiMessages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == _aiMessages.length) return const TypingIndicator();
        final m = _aiMessages[index];
        return _ChatBubble(text: m.text, isUser: m.isUser, senderName: m.isUser ? "Bạn" : "AI Du lịch");
      },
    );
  }

  Widget _buildGroupView() {
    final messagesAsync = ref.watch(groupMessagesProvider(widget.trip.travelId));
    final currentUser = ref.watch(userInfoProvider);

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "Bắt đầu trò chuyện với mọi người!",
                  style: GoogleFonts.beVietnamPro(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(_groupScrollController));
        return ListView.builder(
          controller: _groupScrollController,
          reverse: true, // Show newest at bottom
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final m = messages[index];
            final isMe = m.senderId == currentUser?.uid;
            return _ChatBubble(
              text: m.text,
              isUser: isMe,
              senderName: m.senderName,
              senderPhoto: m.senderPhoto,
              time: m.createdAt,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Lỗi: $e")),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _aiScrollController.dispose();
    _groupScrollController.dispose();
    super.dispose();
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String senderName;
  final String? senderPhoto;
  final DateTime? time;

  const _ChatBubble({
    required this.text,
    required this.isUser,
    required this.senderName,
    this.senderPhoto,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  senderName,
                  style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CircleAvatar(
                      radius: 14, 
                      backgroundColor: const Color(0xFFE4E6EB),
                      backgroundImage: getAvatarProvider(senderPhoto),
                      child: getAvatarProvider(senderPhoto) == null
                          ? const Icon(Icons.person, color: Color(0xFF8A8D91), size: 16)
                          : null,
                    ),
                  ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0084FF) : Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                    ),
                    child: Text(
                      text,
                      style: GoogleFonts.beVietnamPro(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (time != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 4, left: 4),
                child: Text(
                  DateFormat('HH:mm').format(time!),
                  style: GoogleFonts.beVietnamPro(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
