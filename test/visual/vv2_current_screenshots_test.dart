import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ray_app/repositories/app_repository.dart';
import 'package:ray_app/screens/checkin/checkin_provider.dart';
import 'package:ray_app/screens/discover/discover_screen.dart';
import 'package:ray_app/screens/main/main_skeleton.dart';
import 'package:ray_app/screens/message/chat_room_screen.dart';
import 'package:ray_app/screens/message/system_notifications_screen.dart';
import 'package:ray_app/screens/call/call_records_screen.dart';
import 'package:ray_app/screens/profile/profile_screen.dart';
import 'package:ray_app/screens/profile/subscreens/feedback_screen.dart';
import 'package:ray_app/screens/profile/subscreens/my_pinned_screen.dart';
import 'package:ray_app/screens/profile/subscreens/visitors_screen.dart';
import 'package:ray_app/screens/style/style_screen.dart';
import 'package:ray_app/screens/task/task_center_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _viewportSize = Size(375, 812);
const _outputDir = '.xreq/verify/current';

void main() {
  final shouldCapture = Platform.environment['CAPTURE_VV2'] == '1';
  final screenFilter = Platform.environment['CAPTURE_VV2_SCREEN'];

  setUpAll(() async {
    _installPluginMocks();
    await _loadScreenshotFonts();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await markCheckinPopupShownToday();
    AppRepository.instance.resetMockData();
    AppRepository.instance.setCurrentUser('u1');
  });

  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '02_dynamic',
    childBuilder: () => _shellApp('/discover'),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '03_waterfall',
    childBuilder: () => _shellApp('/style'),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '04_notifications',
    childBuilder: () => const ProviderScope(
      child: _VisualMaterialApp(home: SystemNotificationsScreen()),
    ),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '06_chat_detail',
    childBuilder: () => const ProviderScope(
      child: _VisualMaterialApp(home: ChatRoomScreen(otherUserId: 'u4')),
    ),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '09_profile',
    childBuilder: () => _shellApp('/profile'),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '10_visitors',
    childBuilder: () => const ProviderScope(
      child: _VisualMaterialApp(home: VisitorsScreen()),
    ),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '11_my_pinned',
    childBuilder: () => const ProviderScope(
      child: _VisualMaterialApp(home: MyPinnedScreen()),
    ),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '12_feedback_empty',
    childBuilder: () => const _VisualMaterialApp(home: FeedbackScreen()),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '15_task_center',
    childBuilder: () => const ProviderScope(
      child: _VisualMaterialApp(home: TaskCenterScreen()),
    ),
  );
  _captureTest(
    shouldCapture: shouldCapture,
    screenFilter: screenFilter,
    name: '18_call_records',
    childBuilder: () => const ProviderScope(
      child: _VisualMaterialApp(home: CallRecordsScreen()),
    ),
  );
}

class _VisualMaterialApp extends StatelessWidget {
  const _VisualMaterialApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PingFang SC',
      ),
      home: home,
    );
  }
}

Widget _shellApp(String initialLocation) {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainSkeleton(child: child),
        routes: [
          GoRoute(
            path: '/style',
            builder: (context, state) => const StyleScreen(),
          ),
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const SizedBox.shrink(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'PingFang SC',
      ),
      routerConfig: router,
    ),
  );
}

void _installPluginMocks() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  Future<Object?> noop(MethodCall _) async => null;

  messenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (call) async {
      if (call.method == 'create') {
        final arguments = call.arguments;
        final playerId = arguments is Map ? arguments['playerId'] : null;
        if (playerId is String) {
          messenger.setMockMethodCallHandler(
            MethodChannel('xyz.luan/audioplayers/events/$playerId'),
            noop,
          );
        }
      }
      return null;
    },
  );

  for (final channelName in <String>[
    'com.llfbandit.record/messages',
    'xyz.luan/audioplayers.global',
    'xyz.luan/audioplayers.global/events',
  ]) {
    messenger.setMockMethodCallHandler(
      MethodChannel(channelName),
      noop,
    );
  }
}

Future<void> _loadScreenshotFonts() async {
  final fontFile = File(
    '/System/Library/AssetsV2/com_apple_MobileAsset_Font8/86ba2c91f017a3749571a82f2c6d890ac7ffb2fb.asset/AssetData/PingFang.ttc',
  );
  if (!fontFile.existsSync()) return;
  final bytes = await fontFile.readAsBytes();
  final byteData = ByteData.view(bytes.buffer);
  await (FontLoader('PingFang SC')..addFont(Future.value(byteData))).load();
  await (FontLoader('Inter')..addFont(Future.value(byteData))).load();

  final materialIcons = File(
    '/Users/xy/fvm/versions/3.35.4/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (materialIcons.existsSync()) {
    final iconBytes = await materialIcons.readAsBytes();
    final iconData = ByteData.view(iconBytes.buffer);
    await (FontLoader('MaterialIcons')..addFont(Future.value(iconData))).load();
  }
}

void _captureTest({
  required bool shouldCapture,
  required String? screenFilter,
  required String name,
  required Widget Function() childBuilder,
}) {
  testWidgets(
    'capture current vv2 screenshot $name',
    skip: !shouldCapture || (screenFilter != null && screenFilter != name),
    (tester) async {
      await _setFigmaViewport(tester);
      await _captureScreen(tester, name: name, child: childBuilder());
    },
  );
}

Future<void> _setFigmaViewport(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _viewportSize;
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetPadding);
}

Future<void> _captureScreen(
  WidgetTester tester, {
  required String name,
  required Widget child,
}) async {
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            child,
            const _FakeIosStatusBar(),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await _precacheScreenshotAssets(tester, boundaryKey.currentContext!);
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  final boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final outputDirectory = Directory(_outputDir);
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }
    await File('$_outputDir/$name.png').writeAsBytes(bytes);
  });
}

class _FakeIosStatusBar extends StatelessWidget {
  const _FakeIosStatusBar();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: SizedBox(
        width: 375,
        height: 812,
        child: Stack(
          children: [
            Positioned(
              left: 30,
              top: 14,
              width: 44,
              height: 20,
              child: Text(
                '9:41',
                style: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111111),
                  height: 20 / 14,
                ),
              ),
            ),
            Positioned(
              right: 65,
              top: 18,
              child: Icon(
                Icons.signal_cellular_alt_rounded,
                size: 15,
                color: Color(0xFF111111),
              ),
            ),
            Positioned(
              right: 43,
              top: 17,
              child: Icon(
                Icons.wifi_rounded,
                size: 16,
                color: Color(0xFF111111),
              ),
            ),
            Positioned(
              right: 16,
              top: 17,
              child: Icon(
                Icons.battery_full_rounded,
                size: 20,
                color: Color(0xFF111111),
              ),
            ),
            Positioned(
              left: 120,
              top: 798,
              width: 135,
              height: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _precacheScreenshotAssets(
  WidgetTester tester,
  BuildContext context,
) async {
  const assets = <String>[
    'assets/images/message/interaction_empty.png',
    'assets/images/profile/profile_banner.png',
    'assets/images/task_center_gift_figma.png',
    'assets/images/checkin/camera.png',
    'assets/images/avatars/male/male_03.jpg',
    'assets/images/avatars/female/female_03.jpg',
    'assets/images/avatars/female/female_04.jpg',
    'assets/images/avatars/female/female_08.jpg',
    'assets/images/avatars/female/female_09.jpg',
    'assets/icons/chat/send.png',
    'assets/icons/chat/emoji.png',
    'assets/icons/chat/image.png',
    'assets/icons/chat/video.png',
    'assets/icons/chat/voice_icon.png',
  ];

  await tester.runAsync(() async {
    for (final asset in assets) {
      await precacheImage(AssetImage(asset), context);
    }
  });
}
