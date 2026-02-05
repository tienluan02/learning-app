import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/chat_model.dart';
import 'package:mentor_mesh_hub/app/models/call_model.dart';
import 'package:mentor_mesh_hub/app/models/user_model.dart';
import 'package:mentor_mesh_hub/app/modules/video_call/video_call_view.dart';
import 'package:mentor_mesh_hub/app/controllers/auth_controller.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage chat;
  final String? otherUserName;
  final String? otherUserImage;
  final Function(String channelId)? onJoinCall;
  const ChatBubble({
    required this.chat,
    this.otherUserName,
    this.otherUserImage,
    this.onJoinCall,
    super.key,
  });

  // Check if message is a call invitation
  bool get _isCallInvitation {
    return chat.messageContent.startsWith('[CALL:');
  }

  // Extract channel ID from call invitation message
  String? _extractChannelId() {
    if (!_isCallInvitation) return null;
    final match = RegExp(r'\[CALL:(call_\d+_\d+)\]').firstMatch(chat.messageContent);
    return match?.group(1);
  }

  // Get human-friendly message text (without the channel ID marker)
  String get _displayMessage {
    if (_isCallInvitation) {
      // Extract the human-friendly part after [CALL:channelId]
      final match = RegExp(r'\[CALL:call_\d+_\d+\](.+)').firstMatch(chat.messageContent);
      return match?.group(1)?.trim() ?? chat.messageContent;
    }
    return chat.messageContent;
  }

  void _handleCallInvitationTap(BuildContext context) {
    final channelId = _extractChannelId();
    if (channelId == null) return;

    final auth = Get.find<AuthController>();
    final currentUser = auth.currentUser.value;
    
    if (currentUser == null) {
      Get.snackbar('Error', 'Please login to join the call');
      return;
    }

    // Extract user IDs from channel ID (format: call_minId_maxId)
    final parts = channelId.replaceFirst('call_', '').split('_');
    if (parts.length != 2) return;

    final minId = int.tryParse(parts[0]);
    final maxId = int.tryParse(parts[1]);
    if (minId == null || maxId == null) return;

    // Determine other user ID
    final currentUserId = int.tryParse(currentUser.id.toString()) ?? 0;
    final otherUserId = currentUserId == minId ? maxId : minId;

    // Get other user info
    final otherUser = UserModel(
      id: otherUserId.toString(),
      name: otherUserName ?? 'User',
      email: '',
      bio: '',
      profileImage: otherUserImage ?? '',
      role: 'student',
    );

    // Create call model
    final call = CallModel(
      callId: channelId,
      callerId: chat.isMine ? currentUserId : otherUserId,
      receiverId: chat.isMine ? otherUserId : currentUserId,
      callerName: chat.isMine ? currentUser.name : (otherUserName ?? 'User'),
      callerImage: chat.isMine ? currentUser.profileImage : (otherUserImage ?? ''),
      receiverName: chat.isMine ? (otherUserName ?? 'User') : currentUser.name,
      receiverImage: chat.isMine ? (otherUserImage ?? '') : currentUser.profileImage,
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

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) =>
        Theme.of(context).brightness == Brightness.dark;

    // `messageType` is provided by the model for backwards‑compatibility,
    // but alignment still depends on who sent the message.
    final isMine = chat.isMine;
    final isCallInvite = _isCallInvitation && !isMine;

    return Align(
      alignment:
          isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: isCallInvite ? () => _handleCallInvitationTap(context) : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isMine
                    ? (isDarkMode(context)
                        ? AppColors.kSecondary
                        : AppColors.kPrimary)
                    : (isDarkMode(context)
                        ? AppColors.kWhite
                        : AppColors.kPrimary.withValues(
                            alpha: (0.08 * 255).round().toDouble(),
                          )),
                borderRadius: BorderRadius.circular(10.r),
                border: isCallInvite
                    ? Border.all(color: AppColors.kPrimary, width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCallInvite) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.videocam,
                          color: isMine ? AppColors.kWhite : AppColors.kPrimary,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Video Call Invitation',
                          style: AppTypography.kBold14.copyWith(
                            color: isMine ? AppColors.kWhite : AppColors.kPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                  ],
                  Text(
                    _displayMessage,
                    style: AppTypography.kLight14.copyWith(
                      color: isMine ? AppColors.kWhite : Colors.black,
                    ),
                  ),
                  if (isCallInvite) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, color: Colors.white, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Join Call',
                            style: AppTypography.kBold14.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w, right: 4.w),
            child: isMine
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chat.timeLabel,
                        style: AppTypography.kLight14.copyWith(
                          fontSize: 10.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        chat.isRead ? Icons.done_all : Icons.check,
                        size: 14.sp,
                        color: chat.isRead ? AppColors.kPrimary : Colors.grey,
                      ),
                      if (chat.isRead) ...[
                        SizedBox(width: 4.w),
                        Text(
                          'Seen',
                          style: AppTypography.kLight14.copyWith(
                            fontSize: 10.sp,
                            color: AppColors.kPrimary,
                          ),
                        ),
                      ],
                    ],
                  )
                : Text(
                    chat.timeLabel,
                    style: AppTypography.kLight14.copyWith(
                      fontSize: 10.sp,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
