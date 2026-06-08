import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/profile/subscreens/edit_profile_screen.dart';

void main() {
  const portfolioAddButtonKey = Key('profileSetup.portfolioAddButton');

  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  void setCurrentUserPortfolioImages(List<String> images) {
    final repo = AppRepository.instance;
    final userIndex = repo.users.indexWhere((user) => user.id == repo.currentUserId);
    repo.users[userIndex] = repo.users[userIndex].copyWith(
      portfolioImages: images,
    );
  }

  Future<void> pumpEditProfileScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EditProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('编辑资料页会展示当前版本的编辑表单', (tester) async {
    await pumpEditProfileScreen(tester);

    expect(find.text('编辑资料'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('昵称'), findsOneWidget);
    expect(find.text('年龄'), findsOneWidget);
    expect(find.text('性别'), findsOneWidget);
    expect(find.text('作品集'), findsOneWidget);
    expect(find.text('摄影心得：'), findsOneWidget);
    expect(find.byKey(portfolioAddButtonKey), findsOneWidget);
  });

  testWidgets('作品集未满 6 张时显示上传入口', (tester) async {
    setCurrentUserPortfolioImages([
      'assets/images/posts/old_street_1.jpg',
      'assets/images/posts/old_street_2.jpg',
      'assets/images/posts/rain_street.jpg',
      'assets/images/posts/building_facade.jpg',
      'assets/images/posts/city_night.jpg',
    ]);

    await pumpEditProfileScreen(tester);

    expect(find.byKey(portfolioAddButtonKey), findsOneWidget);
  });

  testWidgets('作品集满 6 张时隐藏上传入口，删除后重新显示', (tester) async {
    setCurrentUserPortfolioImages([
      'assets/images/posts/old_street_1.jpg',
      'assets/images/posts/old_street_2.jpg',
      'assets/images/posts/rain_street.jpg',
      'assets/images/posts/building_facade.jpg',
      'assets/images/posts/city_night.jpg',
      'assets/images/posts/desert_sunset_1.jpg',
    ]);

    await pumpEditProfileScreen(tester);

    expect(find.byKey(portfolioAddButtonKey), findsNothing);

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();

    expect(find.byKey(portfolioAddButtonKey), findsOneWidget);
  });
}
