import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/profile/user_posts_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
  });

  String formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}个小时前';
    return '${diff.inDays}天前';
  }

  Future<void> pumpUserPostsScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: UserPostsScreen(userId: 'u1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('最近动态列表页展示标题和动态卡片列表', (tester) async {
    await pumpUserPostsScreen(tester);
    final firstPost = AppRepository.instance.getPostsForUser('u1').first;
    final user = AppRepository.instance.getUser('u1');
    final timeLabel = formatRelativeTime(firstPost.createdAt);

    expect(find.text('近期投稿'), findsOneWidget);
    expect(find.byKey(const ValueKey('userPosts.list')), findsOneWidget);
    expect(find.text(user.name), findsWidgets);
    expect(find.text(timeLabel), findsWidgets);
    expect(find.text(firstPost.content), findsWidgets);
  });
}
