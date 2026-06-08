import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../repositories/app_repository.dart';

part 'auth_provider.g.dart';

const _currentUserIdPrefsKey = 'current_user_id';

String _profileCompletedPrefsKey(String userId) => 'profile_completed_$userId';

@riverpod
class Auth extends _$Auth {
  @override
  User? build() {
    return AppRepository.instance.getCurrentUser();
  }

  Future<void> login(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    AppRepository.instance.setCurrentUser(userId);

    final isProfileCompleted = prefs.getBool(_profileCompletedPrefsKey(userId));
    if (isProfileCompleted != null) {
      AppRepository.instance
          .setUserProfileCompleted(userId, isProfileCompleted);
    }

    state = AppRepository.instance.getCurrentUser();
    await prefs.setString(_currentUserIdPrefsKey, userId);
  }

  Future<void> setProfileCompleted(
      String userId, bool isProfileCompleted) async {
    AppRepository.instance.setUserProfileCompleted(userId, isProfileCompleted);
    if (AppRepository.instance.currentUserId == userId) {
      state = AppRepository.instance.getCurrentUser();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _profileCompletedPrefsKey(userId),
      isProfileCompleted,
    );
  }

  Future<void> logout() async {
    AppRepository.instance.setCurrentUser('');
    state = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdPrefsKey);
  }

  Future<void> deleteAccount() async {
    final userId = AppRepository.instance.currentUserId;
    // 模拟服务端注销账号，清理本地状态
    AppRepository.instance.setCurrentUser('');
    state = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserIdPrefsKey);
    if (userId.isNotEmpty) {
      await prefs.remove(_profileCompletedPrefsKey(userId));
    }
  }
}
