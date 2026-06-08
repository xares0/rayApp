import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/agreement_screen.dart';
import '../../screens/auth/profile_setup_screen.dart';
import '../../screens/main/main_skeleton.dart';
import '../../screens/style/style_screen.dart';
import '../../screens/discover/discover_screen.dart';
import '../../screens/profile/profile_screen.dart';

// Keeps other secondary screens
import '../../screens/moment/moment_detail_screen.dart';
import '../../screens/moment/add_moment_screen.dart';
import '../../screens/message/message_list_screen.dart';
import '../../screens/message/chat_room_screen.dart';
import '../../screens/message/system_notifications_screen.dart';
import '../../screens/profile/subscreens/edit_profile_screen.dart';
import '../../screens/profile/user_profile_screen.dart';
import '../../screens/profile/user_posts_screen.dart';
import '../../screens/profile/subscreens/profile_moments_screen.dart';
import '../../screens/profile/subscreens/profile_following_screen.dart';
import '../../screens/profile/subscreens/profile_followers_screen.dart';
import '../../screens/profile/subscreens/profile_album_screen.dart';
import '../../screens/profile/subscreens/settings_screen.dart';
import '../../screens/profile/subscreens/about_us_screen.dart';
import '../../screens/profile/subscreens/real_name_verification_screen.dart';
import '../../screens/profile/subscreens/blacklist_screen.dart';
import '../../screens/profile/subscreens/my_post_detail_screen.dart';
import '../../screens/profile/subscreens/visitors_screen.dart';
import '../../screens/profile/subscreens/my_pinned_screen.dart';
import '../../screens/profile/subscreens/friends_screen.dart';
import '../../screens/profile/subscreens/feedback_screen.dart';
import '../../screens/profile/subscreens/report_screen.dart';
import '../../screens/task/task_center_screen.dart';
import '../../screens/call/call_records_screen.dart';
import '../../screens/call/voice_call_screen.dart';
import '../../screens/call/video_call_screen.dart';

part 'app_router.g.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

@visibleForTesting
String appInitialLocation(User? currentUser) {
  if (currentUser == null) return '/login';
  return currentUser.isProfileCompleted ? '/style' : '/profile_setup';
}

@visibleForTesting
String? resolveAppAuthRedirect(User? currentUser, String location) {
  final isLoginRoute = location == '/login';
  final isAgreementRoute = location.startsWith('/agreement/');
  final isProfileSetupRoute = location == '/profile_setup';
  final isPublicRoute = isLoginRoute || isAgreementRoute;

  if (currentUser == null) {
    if (isPublicRoute) return null;
    return '/login';
  }

  if (isAgreementRoute) return null;

  if (!currentUser.isProfileCompleted) {
    if (isProfileSetupRoute) return null;
    return '/profile_setup';
  }

  if (isLoginRoute || isProfileSetupRoute) {
    return '/style';
  }

  return null;
}

@riverpod
GoRouter appRouter(Ref ref) {
  final currentUser = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: appInitialLocation(currentUser),
    redirect: (context, state) =>
        resolveAppAuthRedirect(currentUser, state.uri.path),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile_setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/agreement/:type',
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'user';
          return AgreementScreen(type: type);
        },
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
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
            builder: (context, state) => const MessageListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Secondary Routes
      GoRoute(
        path: '/edit_profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile_moments',
        builder: (context, state) => const ProfileMomentsScreen(),
      ),
      GoRoute(
        path: '/my_pinned',
        builder: (context, state) => const MyPinnedScreen(),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/settings/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/task_center',
        builder: (context, state) => const TaskCenterScreen(),
      ),
      GoRoute(
        path: '/call_records',
        builder: (context, state) => const CallRecordsScreen(),
      ),
      GoRoute(
        path: '/call/voice/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final stateStr = state.uri.queryParameters['callState'] ?? 'outgoing';
          final callState = VoiceCallState.values.firstWhere(
            (e) => e.name == stateStr,
            orElse: () => VoiceCallState.outgoing,
          );
          return VoiceCallScreen(otherUserId: userId, initialState: callState);
        },
      ),
      GoRoute(
        path: '/call/video/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final stateStr = state.uri.queryParameters['state'] ?? 'outgoingA';
          final callState = VideoCallState.values.firstWhere(
            (e) => e.name == stateStr,
            orElse: () => VideoCallState.outgoingA,
          );
          return VideoCallScreen(otherUserId: userId, initialState: callState);
        },
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) {
          final typeStr = state.uri.queryParameters['targetType'] ?? 'user';
          final targetId = state.uri.queryParameters['targetId'] ?? '';
          final targetType = ReportTargetType.values.firstWhere(
            (e) => e.name == typeStr,
            orElse: () => ReportTargetType.user,
          );
          return ReportScreen(targetType: targetType, targetId: targetId);
        },
      ),
      GoRoute(
        path: '/profile_following',
        builder: (context, state) => const ProfileFollowingScreen(),
      ),
      GoRoute(
        path: '/profile_followers',
        builder: (context, state) => const ProfileFollowersScreen(),
      ),
      GoRoute(
        path: '/profile_album',
        builder: (context, state) => const ProfileAlbumScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/real_name',
        builder: (context, state) => const RealNameVerificationScreen(),
      ),
      GoRoute(
        path: '/settings/blacklist',
        builder: (context, state) => const BlacklistScreen(),
      ),
      GoRoute(
        path: '/visitors',
        builder: (context, state) => const VisitorsScreen(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddMomentScreen(),
      ),
      GoRoute(
        path: '/recommend',
        redirect: (context, state) => '/style',
      ),
      GoRoute(
        path: '/system_notifications',
        builder: (context, state) => const SystemNotificationsScreen(),
      ),
      GoRoute(
        path: '/moment_detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MomentDetailScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/my_post_detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MyPostDetailScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final greeting = state.uri.queryParameters['greeting'];
          return ChatRoomScreen(otherUserId: userId, initialGreeting: greeting);
        },
      ),
      GoRoute(
        path: '/user_profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/user_posts/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserPostsScreen(userId: userId);
        },
      ),
    ],
  );
}
