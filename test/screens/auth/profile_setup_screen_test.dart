import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/auth/profile_setup_screen.dart';

void main() {
  setUp(() {
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  Future<void> pumpProfileSetupScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileSetupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('资料完善页会展示 Figma 关键元素', (tester) async {
    await pumpProfileSetupScreen(tester);

    expect(find.text('完善个人资料'), findsOneWidget);
    expect(find.text('昵称'), findsOneWidget);
    expect(find.text('年龄'), findsOneWidget);
    expect(find.text('性别'), findsOneWidget);
    expect(find.text('性别设置后不可更改'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
    expect(find.text('男'), findsOneWidget);
    expect(find.text('女'), findsOneWidget);
  });

  testWidgets('点击年龄字段会弹出日期选择层', (tester) async {
    await pumpProfileSetupScreen(tester);

    expect(find.text('取消'), findsNothing);
    expect(find.text('确认'), findsNothing);

    await tester.tap(find.byKey(const Key('profileSetup.ageField')));
    await tester.pumpAndSettle();

    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确认'), findsOneWidget);
    expect(find.textContaining('月'), findsWidgets);
    expect(find.textContaining('日'), findsWidgets);
  });

  testWidgets('性别图标尺寸与 Figma 版式一致', (tester) async {
    await pumpProfileSetupScreen(tester);

    final selectedMaleBox = tester.widget<SizedBox>(
      find.byKey(const ValueKey('profileSetup.genderIcon.男')),
    );
    final unselectedFemaleBox = tester.widget<SizedBox>(
      find.byKey(const ValueKey('profileSetup.genderIcon.女')),
    );

    expect(selectedMaleBox.width, 72);
    expect(selectedMaleBox.height, 95);
    expect(unselectedFemaleBox.width, 56);
    expect(unselectedFemaleBox.height, 77);
  });

  testWidgets('切换性别后会展示新的图标资源尺寸', (tester) async {
    await pumpProfileSetupScreen(tester);

    await tester.tap(find.byKey(const Key('profileSetup.genderFemale')));
    await tester.pumpAndSettle();

    final selectedFemaleBox = tester.widget<SizedBox>(
      find.byKey(const ValueKey('profileSetup.genderIcon.女')),
    );
    final unselectedMaleBox = tester.widget<SizedBox>(
      find.byKey(const ValueKey('profileSetup.genderIcon.男')),
    );

    expect(selectedFemaleBox.width, 72);
    expect(selectedFemaleBox.height, 95);
    expect(unselectedMaleBox.width, 56);
    expect(unselectedMaleBox.height, 77);
  });

  testWidgets('日期选择层不会被整块白色遮罩盖住', (tester) async {
    await pumpProfileSetupScreen(tester);

    await tester.tap(find.byKey(const Key('profileSetup.ageField')));
    await tester.pumpAndSettle();

    final blockingMask = find.byWidgetPredicate((widget) {
      if (widget is! DecoratedBox) return false;
      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) return false;
      final gradient = decoration.gradient;
      if (gradient is! LinearGradient) return false;
      return gradient.colors.length == 6 &&
          gradient.colors.first == Colors.white &&
          gradient.colors.last == Colors.white &&
          gradient.stops?.length == 6;
    });

    expect(blockingMask, findsNothing);
  });

  testWidgets('唤起键盘时完成按钮不会跟随上移', (tester) async {
    addTearDown(tester.view.resetViewInsets);

    await pumpProfileSetupScreen(tester);

    final buttonFinder = find.byKey(const Key('profileSetup.completeButton'));
    final before = tester.getTopLeft(buttonFinder);

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pump();

    final after = tester.getTopLeft(buttonFinder);
    expect(after, before);
  });

  testWidgets('点击背景会收起键盘', (tester) async {
    await pumpProfileSetupScreen(tester);

    await tester.tap(find.byType(TextField));
    await tester.pump();

    final editableState = tester.state<EditableTextState>(
      find.byType(EditableText),
    );
    expect(editableState.widget.focusNode.hasFocus, isTrue);

    await tester.tap(find.text('完善个人资料'));
    await tester.pump();

    expect(editableState.widget.focusNode.hasFocus, isFalse);
  });
}
