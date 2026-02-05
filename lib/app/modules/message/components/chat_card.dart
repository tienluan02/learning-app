import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mentor_mesh_hub/app/data/constants/constants.dart';
import 'package:mentor_mesh_hub/app/models/chat_model.dart';
import 'package:mentor_mesh_hub/app/modules/message/conversation_view.dart';
import 'package:mentor_mesh_hub/app/modules/profile/components/profile_image_card.dart';

class ChatCard extends StatelessWidget {
  final ChatModel chat;
  const ChatCard({required this.chat, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () async {
          await Get.to<Widget>(() => ConversationView(chat: chat));
          // Refresh conversation list when returning
          // This will be handled by MessageView's auto-refresh
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          width: double.infinity,
          child: Row(
            children: [
              Hero(
                tag: chat.imageURL + chat.time,
                child: ProfileImageCard(
                  size: 50.h,
                  image: chat.imageURL,
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style: AppTypography.kBold16,
                    ),
                    Text(
                      '${chat.time} • ${chat.messagename}',
                      style: AppTypography.kLight14,
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
}
