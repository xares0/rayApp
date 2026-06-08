import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/widgets/interaction_utils.dart';

void main() {
  Future<void> pumpDialogHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () => showBlockConfirmDialog(context),
                    child: const Text('open-block'),
                  ),
                  TextButton(
                    onPressed: () => showFigmaDeletePostDialog(context),
                    child: const Text('open-delete'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('拉黑确认弹窗显示正确文案', (tester) async {
    await pumpDialogHost(tester);

    await tester.tap(find.text('open-block'));
    await tester.pumpAndSettle();

    expect(find.text('温馨提示'), findsOneWidget);
    expect(find.text('确定要拉黑对方？'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确认'), findsOneWidget);
  });

  testWidgets('删除投稿弹窗显示正确文案', (tester) async {
    await pumpDialogHost(tester);

    await tester.tap(find.text('open-delete'));
    await tester.pumpAndSettle();

    expect(find.text('删除投稿'), findsOneWidget);
    expect(find.text('投稿删除后不可恢复，\n是否删除投稿？'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确认'), findsOneWidget);
  });
}
