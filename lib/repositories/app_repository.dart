import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

import '../models/comment.dart';
import '../models/message.dart';
import '../models/post.dart';
import '../models/system_notification_item.dart';
import '../models/user.dart';

class AppRepository {
  static final AppRepository instance = AppRepository._internal();
  static const String officialSupportUserId = 'u_cs';
  static const String systemWelcomeMessage = '欢迎来到photomate，开启摄影分享新体验！';

  AppRepository._internal() {
    _initData();
  }

  String currentUserId = '';

  final List<User> users = [];
  final List<Post> posts = [];
  final List<Comment> comments = [];
  final List<Message> messages = [];
  final List<SystemNotificationItem> systemNotifications = [];

  final Map<String, Set<String>> _followingRelations = {};
  final Map<String, DateTime> _lastSeenAt = {};
  final Map<String, Map<String, DateTime>> _conversationPinTimes = {};
  final Map<String, Set<String>> _hiddenConversationUserIds = {};
  // userId -> list of (visitorUserId, visitedAt)
  final Map<String, List<({String visitorId, DateTime visitedAt})>> _visitors =
      {};

  void resetMockData() {
    currentUserId = '';
    users.clear();
    posts.clear();
    comments.clear();
    messages.clear();
    systemNotifications.clear();
    _followingRelations.clear();
    _lastSeenAt.clear();
    _conversationPinTimes.clear();
    _hiddenConversationUserIds.clear();
    _visitors.clear();
    _initData();
  }

  void _initData() {
    final now = DateTime.now();

    users.addAll([
      const User(
        id: 'u1',
        name: 'Ray Photographer',
        avatarUrl: 'assets/images/avatars/male/male_01.jpg',
        bio: '街拍与人文摄影爱好者',
        portfolioImages: [
          'assets/images/posts/old_street_1.jpg',
          'assets/images/posts/old_street_2.jpg',
          'assets/images/posts/rain_street.jpg',
        ],
        gender: 'male',
        birthday: '1998-04-12',
      ),
      const User(
        id: 'u2',
        name: 'Alice Wonders',
        avatarUrl: 'assets/images/avatars/female/female_01.jpg',
        bio: '胶片玩家，周末探店拍摄',
        portfolioImages: [
          'assets/images/posts/desert_sunset_1.jpg',
          'assets/images/posts/desert_sunset_2.jpg',
          'assets/images/posts/film_roll.webp',
        ],
        remarkName: 'Alice老师',
        gender: 'female',
        birthday: '1999-09-20',
      ),
      const User(
        id: 'u3',
        name: 'Bob Explorer',
        avatarUrl: 'assets/images/avatars/male/male_02.jpg',
        bio: '风光和徒步记录',
        portfolioImages: [
          'assets/images/posts/morning_valley.jpg',
          'assets/images/posts/building_facade.jpg',
        ],
        gender: 'male',
        birthday: '1995-01-18',
      ),
      const User(
        id: 'u4',
        name: '棠也',
        avatarUrl: 'assets/images/avatars/female/female_04.jpg',
        bio: '社牛属性拉满！刷到就是缘分',
        portfolioImages: [
          'assets/images/posts/city_flash_1.jpg',
          'assets/images/posts/city_flash_2.jpg',
          'assets/images/posts/city_flash_3.jpg',
        ],
        gender: 'female',
        birthday: '2001-04-10',
      ),
      const User(
        id: 'u5',
        name: 'David North',
        avatarUrl: 'assets/images/avatars/male/male_03.jpg',
        bio: '器材党，分享拍摄参数',
        portfolioImages: [
          'assets/images/posts/lens_35mm.webp',
        ],
        gender: 'male',
        birthday: '1993-11-28',
      ),
      const User(
        id: 'u6',
        name: 'Eva Stories',
        avatarUrl: 'assets/images/avatars/female/female_03.jpg',
        bio: '旅行博主，记录城市温度',
        portfolioImages: [
          'assets/images/posts/city_flash_1.jpg',
          'assets/images/posts/city_flash_2.jpg',
          'assets/images/posts/city_flash_3.jpg',
        ],
        gender: 'female',
        birthday: '2000-03-11',
      ),
      const User(
        id: 'u7',
        name: 'Frank Motion',
        avatarUrl: 'assets/images/avatars/male/male_04.jpg',
        bio: '视频剪辑与航拍',
        portfolioImages: [
          'assets/images/posts/city_night.jpg',
        ],
        gender: 'male',
        birthday: '1996-08-09',
      ),
      const User(
        id: 'u8',
        name: 'Grace Film',
        avatarUrl: 'assets/images/avatars/female/female_04.jpg',
        bio: '日常胶片与暗房冲洗',
        portfolioImages: [
          'assets/images/posts/film_roll.webp',
          'assets/images/posts/desert_sunset_2.jpg',
        ],
        gender: 'female',
        birthday: '2001-12-03',
      ),
      const User(
        id: 'u9',
        name: 'Hana Light',
        avatarUrl: 'assets/images/avatars/female/female_05.jpg',
        bio: '自然光人像 / 旅拍',
        gender: 'female',
        birthday: '2000-05-14',
      ),
      const User(
        id: 'u10',
        name: 'Iris Moon',
        avatarUrl: 'assets/images/avatars/female/female_06.jpg',
        bio: '写真约拍，夜景灯光',
        gender: 'female',
        birthday: '2002-02-19',
      ),
      const User(
        id: 'u11',
        name: 'Jade Dream',
        avatarUrl: 'assets/images/avatars/female/female_07.jpg',
        bio: '咖啡店与旅行胶片',
        gender: 'female',
        birthday: '2001-08-08',
      ),
      const User(
        id: officialSupportUserId,
        name: '官方客服',
        avatarUrl: 'assets/images/avatars/female/female_08.jpg',
        bio: '在线为你处理账号、支付与内容问题',
        gender: 'female',
        birthday: '1994-06-06',
      ),
    ]);

    _followingRelations.addAll({
      'u1': {'u2', 'u3', 'u4', 'u6', 'u9'},
      'u2': {'u1', 'u8'},
      'u3': {'u1', 'u5'},
      'u4': {'u1', 'u6'},
      'u5': {'u1', 'u2', 'u3'},
      'u6': {'u1', 'u4', 'u7'},
      'u7': {'u1', 'u3'},
      'u8': {'u2', 'u6'},
      'u9': {'u1', 'u6'},
      'u10': {'u1', 'u2'},
      'u11': {'u1', 'u4'},
    });

    _lastSeenAt.addAll({
      'u1': now.subtract(const Duration(minutes: 2)),
      'u2': now.subtract(const Duration(minutes: 18)),
      'u3': now.subtract(const Duration(minutes: 41)),
      'u4': now.subtract(const Duration(seconds: 20)),
      'u5': now.subtract(const Duration(hours: 3, minutes: 14)),
      'u6': now.subtract(const Duration(minutes: 9)),
      'u7': now.subtract(const Duration(hours: 6, minutes: 33)),
      'u8': now.subtract(const Duration(days: 1, minutes: 12)),
      'u9': now.subtract(const Duration(minutes: 6)),
      'u10': now.subtract(const Duration(minutes: 24)),
      'u11': now.subtract(const Duration(hours: 2, minutes: 5)),
      officialSupportUserId: now.subtract(const Duration(minutes: 1)),
    });

    // Mock 置顶联系人（对齐 vv2「我的置顶」截图）
    _conversationPinTimes['u1'] = {
      'u4': now.subtract(const Duration(hours: 1)),
    };

    posts.addAll([
      Post(
        id: 'p1',
        userId: 'u1',
        images: [
          'assets/images/posts/old_street_1.jpg',
          'assets/images/posts/old_street_2.jpg',
        ],
        content: '老街下午的光影太漂亮了，今天快门按到停不下来。',
        likesCount: 358,
        commentsCount: 122,
        isLiked: true,
        createdAt: now.subtract(const Duration(minutes: 30)),
        category: '人物',
      ),
      Post(
        id: 'p2',
        userId: 'u2',
        images: [
          'assets/images/posts/desert_sunset_1.jpg',
          'assets/images/posts/desert_sunset_2.jpg',
        ],
        content: '沙漠的风很大，但夕阳真值得。',
        likesCount: 358,
        commentsCount: 122,
        isLiked: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        category: '风景',
      ),
      Post(
        id: 'p3',
        userId: 'u3',
        images: const [
          'assets/images/posts/morning_valley.jpg',
        ],
        content: '清晨六点的山谷，雾刚好。',
        likesCount: 1200,
        commentsCount: 45,
        isLiked: false,
        createdAt: now.subtract(const Duration(hours: 5)),
        category: '风景',
      ),
      Post(
        id: 'p4',
        userId: 'u4',
        images: const [
          'assets/images/posts/building_facade.jpg',
        ],
        content: '新的建筑项目交付，赶在天黑前拍完外立面。',
        likesCount: 212,
        commentsCount: 15,
        isLiked: false,
        createdAt: now.subtract(const Duration(hours: 9)),
        category: '风景',
      ),
      Post(
        id: 'p5',
        userId: 'u5',
        images: const [
          'assets/images/posts/lens_35mm.webp',
        ],
        content: '35mm 和 50mm 对比样片，晚上发参数。',
        likesCount: 56,
        commentsCount: 3,
        isLiked: false,
        createdAt: now.subtract(const Duration(hours: 11)),
        category: '写真',
      ),
      Post(
        id: 'p6',
        userId: 'u6',
        images: [
          'assets/images/posts/city_flash_1.jpg',
          'assets/images/posts/city_flash_2.jpg',
          'assets/images/posts/city_flash_3.jpg',
        ],
        content: '三城一日快闪，真的全靠咖啡续命。',
        likesCount: 421,
        commentsCount: 29,
        isLiked: true,
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        category: '人物',
      ),
      Post(
        id: 'p7',
        userId: 'u7',
        images: const [
          'assets/images/posts/city_night.jpg',
        ],
        content: '城市夜景延时导出中，先放一张封面。',
        likesCount: 137,
        commentsCount: 9,
        isLiked: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        category: '风景',
      ),
      Post(
        id: 'p8',
        userId: 'u8',
        images: const [
          'assets/images/posts/film_roll.webp',
        ],
        content: '今天冲洗了两卷胶片，颗粒感太喜欢了。',
        likesCount: 260,
        commentsCount: 17,
        isLiked: false,
        createdAt: now.subtract(const Duration(days: 2)),
        category: '写真',
      ),
      Post(
        id: 'p9',
        userId: 'u1',
        images: const [
          'assets/images/posts/rain_street.jpg',
        ],
        content: '雨后路面反光，拍街景真的加分。',
        likesCount: 98,
        commentsCount: 5,
        isLiked: false,
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
        category: '风景',
      ),
    ]);

    comments.addAll([
      Comment(
        id: 'c1',
        postId: 'p1',
        userId: 'u2',
        content: '这组色调好舒服。',
        createdAt: now.subtract(const Duration(minutes: 20)),
      ),
      Comment(
        id: 'c2',
        postId: 'p1',
        userId: 'u3',
        content: '构图很稳，学习了。',
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      Comment(
        id: 'c3',
        postId: 'p3',
        userId: 'u1',
        content: '这光线绝了，几点到的机位？',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Comment(
        id: 'c4',
        postId: 'p6',
        userId: 'u4',
        content: '第三张很有电影感。',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Comment(
        id: 'c5',
        postId: 'p8',
        userId: 'u6',
        content: '胶片味道太正了！',
        createdAt: now.subtract(const Duration(days: 1, hours: 12)),
      ),
    ]);

    messages.addAll([
      Message(
        id: 'm1',
        senderId: 'u2',
        receiverId: 'u1',
        content: '你周末有空去拍展吗？',
        createdAt: now.subtract(const Duration(hours: 10)),
        isRead: true,
      ),
      Message(
        id: 'm2',
        senderId: 'u1',
        receiverId: 'u2',
        content: '可以，周六下午我都在。',
        createdAt: now.subtract(const Duration(hours: 9, minutes: 50)),
        isRead: true,
      ),
      Message(
        id: 'm3',
        senderId: 'u3',
        receiverId: 'u1',
        content: '山上那条线路我发你了。',
        createdAt: now.subtract(const Duration(hours: 3, minutes: 20)),
        isRead: false,
      ),
      Message(
        id: 'm4',
        senderId: 'u4',
        receiverId: 'u1',
        content: '你好啊',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 40)),
        isRead: false,
      ),
      Message(
        id: 'm4_image',
        senderId: 'u1',
        receiverId: 'u4',
        content: '',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 35)),
        isRead: true,
        type: MessageType.image,
        mediaPath: 'assets/images/checkin/camera.png',
        thumbnailPath: 'assets/images/checkin/camera.png',
      ),
      Message(
        id: 'm5',
        senderId: 'u1',
        receiverId: 'u6',
        content: '你上次那组旅行图太好看了。',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 5)),
        isRead: true,
      ),
      Message(
        id: 'm6',
        senderId: 'u6',
        receiverId: 'u1',
        content: '😊',
        createdAt: now.subtract(const Duration(minutes: 58)),
        isRead: true,
        type: MessageType.emoji,
        emojiLabel: '可爱',
      ),
      Message(
        id: 'm18',
        senderId: 'u6',
        receiverId: 'u1',
        content: '',
        createdAt: now.subtract(const Duration(minutes: 56)),
        isRead: false,
        type: MessageType.image,
        mediaPath: 'assets/images/posts/city_flash_1.jpg',
        thumbnailPath: 'assets/images/posts/city_flash_1.jpg',
      ),
      Message(
        id: 'm7',
        senderId: 'u5',
        receiverId: 'u1',
        content: '新镜头到了，今晚试拍吗？',
        createdAt: now.subtract(const Duration(hours: 5, minutes: 12)),
        isRead: true,
      ),
      Message(
        id: 'm8',
        senderId: 'u1',
        receiverId: 'u5',
        content: '可以，带上三脚架。',
        createdAt: now.subtract(const Duration(hours: 4, minutes: 58)),
        isRead: true,
      ),
      Message(
        id: 'm9',
        senderId: 'u3',
        receiverId: 'u2',
        content: '你上次那卷胶片在哪冲的？',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 13)),
        isRead: false,
      ),
      Message(
        id: 'm10',
        senderId: 'u2',
        receiverId: 'u3',
        content: '我私聊你店铺地址。',
        createdAt: now.subtract(const Duration(hours: 2, minutes: 2)),
        isRead: false,
      ),
      Message(
        id: 'm11',
        senderId: 'u8',
        receiverId: 'u4',
        content: '下周建筑主题的拍摄活动要来吗？',
        createdAt: now.subtract(const Duration(hours: 7, minutes: 30)),
        isRead: true,
      ),
      Message(
        id: 'm12',
        senderId: 'u4',
        receiverId: 'u8',
        content: '来，顺便聊聊后期流程。',
        createdAt: now.subtract(const Duration(hours: 7, minutes: 10)),
        isRead: true,
      ),
      Message(
        id: 'm13',
        senderId: 'u7',
        receiverId: 'u6',
        content: '无人机电池充好了吗？',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 42)),
        isRead: false,
      ),
      Message(
        id: 'm14',
        senderId: 'u6',
        receiverId: 'u7',
        content: '已经充满，明早 6:30 出发。',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 21)),
        isRead: false,
      ),
      Message(
        id: 'm15',
        senderId: 'u8',
        receiverId: 'u2',
        content: '我把暗房笔记整理完了。',
        createdAt: now.subtract(const Duration(minutes: 48)),
        isRead: false,
      ),
      Message(
        id: 'm16',
        senderId: 'u2',
        receiverId: 'u8',
        content: '太好了，发我一份。',
        createdAt: now.subtract(const Duration(minutes: 37)),
        isRead: false,
      ),
      Message(
        id: 'm17',
        senderId: officialSupportUserId,
        receiverId: 'u1',
        content: '您好，这里是官方客服。你可直接发送“账号、支付、举报、建议”等关键词。',
        createdAt: now.subtract(const Duration(minutes: 12)),
        isRead: false,
      ),
    ]);

    systemNotifications.addAll([
      SystemNotificationItem(
        id: 'sn_welcome',
        title: '系统通知',
        content: systemWelcomeMessage,
        createdAt: now.subtract(const Duration(minutes: 4)),
      ),
    ]);

    // Mock visitor records: u1 (Ray) sees who visited their profile
    _visitors['u1'] = [
      (visitorId: 'u4', visitedAt: now.subtract(const Duration(minutes: 5))),
      (visitorId: 'u4', visitedAt: now.subtract(const Duration(seconds: 30))),
    ];
  }

  User? getCurrentUser() {
    if (currentUserId.isEmpty) return null;
    return getUser(currentUserId);
  }

  void setCurrentUser(String userId) {
    if (userId.isEmpty) {
      currentUserId = '';
      return;
    }
    if (users.any((u) => u.id == userId)) {
      currentUserId = userId;
      _lastSeenAt[userId] = DateTime.now();
      ensureOfficialSupportConversation(userId);
    }
  }

  void setUserProfileCompleted(String userId, bool isProfileCompleted) {
    final userIndex = users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return;
    users[userIndex] = users[userIndex].copyWith(
      isProfileCompleted: isProfileCompleted,
    );
  }

  User getUser(String id) {
    return users.firstWhere((u) => u.id == id, orElse: () => users.first);
  }

  void updateUserProfile({
    required String userId,
    required String name,
    required String avatarUrl,
    required String bio,
    required String gender,
    String? birthday,
    required List<String> portfolioImages,
  }) {
    final userIndex = users.indexWhere((u) => u.id == userId);
    if (userIndex == -1) return;
    users[userIndex] = users[userIndex].copyWith(
      name: name,
      avatarUrl: avatarUrl,
      bio: bio,
      gender: gender,
      birthday: birthday,
      portfolioImages: List<String>.from(portfolioImages),
    );
  }

  List<User> getFollowingUsers(String userId) {
    final followingIds = _followingRelations[userId] ?? <String>{};
    return users.where((u) => followingIds.contains(u.id)).toList();
  }

  List<User> getFollowerUsers(String userId) {
    final followerIds = _followingRelations.entries
        .where((entry) => entry.value.contains(userId))
        .map((entry) => entry.key)
        .toSet();
    return users.where((u) => followerIds.contains(u.id)).toList();
  }

  /// 好友 = 互关用户（我关注 ∩ 关注我）
  List<User> getFriends(String userId) {
    final following = (_followingRelations[userId] ?? <String>{});
    final followers = _followingRelations.entries
        .where((entry) => entry.value.contains(userId))
        .map((entry) => entry.key)
        .toSet();
    final mutual = following.intersection(followers);
    return users.where((u) => mutual.contains(u.id)).toList();
  }

  int getFriendCount(String userId) => getFriends(userId).length;

  /// Returns list of (visitor user, visitedAt) in display order.
  List<({User user, DateTime visitedAt})> getVisitors(String userId) {
    final records = _visitors[userId] ?? [];
    final result = <({User user, DateTime visitedAt})>[];
    for (final r in records) {
      final idx = users.indexWhere((u) => u.id == r.visitorId);
      if (idx != -1) {
        result.add((user: users[idx], visitedAt: r.visitedAt));
      }
    }
    return result;
  }

  int getVisitorCount(String userId) => (_visitors[userId] ?? []).length;

  int getFollowingCount(String userId) {
    return (_followingRelations[userId] ?? <String>{}).length;
  }

  int getFollowerCount(String userId) {
    return _followingRelations.entries
        .where((entry) => entry.value.contains(userId))
        .length;
  }

  bool isFollowing(String userId, String targetUserId) {
    if (userId == targetUserId) return false;
    return (_followingRelations[userId] ?? <String>{}).contains(targetUserId);
  }

  void setFollowing(
    String userId,
    String targetUserId, {
    required bool following,
  }) {
    if (userId == targetUserId) return;
    final set = _followingRelations.putIfAbsent(userId, () => <String>{});
    if (following) {
      set.add(targetUserId);
    } else {
      set.remove(targetUserId);
    }
  }

  DateTime getLastSeenAt(String userId) {
    return _lastSeenAt[userId] ??
        DateTime.now().subtract(const Duration(days: 1));
  }

  bool isOfficialSupportUser(String userId) {
    return userId == officialSupportUserId;
  }

  List<SystemNotificationItem> getSystemNotificationsForUser(String userId) {
    final notifications =
        List<SystemNotificationItem>.from(systemNotifications);
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  int getSystemNotificationUnreadCount(String userId) {
    return systemNotifications.where((item) => !item.isReadFor(userId)).length;
  }

  SystemNotificationItem? getLatestSystemNotification(String userId) {
    final notifications = getSystemNotificationsForUser(userId);
    return notifications.isEmpty ? null : notifications.first;
  }

  void markAllSystemNotificationsRead(String userId) {
    for (var i = 0; i < systemNotifications.length; i++) {
      final item = systemNotifications[i];
      if (item.isReadFor(userId)) continue;
      systemNotifications[i] = item.copyWith(
        readUserIds: [...item.readUserIds, userId],
      );
    }
  }

  DateTime? getConversationPinUpdatedAt(String userId, String otherUserId) {
    return _conversationPinTimes[userId]?[otherUserId];
  }

  bool isConversationHidden(String userId, String otherUserId) {
    return _hiddenConversationUserIds[userId]?.contains(otherUserId) ?? false;
  }

  void pinConversation({
    required String userId,
    required String otherUserId,
  }) {
    final pinMap = _conversationPinTimes.putIfAbsent(
      userId,
      () => <String, DateTime>{},
    );
    pinMap[otherUserId] = DateTime.now();
    _hiddenConversationUserIds[userId]?.remove(otherUserId);
  }

  void unpinConversation({
    required String userId,
    required String otherUserId,
  }) {
    _conversationPinTimes[userId]?.remove(otherUserId);
  }

  void hideConversation({
    required String userId,
    required String otherUserId,
  }) {
    final hiddenIds =
        _hiddenConversationUserIds.putIfAbsent(userId, () => <String>{});
    hiddenIds.add(otherUserId);
  }

  void clearConversationList(String userId) {
    final otherIds = messages
        .where((message) =>
            message.senderId == userId || message.receiverId == userId)
        .map((message) =>
            message.senderId == userId ? message.receiverId : message.senderId)
        .toSet();
    final hiddenIds =
        _hiddenConversationUserIds.putIfAbsent(userId, () => <String>{});
    hiddenIds.addAll(otherIds);
  }

  void _revealConversation({
    required String userId,
    required String otherUserId,
  }) {
    _hiddenConversationUserIds[userId]?.remove(otherUserId);
  }

  void ensureOfficialSupportConversation(String userId) {
    if (userId == officialSupportUserId) return;
    final exists = messages.any((m) {
      return (m.senderId == officialSupportUserId && m.receiverId == userId) ||
          (m.senderId == userId && m.receiverId == officialSupportUserId);
    });
    if (exists) return;

    final now = DateTime.now();
    messages.add(
      Message(
        id: 'm${now.microsecondsSinceEpoch}',
        senderId: officialSupportUserId,
        receiverId: userId,
        content: '您好，官方客服在线。请描述你遇到的问题，我们会尽快处理。',
        createdAt: now,
        isRead: false,
      ),
    );
  }

  void markConversationAsRead({
    required String userId,
    required String otherUserId,
  }) {
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final isIncoming =
          message.senderId == otherUserId && message.receiverId == userId;
      if (isIncoming && !message.isRead) {
        messages[i] = message.copyWith(isRead: true);
      }
    }
  }

  void markAllMessagesAsRead(String userId) {
    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.receiverId == userId && !message.isRead) {
        messages[i] = message.copyWith(isRead: true);
      }
    }
  }

  String buildOfficialSupportReply(String text) {
    final normalized = text.trim().toLowerCase();
    if (normalized.contains('账号') || normalized.contains('登录')) {
      return '账号问题已记录。请提供账号 ID 与出现时间，我们 10 分钟内处理。';
    }
    if (normalized.contains('支付') ||
        normalized.contains('充值') ||
        normalized.contains('退款')) {
      return '支付问题已受理。请发送订单号后四位，我们会优先核查。';
    }
    if (normalized.contains('举报') || normalized.contains('违规')) {
      return '举报通道已开启。请补充用户 ID 或内容链接，我们会尽快审核。';
    }
    if (normalized.contains('建议') || normalized.contains('反馈')) {
      return '感谢反馈，产品同学会评估并回访你。';
    }
    if (normalized.contains('人工') || normalized.contains('转人工')) {
      return '已为你转接人工客服，请稍候 1-3 分钟。';
    }
    return '已收到，我们正在处理。你也可以补充截图或复现步骤，处理会更快。';
  }

  List<Post> getPostsForUser(String userId) {
    return posts.where((p) => p.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Post> getAllPosts() {
    return List<Post>.from(posts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Post? getPostById(String postId) {
    for (final post in posts) {
      if (post.id == postId) {
        return post;
      }
    }
    return null;
  }

  void removePost(String postId) {
    posts.removeWhere((post) => post.id == postId);
    comments.removeWhere((comment) => comment.postId == postId);
  }

  List<Comment> getCommentsForPost(String postId) {
    return comments.where((c) => c.postId == postId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// 一级评论（parentId == null），按时间升序
  List<Comment> getTopLevelComments(String postId) {
    return comments
        .where((c) => c.postId == postId && c.parentId == null)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// 某条一级评论下的二级回复，按时间升序
  List<Comment> getReplies(String parentId) {
    return comments.where((c) => c.parentId == parentId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// 删除评论；若为一级评论，关联的二级回复同步删除
  void deleteComment(String commentId) {
    final target = comments.where((c) => c.id == commentId).toList();
    if (target.isEmpty) return;
    final comment = target.first;

    int removed = 0;
    if (comment.parentId == null) {
      // 一级评论 + 其全部回复
      final replyCount = comments.where((c) => c.parentId == commentId).length;
      removed = 1 + replyCount;
      comments.removeWhere((c) => c.id == commentId || c.parentId == commentId);
    } else {
      removed = 1;
      comments.removeWhere((c) => c.id == commentId);
    }

    final postIndex = posts.indexWhere((post) => post.id == comment.postId);
    if (postIndex != -1) {
      final post = posts[postIndex];
      final next = (post.commentsCount - removed).clamp(0, 1 << 30);
      posts[postIndex] = post.copyWith(commentsCount: next);
    }
  }

  Post addPost({
    required String userId,
    required String content,
    required List<String> images,
    String? videoUrl,
    String? category,
  }) {
    final now = DateTime.now();
    final post = Post(
      id: 'p${now.microsecondsSinceEpoch}',
      userId: userId,
      images: List<String>.from(images),
      content: content,
      videoUrl: videoUrl,
      category: category,
      likesCount: 0,
      commentsCount: 0,
      isLiked: false,
      createdAt: now,
    );
    posts.insert(0, post);
    return post;
  }

  Message addMessage({
    required String senderId,
    required String receiverId,
    required String content,
    bool isRead = false,
    MessageType type = MessageType.text,
    String? mediaPath,
    String? thumbnailPath,
    int? voiceDurationSeconds,
    String? emojiLabel,
    MessageSendStatus sendStatus = MessageSendStatus.sent,
  }) {
    final now = DateTime.now();
    final message = Message(
      id: 'm${now.microsecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      createdAt: now,
      isRead: isRead,
      type: type,
      mediaPath: mediaPath,
      thumbnailPath: thumbnailPath,
      voiceDurationSeconds: voiceDurationSeconds,
      emojiLabel: emojiLabel,
      sendStatus: sendStatus,
    );
    messages.add(message);
    _lastSeenAt[senderId] = now;
    _revealConversation(userId: senderId, otherUserId: receiverId);
    _revealConversation(userId: receiverId, otherUserId: senderId);
    return message;
  }

  void updateMessage(String messageId, Message updatedMessage) {
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;
    messages[index] = updatedMessage;
  }

  void deleteMessageForUser({
    required String messageId,
    required String userId,
  }) {
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;
    final message = messages[index];
    if (message.hiddenForUserIds.contains(userId)) return;
    messages[index] = message.copyWith(
      hiddenForUserIds: [...message.hiddenForUserIds, userId],
    );
  }

  bool canRecallMessage({
    required Message message,
    required String userId,
  }) {
    if (message.senderId != userId) return false;
    if (message.type == MessageType.recall ||
        message.type == MessageType.system) {
      return false;
    }
    final diff = DateTime.now().difference(message.createdAt);
    return diff <= const Duration(minutes: 2);
  }

  void recallMessage({
    required String messageId,
    required String operatorUserId,
  }) {
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;
    final message = messages[index];
    if (!canRecallMessage(message: message, userId: operatorUserId)) return;
    messages[index] = message.copyWith(
      type: MessageType.recall,
      content: '',
      isRead: true,
      mediaPath: null,
      thumbnailPath: null,
      voiceDurationSeconds: null,
      emojiLabel: null,
      sendStatus: MessageSendStatus.sent,
      recalledByUserId: operatorUserId,
      recalledAt: DateTime.now(),
    );
  }

  void retryMessage(String messageId) {
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;
    final message = messages[index];
    final now = DateTime.now();
    messages[index] = message.copyWith(
      sendStatus: MessageSendStatus.sent,
      createdAt: now,
    );
    _lastSeenAt[message.senderId] = now;
    _revealConversation(
        userId: message.senderId, otherUserId: message.receiverId);
    _revealConversation(
        userId: message.receiverId, otherUserId: message.senderId);
  }

  Future<bool> saveMessageMediaToGallery(Message message) async {
    final source = message.mediaPath ?? message.thumbnailPath;
    if (source == null || source.isEmpty) return false;

    final resolvedPath = await _resolveSavablePath(source);
    if (resolvedPath == null) return false;

    final result = message.type == MessageType.video
        ? await GallerySaver.saveVideo(resolvedPath, albumName: 'photomate')
        : await GallerySaver.saveImage(resolvedPath, albumName: 'photomate');
    return result ?? false;
  }

  Future<String?> _resolveSavablePath(String source) async {
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return source;
    }

    final localPath = _normalizeLocalPath(source);
    if (localPath != null) {
      final file = File(localPath);
      return file.existsSync() ? file.path : null;
    }

    if (!source.startsWith('assets/')) {
      return null;
    }

    final tempDirectory = await getTemporaryDirectory();
    final fileName = source.split('/').last;
    final targetPath = '${tempDirectory.path}/$fileName';
    final targetFile = File(targetPath);
    if (targetFile.existsSync()) {
      return targetFile.path;
    }
    final byteData = await rootBundle.load(source);
    await targetFile.writeAsBytes(
      byteData.buffer.asUint8List(),
      flush: true,
    );
    return targetFile.path;
  }

  String? _normalizeLocalPath(String value) {
    if (value.isEmpty) return null;
    if (value.startsWith('file://')) {
      return Uri.parse(value).toFilePath();
    }
    if (value.startsWith('/')) {
      return value;
    }
    return null;
  }

  Comment addComment({
    required String postId,
    required String userId,
    required String content,
    String? parentId,
    String? replyToUserId,
    String? replyToUserName,
  }) {
    final now = DateTime.now();
    final comment = Comment(
      id: 'c${now.microsecondsSinceEpoch}',
      postId: postId,
      userId: userId,
      content: content,
      createdAt: now,
      parentId: parentId,
      replyToUserId: replyToUserId,
      replyToUserName: replyToUserName,
    );
    comments.add(comment);

    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = posts[postIndex];
      posts[postIndex] = post.copyWith(commentsCount: post.commentsCount + 1);
    }

    return comment;
  }

  /// 返回当前用户已置顶的联系人列表，按置顶时间降序排列
  List<User> getPinnedUsers(String userId) {
    final pinMap = _conversationPinTimes[userId];
    if (pinMap == null || pinMap.isEmpty) return [];
    final sorted = pinMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .map((e) => users.firstWhere(
              (u) => u.id == e.key,
              orElse: () => users.first,
            ))
        .toList();
  }

  void togglePinnedUser({
    required String currentUserId,
    required String otherUserId,
  }) {
    final isPinned =
        _conversationPinTimes[currentUserId]?.containsKey(otherUserId) ?? false;
    if (isPinned) {
      unpinConversation(userId: currentUserId, otherUserId: otherUserId);
    } else {
      pinConversation(userId: currentUserId, otherUserId: otherUserId);
    }
  }

  bool isUserPinned(String currentUserId, String otherUserId) {
    return _conversationPinTimes[currentUserId]?.containsKey(otherUserId) ??
        false;
  }
}
