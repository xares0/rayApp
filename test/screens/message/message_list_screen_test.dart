import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/message/message_list_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  Future<void> pumpMessageListScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MessageListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('点击右上角管理按钮会显示气泡菜单', (tester) async {
    await pumpMessageListScreen(tester);

    expect(find.text('清空聊天列表'), findsNothing);

    await tester
        .tap(find.byKey(const ValueKey<String>('message_manage_button')));
    await tester.pumpAndSettle();

    expect(find.text('清空聊天列表'), findsOneWidget);
    expect(find.text('一键已读'), findsOneWidget);
  });

  testWidgets('点击空白区域会关闭气泡菜单', (tester) async {
    await pumpMessageListScreen(tester);

    await tester
        .tap(find.byKey(const ValueKey<String>('message_manage_button')));
    await tester.pumpAndSettle();
    expect(find.text('清空聊天列表'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('清空聊天列表'), findsNothing);
    expect(find.text('一键已读'), findsNothing);
  });

  testWidgets('点击清空聊天列表后会清空会话区域', (tester) async {
    await pumpMessageListScreen(tester);

    expect(find.text('官方客服'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('message_manage_button')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('message_manage_action_clear')));
    await tester.pumpAndSettle();

    expect(find.text('是否要清空聊天列表？'), findsOneWidget);
    expect(find.text('清空'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);

    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();

    expect(find.text('暂无会话，先去发现页找人聊聊吧'), findsOneWidget);
    expect(find.text('系统通知'), findsOneWidget);
    expect(find.text('官方客服'), findsNothing);
  });

  testWidgets('点击一键已读后会清掉消息和系统未读', (tester) async {
    await pumpMessageListScreen(tester);

    final unreadMessageCountBefore = AppRepository.instance.messages
        .where((message) => message.receiverId == 'u1' && !message.isRead)
        .length;
    final unreadNotificationCountBefore =
        AppRepository.instance.getSystemNotificationUnreadCount('u1');

    expect(unreadMessageCountBefore, greaterThan(0));
    expect(unreadNotificationCountBefore, greaterThan(0));

    await tester
        .tap(find.byKey(const ValueKey<String>('message_manage_button')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('message_manage_action_read')));
    await tester.pumpAndSettle();

    expect(find.text('是否要一键已读所有消息？'), findsOneWidget);
    expect(find.text('确定'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);

    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    final unreadMessages = AppRepository.instance.messages.where(
      (message) => message.receiverId == 'u1' && !message.isRead,
    );
    final hasUnreadNotifications = AppRepository.instance.systemNotifications
        .any((item) => !item.isReadFor('u1'));

    expect(unreadMessages, isEmpty);
    expect(hasUnreadNotifications, isFalse);
  });

  testWidgets('左滑会话会显示置顶和删除操作', (tester) async {
    await pumpMessageListScreen(tester);

    final swipeTile = find.byKey(
      const ValueKey<String>('message_swipe_tile_u2'),
    );
    expect(swipeTile, findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('message_action_pin_u2')).hitTestable(),
      findsNothing,
    );
    expect(
      find
          .byKey(const ValueKey<String>('message_action_delete_u2'))
          .hitTestable(),
      findsNothing,
    );

    await tester.drag(swipeTile, const Offset(-140, 0));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('message_action_pin_u2')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find
          .byKey(const ValueKey<String>('message_action_delete_u2'))
          .hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('置顶后官方客服仍固定在普通会话前面', (tester) async {
    await pumpMessageListScreen(tester);

    expect(
      AppRepository.instance.getConversationPinUpdatedAt('u1', 'u2'),
      isNull,
    );

    final swipeTile = find.byKey(
      const ValueKey<String>('message_swipe_tile_u2'),
    );
    await tester.drag(swipeTile, const Offset(-140, 0));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('message_action_pin_u2')));
    await tester.pumpAndSettle();

    expect(
      AppRepository.instance.getConversationPinUpdatedAt('u1', 'u2'),
      isNotNull,
    );

    final supportTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey<String>('message_conversation_tile_u_cs')),
    );
    final pinnedTopLeft = tester.getTopLeft(
      find.byKey(const ValueKey<String>('message_conversation_tile_u2')),
    );

    expect(supportTopLeft.dy, lessThan(pinnedTopLeft.dy));

    await tester.drag(swipeTile, const Offset(-140, 0));
    await tester.pumpAndSettle();
    expect(find.text('取消置顶'), findsOneWidget);
  });

  testWidgets('顶部背景固定且置顶会话背景会动态变化', (tester) async {
    await pumpMessageListScreen(tester);

    final headerBackground = find.byKey(
      const ValueKey<String>('message_header_background'),
    );
    final systemBackground = find.byKey(
      const ValueKey<String>('message_system_background'),
    );
    final supportBackground = find.byKey(
      const ValueKey<String>('message_conversation_background_u_cs'),
    );
    final conversationBackground = find.byKey(
      const ValueKey<String>('message_conversation_background_u2'),
    );
    final initialHeaderHeight = tester.getSize(headerBackground).height;

    expect(initialHeaderHeight, greaterThan(0));
    expect(
      tester.widget<ColoredBox>(systemBackground).color,
      const Color(0x33A699FF),
    );
    expect(
      tester.widget<ColoredBox>(supportBackground).color,
      const Color(0x33A699FF),
    );
    expect(
      tester.widget<ColoredBox>(conversationBackground).color,
      Colors.transparent,
    );

    final swipeTile = find.byKey(
      const ValueKey<String>('message_swipe_tile_u2'),
    );

    await tester.drag(swipeTile, const Offset(-140, 0));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const ValueKey<String>('message_action_pin_u2')));
    await tester.pumpAndSettle();

    expect(tester.getSize(headerBackground).height, initialHeaderHeight);
    expect(
      tester.widget<ColoredBox>(conversationBackground).color,
      const Color(0x33A699FF),
    );

    final pinnedSwipeTile = find.byKey(
      const ValueKey<String>('message_swipe_tile_u2'),
    );
    await tester.drag(pinnedSwipeTile, const Offset(-140, 0));
    await tester.pumpAndSettle();
    expect(find.text('取消置顶'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey<String>('message_action_pin_u2')));
    await tester.pumpAndSettle();

    expect(tester.getSize(headerBackground).height, initialHeaderHeight);
    expect(
      tester.widget<ColoredBox>(conversationBackground).color,
      Colors.transparent,
    );
  });
}
