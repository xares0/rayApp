import 'package:flutter/widgets.dart';

import '../../auth/profile_setup_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileSetupScreen(mode: ProfileFormMode.edit);
  }
}
