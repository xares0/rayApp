import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_app/models/message.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/message/chat_room_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    AppRepository.instance.setCurrentUser('u1');
  });

  testWidgets('消息详情默认结构对齐 vv2', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChatRoomScreen(otherUserId: 'u4'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('棠也'), findsOneWidget);
    expect(find.text('刚刚在线'), findsOneWidget);
    expect(find.text('摄影作品'), findsOneWidget);
    expect(find.text('你好啊'), findsOneWidget);
    expect(find.text('发送一条炫技中心把~'), findsOneWidget);
    expect(find.text('鼓掌'), findsOneWidget);
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('chat.backIconFrame'))),
      const Offset(14, 61),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('chat.backIconFrame'))),
      const Size(20, 20),
    );
    final titleTopLeft =
        tester.getTopLeft(find.byKey(const ValueKey<String>('chat.title')));
    expect(titleTopLeft.dx, closeTo(172, 0.5));
    expect(titleTopLeft.dy, 53);
    final subtitleTopLeft =
        tester.getTopLeft(find.byKey(const ValueKey<String>('chat.subtitle')));
    expect(subtitleTopLeft.dx, closeTo(168, 0.5));
    expect(subtitleTopLeft.dy, 75);
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('chat.moreNavIconFrame'))),
      const Offset(341, 59),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('chat.moreNavIconFrame'))),
      const Size(20, 20),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('chat.galleryCard'))),
      const Offset(14, 103),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('chat.galleryCard'))),
      const Size(347, 158),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('chat.galleryImage.0'))),
      const Offset(28, 143),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('chat.galleryImage.0'))),
      const Size(102, 104),
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('chat.messageAvatar.m4')),
      ),
      const Offset(14, 275),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey<String>('chat.messageAvatar.m4')),
      ),
      const Size(50, 50),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('chat.textBubble.m4'))),
      const Offset(76, 290),
    );
    final textBubbleSize = tester
        .getSize(find.byKey(const ValueKey<String>('chat.textBubble.m4')));
    expect(textBubbleSize.width, closeTo(70.75, 0.01));
    expect(textBubbleSize.height, 38);
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('chat.imageBubble.m4_image')),
      ),
      const Offset(200, 347),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey<String>('chat.imageBubble.m4_image')),
      ),
      const Size(99, 99),
    );
    expect(
      tester.getTopLeft(
        find.byKey(const ValueKey<String>('chat.messageAvatar.m4_image')),
      ),
      const Offset(311, 332),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('chat.inputBar'))),
      const Offset(0, 694),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('chat.inputBar'))),
      const Size(375, 84),
    );
    expect(
      tester
          .getTopLeft(find.byKey(const ValueKey<String>('chat.textInputBox'))),
      const Offset(14, 704),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('chat.textInputBox'))),
      const Size(292, 40),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('chat.moreIcon'))),
      const Offset(179.25, 748),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('chat.moreIcon'))),
      const Size(29, 29),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey<String>('chat.giftButton'))),
      const Offset(315, 608),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey<String>('chat.giftButton'))),
      const Size(46, 47),
    );
  });

  testWidgets('切到语音模式后只显示按住说话按钮', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChatRoomScreen(otherUserId: 'u4'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('按住说话，手指上滑可取消'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('chat.voiceModeButton')));
    await tester.pumpAndSettle();

    expect(find.text('按住说话，手指上滑可取消'), findsNothing);
    expect(find.text('按住说话'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('点击加号会展示 vv2 通话弹层', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.view.resetPadding);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChatRoomScreen(otherUserId: 'u4'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('chat.moreButton')));
    await tester.pumpAndSettle();

    expect(find.text('视频通话'), findsOneWidget);
    expect(find.text('语音通话'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('chat.callActionSheet')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('chat.callAction.video')),
        findsOneWidget);
    expect(find.byKey(const ValueKey<String>('chat.callAction.voice')),
        findsOneWidget);
    final bottomPadding =
        tester.view.padding.bottom / tester.view.devicePixelRatio;
    final sheetTop = 812 - 181 - bottomPadding;
    final safeAreaTop = 812 - bottomPadding;

    expect(
      tester
          .getTopLeft(
              find.byKey(const ValueKey<String>('chat.callActionSheet')))
          .dy,
      closeTo(sheetTop, 0.1),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('chat.callActionSheet'))),
      Size(375, 181 + bottomPadding),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('chat.callAction.video'))),
      Offset(0, sheetTop),
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('chat.callAction.video'))),
      const Size(375, 60),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('chat.callAction.icon.video'))),
      const Size(24, 24),
    );
    expect(
      find.text('视频通话'),
      findsOneWidget,
    );
    expect(
      find.text('语音通话'),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('chat.callAction.divider.video'))),
      Offset(0, sheetTop + 60),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('chat.callAction.voice'))),
      Offset(0, sheetTop + 61),
    );
    expect(
      tester.getSize(
          find.byKey(const ValueKey<String>('chat.callAction.icon.voice'))),
      const Size(24, 24),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('chat.callAction.divider.voice'))),
      Offset(0, sheetTop + 121),
    );
    expect(
      tester.getTopLeft(
          find.byKey(const ValueKey<String>('chat.callAction.cancel'))),
      Offset(0, sheetTop + 122),
    );
    final cancelRect = tester.getRect(
        find.byKey(const ValueKey<String>('chat.callAction.cancelText')));
    expect(cancelRect.center.dx, closeTo(187.5, 0.5));
    expect(cancelRect.width, greaterThan(36));
    expect(
      cancelRect.bottom,
      lessThanOrEqualTo(safeAreaTop),
    );
  });

  testWidgets('点击送礼发送鼓掌图片消息', (tester) async {
    SharedPreferences.setMockInitialValues({});
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');

    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChatRoomScreen(otherUserId: 'u4'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('chat.giftButton')));
    await tester.pump(const Duration(milliseconds: 400));

    final sentGift = AppRepository.instance.messages.lastWhere(
      (message) =>
          message.senderId == 'u1' &&
          message.receiverId == 'u4' &&
          message.content == '🎁 送出一个礼物',
    );
    expect(sentGift.type, MessageType.image);
    expect(sentGift.mediaPath, 'assets/images/checkin/camera.png');
    expect(sentGift.thumbnailPath, 'assets/images/checkin/camera.png');
    expect(
      find.byKey(ValueKey<String>('chat.imageBubble.${sentGift.id}')),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 1));
  });
}
