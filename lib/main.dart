import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'repositories/app_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final cachedUserId = prefs.getString('current_user_id') ?? '';
  AppRepository.instance.setCurrentUser(cachedUserId);
  if (cachedUserId.isNotEmpty) {
    final isProfileCompleted = prefs.getBool('profile_completed_$cachedUserId');
    if (isProfileCompleted != null) {
      AppRepository.instance.setUserProfileCompleted(
        cachedUserId,
        isProfileCompleted,
      );
    }
  }

  runApp(
    const ProviderScope(
      child: RayApp(),
    ),
  );
}

class RayApp extends ConsumerWidget {
  const RayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'photomate',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
