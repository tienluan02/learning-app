import 'package:mentor_mesh_hub/app/data/constants/constants.dart';

/// Conversation summary (one card in the chat list)
class ChatModel {
  final String userId;
  final String name;
  final String lastMessage;
  final String imageURL;
  final DateTime lastMessageAt;

  ChatModel({
    required this.userId,
    required this.name,
    required this.lastMessage,
    required this.imageURL,
    required this.lastMessageAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // Parse datetime and convert to local timezone
    DateTime? parsedDate;
    final dateStr = json['lastMessageAt']?.toString();
    if (dateStr != null && dateStr.isNotEmpty) {
      parsedDate = DateTime.tryParse(dateStr);
      if (parsedDate != null) {
        // Convert UTC to local time if it's UTC
        parsedDate = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;
      }
    }
    return ChatModel(
      userId: json['userId'].toString(),
      name: json['name'] ?? 'User',
      lastMessage: json['lastMessage'] ?? '',
      imageURL: ((json['profileImage'] as String?) ?? '').isNotEmpty
          ? json['profileImage'] as String
          : AppAssets.kUser1,
      lastMessageAt: parsedDate ?? DateTime.now(),
    );
  }

  /// Format time using device's local time with smart formatting
  String get timeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      lastMessageAt.year,
      lastMessageAt.month,
      lastMessageAt.day,
    );
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    // Format time part (e.g., "2:30 PM")
    final hour = lastMessageAt.hour;
    final minute = lastMessageAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    if (messageDate == today) {
      // Today: just show time
      return timeStr;
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday $timeStr';
    } else if (lastMessageAt.isAfter(weekAgo)) {
      // This week: show day name
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[lastMessageAt.weekday - 1]} $timeStr';
    } else {
      // Older: show date
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[lastMessageAt.month - 1]} ${lastMessageAt.day}, $timeStr';
    }
  }

  /// Backwards‑compatibility for old UI code (`chat.time`).
  String get time => timeLabel;

  /// Backwards‑compatibility for old UI code (`chat.messagename`).
  String get messagename => lastMessage;
}

/// Single chat message in a conversation
class ChatMessage {
  final String id;
  final String messageContent;
  final bool isMine;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  ChatMessage({
    required this.id,
    required this.messageContent,
    required this.isMine,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Parse datetime and convert to local timezone
    DateTime? parsedDate;
    final dateStr = json['createdAt']?.toString();
    if (dateStr != null && dateStr.isNotEmpty) {
      parsedDate = DateTime.tryParse(dateStr);
      if (parsedDate != null) {
        // Convert UTC to local time if it's UTC
        parsedDate = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;
      }
    }
    DateTime? parsedReadAt;
    final readAtStr = json['readAt']?.toString();
    if (readAtStr != null && readAtStr.isNotEmpty) {
      parsedReadAt = DateTime.tryParse(readAtStr);
      if (parsedReadAt != null) {
        parsedReadAt = parsedReadAt.isUtc ? parsedReadAt.toLocal() : parsedReadAt;
      }
    }

    return ChatMessage(
      id: json['id'].toString(),
      messageContent: json['content'] ?? '',
      isMine: json['isMine'] as bool? ?? false,
      createdAt: parsedDate ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      readAt: parsedReadAt,
    );
  }

  /// Backwards‑compatibility for old UI code (`chat.messageType`).
  /// We map `isMine == true` to `receiver` (bubble on the right).
  String get messageType => isMine ? 'receiver' : 'sender';

  /// Format message time using device's local time
  String get timeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );
    final yesterday = today.subtract(const Duration(days: 1));

    // Format time part (e.g., "2:30 PM")
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    if (messageDate == today) {
      // Today: just show time
      return timeStr;
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday $timeStr';
    } else {
      // Older: show date and time
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[createdAt.month - 1]} ${createdAt.day}, $timeStr';
    }
  }

  /// Human-friendly read status for outgoing messages
  String get readLabel {
    if (!isMine) return '';
    return isRead ? 'Seen' : 'Sent';
  }
}

class OnlinePeople {
  String image;
  String name;

  OnlinePeople({required this.image, required this.name});
}

List<OnlinePeople> onlinePeople = [
  OnlinePeople(
    image: AppAssets.kUser1,
    name: 'Alex',
  ),
  OnlinePeople(
    image: AppAssets.kUser2,
    name: 'Qin',
  ),
  OnlinePeople(
    image: AppAssets.kUser3,
    name: 'Harinder',
  ),
  OnlinePeople(
    image: AppAssets.kUser5,
    name: 'Lilah',
  ),
  OnlinePeople(
    image: AppAssets.kUser6,
    name: 'Martin',
  ),
];

/// Temporary in‑memory lists so existing UI (`chatList`, `messages`) compiles.
/// These will be replaced by real API‑driven data in the controller.
final List<ChatModel> chatList = <ChatModel>[];
final List<ChatMessage> messages = <ChatMessage>[];
