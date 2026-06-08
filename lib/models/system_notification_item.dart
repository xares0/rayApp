class SystemNotificationItem {
  const SystemNotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.actionLabel,
    this.actionRoute,
    this.readUserIds = const <String>[],
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? actionLabel;
  final String? actionRoute;
  final List<String> readUserIds;

  bool isReadFor(String userId) => readUserIds.contains(userId);

  SystemNotificationItem copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? actionLabel,
    String? actionRoute,
    List<String>? readUserIds,
  }) {
    return SystemNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
      readUserIds: readUserIds ?? this.readUserIds,
    );
  }
}
