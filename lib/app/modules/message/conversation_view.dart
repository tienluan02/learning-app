import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/chat_model.dart';
import 'package:mentor_mesh_hub/app/modules/message/components/chat_bubble.dart';
import 'package:mentor_mesh_hub/app/modules/message/components/message_appbar.dart';
import 'package:mentor_mesh_hub/app/modules/message/components/message_field.dart';
import 'package:mentor_mesh_hub/app/modules/profile/components/profile_image_card.dart';
import 'package:mentor_mesh_hub/app/modules/video_call/video_call_view.dart';
import 'package:mentor_mesh_hub/app/models/call_model.dart';
import 'package:mentor_mesh_hub/app/models/user_model.dart';
import 'package:mentor_mesh_hub/app/services/api_service.dart';

class ConversationView extends StatefulWidget {
  final ChatModel chat;
  const ConversationView({required this.chat, Key? key}) : super(key: key);

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> with WidgetsBindingObserver {
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isSending = false;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  late final int _currentUserId;

  ChatModel get chat => widget.chat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final user = auth.currentUser.value;
    var parsedId = -1;
    if (user != null) {
      final dynamic rawId = user.id;
      if (rawId is int) {
        parsedId = rawId;
      } else {
        final parsed = int.tryParse(rawId.toString());
        if (parsed != null) {
          parsedId = parsed;
        }
      }
    }
    _currentUserId = parsedId;
    // Load messages and scroll to bottom after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages(scrollToBottom: true);
    });
    // Start polling for new messages every 3 seconds
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh messages when app comes back to foreground
      _loadMessages();
    }
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _loadMessages();
        _startPolling(); // Schedule next poll
      }
    });
  }

  Future<void> _loadMessages({bool scrollToBottom = false}) async {
    // Don't show loading indicator on polling updates
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final response = await ApiService.getMessagesWithUser(chat.userId);
      final data =
          (response['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final list = (data['messages'] as List<dynamic>?) ?? <dynamic>[];

      final loaded = list.map<ChatMessage>((raw) {
        final m = raw as Map<String, dynamic>;
        final senderRaw = m['senderId'] ?? m['sender_id'];
        final senderId = senderRaw is int
            ? senderRaw
            : int.tryParse(senderRaw?.toString() ?? '') ?? -1;
        // Inject `isMine` for the model factory and rely on backend read flags
        m['isMine'] = senderId == _currentUserId;
        return ChatMessage.fromJson(m);
      }).toList();

      // Check if user was at bottom before updating
      final wasAtBottom = _scrollController.hasClients &&
          _messages.isNotEmpty &&
          (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100);
      final isInitialLoad = _messages.isEmpty;
      final previousMessageCount = _messages.length;

      setState(() {
        _messages
          ..clear()
          ..addAll(loaded);
      });

      // Always scroll to bottom on initial load, when new messages arrive, or if explicitly requested
      final hasNewMessages = loaded.length > previousMessageCount;
      final shouldScroll = isInitialLoad || wasAtBottom || scrollToBottom || hasNewMessages;
      
      if (shouldScroll && loaded.isNotEmpty) {
        // Wait for the ListView to build and layout
        await Future.delayed(const Duration(milliseconds: 300));
        if (_scrollController.hasClients) {
          // Use jumpTo for immediate scroll on initial load or new messages
          if (isInitialLoad || scrollToBottom || hasNewMessages) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          } else {
            // Update - animate smoothly
            unawaited(
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
            );
          }
        }
      }
    } on Exception {
      // Optionally show an error snackbar
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startVideoCall() async {
    final auth = Get.find<AuthController>();
    final currentUser = auth.currentUser.value;
    
    if (currentUser == null) {
      Get.snackbar('Error', 'Please login to start a video call');
      return;
    }
    
    // Get other user info from chat
    final otherUser = UserModel(
      id: chat.userId.toString(),
      name: chat.name,
      email: '',
      bio: '',
      profileImage: chat.imageURL,
      role: 'student', // Default, adjust as needed
    );
    
    // Generate consistent channel ID from user IDs (so both users join same channel)
    final minId = _currentUserId < int.parse(chat.userId) ? _currentUserId : int.parse(chat.userId);
    final maxId = _currentUserId > int.parse(chat.userId) ? _currentUserId : int.parse(chat.userId);
    final channelId = 'call_${minId}_${maxId}';
    
    // Generate call ID for tracking
    final callId = '${channelId}_${DateTime.now().millisecondsSinceEpoch}';
    
    // Parse receiver ID to int
    final receiverId = int.tryParse(chat.userId) ?? 0;
    if (receiverId == 0) {
      Get.snackbar('Error', 'Invalid user ID');
      return;
    }
    
    // Create human-friendly invitation message based on role
    final isTeacher = currentUser.role.toLowerCase() == 'teacher';
    final callerName = currentUser.name;
    final invitationMessage = isTeacher
        ? '$callerName is calling you. Tap to join the call!'
        : '$callerName is inviting you to a meeting. Tap to join!';
    
    // Store channel ID in a hidden format that can be extracted
    // Format: [CALL:channelId] followed by human-friendly message
    final fullMessage = '[CALL:$channelId]$invitationMessage';
    
    // Send call invitation message
    try {
      await ApiService.sendMessageToUser(
        chat.userId,
        fullMessage,
      );
    } catch (e) {
      // Continue even if message sending fails
      debugPrint('Failed to send call invitation: $e');
    }
    
    // Create call model
    final call = CallModel(
      callId: channelId, // Use channelId as callId for consistency
      callerId: _currentUserId,
      receiverId: receiverId,
      callerName: currentUser.name,
      callerImage: currentUser.profileImage,
      receiverName: chat.name,
      receiverImage: chat.imageURL,
      type: CallType.video,
      status: CallStatus.ringing,
    );
    
    // Navigate to video call screen
    Get.to(() => VideoCallView(
      call: call,
      currentUser: currentUser,
      otherUser: otherUser,
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (_isSending) return;
    setState(() {
      _isSending = true;
    });

    try {
      final response =
          await ApiService.sendMessageToUser(chat.userId, text);
      final data =
          (response['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};

      setState(() {
        _messages.add(
          ChatMessage(
            id: data['id']?.toString() ?? DateTime.now().toIso8601String(),
            messageContent: data['content']?.toString() ?? text,
            isMine: true,
            createdAt: DateTime.tryParse(
                  data['createdAt']?.toString() ?? '',
                ) ??
                DateTime.now(),
            isRead: false,
          ),
        );
      });

      // Reload messages to get the latest from server (includes the one we just sent)
      await _loadMessages(scrollToBottom: true);
      
      // Ensure scroll to bottom after sending
      if (_scrollController.hasClients && _messages.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    } on Exception {
      // You can add a snackbar here if needed
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      appBar: const MessageAppBar(),
      body: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusThirty),
          ),
          color: isDarkMode(context) ? Colors.black : Colors.white,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30.r),
            ),
            color: AppColors.kPrimary.withValues(
              alpha: (0.4 * 255).round().toDouble(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(AppSpacing.twentyVertical),
                child: Row(
                  children: [
                    Hero(
                      tag: chat.imageURL + chat.time,
                      child: ProfileImageCard(
                        image: chat.imageURL,
                        size: 60.h,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chat.name, style: AppTypography.kBold16),
                        SizedBox(height: 6.h),
                      ],
                    ),
                    const Spacer(),
                    // Video call button
                    IconButton(
                      icon: const Icon(Icons.videocam),
                      color: AppColors.kPrimary,
                      tooltip: 'Video Call',
                      onPressed: () => _startVideoCall(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: isDarkMode(context) ? Colors.black : Colors.white,
                  child: _isLoading && _messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.all(AppSpacing.twentyVertical),
                          itemBuilder: (context, index) {
                            return ChatBubble(
                              chat: _messages[index],
                              otherUserName: widget.chat.name,
                              otherUserImage: widget.chat.imageURL,
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10.h),
                          itemCount: _messages.length,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: MessageField(
        onSend: _sendMessage,
      ),
    );
  }
}
