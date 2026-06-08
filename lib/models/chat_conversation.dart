import 'message.dart';
import 'user.dart';

class ChatConversation {
  const ChatConversation({
    required this.user,
    required this.latestMessage,
    required this.unreadCount,
    this.pinUpdatedAt,
  });

  final User user;
  final Message latestMessage;
  final int unreadCount;
  final DateTime? pinUpdatedAt;

  bool get isPinned => pinUpdatedAt != null;

  String get displayName {
    final remarkName = user.remarkName?.trim();
    if (remarkName != null && remarkName.isNotEmpty) {
      return remarkName;
    }
    return user.name;
  }
}
