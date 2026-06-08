import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageType {
  text,
  emoji,
  image,
  video,
  voice,
  recall,
  system,
}

enum MessageSendStatus {
  sending,
  sent,
  failed,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String senderId,
    required String receiverId,
    required String content,
    required DateTime createdAt,
    @Default(false) bool isRead,
    @Default(MessageType.text) MessageType type,
    String? mediaPath,
    String? thumbnailPath,
    int? voiceDurationSeconds,
    String? emojiLabel,
    @Default(MessageSendStatus.sent) MessageSendStatus sendStatus,
    @Default(<String>[]) List<String> hiddenForUserIds,
    String? recalledByUserId,
    DateTime? recalledAt,
    // Attached user for list display
    User? otherUser,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
