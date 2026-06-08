import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/smart_image.dart';

enum ProfileFormMode { setup, edit }

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({
    super.key,
    this.mode = ProfileFormMode.setup,
  });

  final ProfileFormMode mode;

  bool get isEditMode => mode == ProfileFormMode.edit;

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  static const _defaultAvatarAsset = 'assets/images/portraits/portrait_1.jpg';
  static const _cameraBadgeAsset =
      'assets/images/profile_setup/avatar_camera_badge.png';
  static const _portfolioImageLimit = 6;
  static const _maleSelectedAsset =
      'assets/images/profile_setup/gender_male_selected.svg';
  static const _maleUnselectedAsset =
      'assets/images/profile_setup/gender_male_unselected.png';
  static const _femaleSelectedAsset =
      'assets/images/profile_setup/gender_female_selected.png';
  static const _femaleUnselectedAsset =
      'assets/images/profile_setup/gender_female_unselected.svg';

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _avatarPath;
  String _avatarAssetPath = _defaultAvatarAsset;
  String _gender = 'male';
  late DateTime _birthday;
  List<String> _portfolioImages = [];

  @override
  void initState() {
    super.initState();
    final repo = AppRepository.instance;
    final user = repo.getUser(repo.currentUserId);
    final now = DateTime.now();
    _birthday = DateTime(now.year - 20, now.month, now.day);

    _nicknameController.text = user.name.isEmpty ? '许愿望的小南瓜' : user.name;
    _bioController.text = user.bio;
    _gender = user.gender;
    _portfolioImages = List.from(user.portfolioImages);

    final birthday = user.birthday == null || user.birthday!.isEmpty
        ? null
        : DateTime.tryParse(user.birthday!);
    if (birthday != null) {
      _birthday = _clampBirthday(birthday);
    }

    if (user.avatarUrl.startsWith('assets/')) {
      _avatarAssetPath = user.avatarUrl;
    } else if (user.avatarUrl.isNotEmpty) {
      _avatarPath = user.avatarUrl;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  DateTime get _maxDate {
    final now = DateTime.now();
    return DateTime(now.year - 18, now.month, now.day);
  }

  DateTime get _minDate {
    final now = DateTime.now();
    return DateTime(now.year - 80, now.month, now.day);
  }

  DateTime _clampBirthday(DateTime value) {
    if (value.isBefore(_minDate)) return _minDate;
    if (value.isAfter(_maxDate)) return _maxDate;
    return value;
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  ImageProvider<Object> get _avatarProvider {
    if (_avatarPath != null) {
      return FileImage(File(_avatarPath!));
    }
    return AssetImage(_avatarAssetPath);
  }

  Future<void> _pickAvatar() async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (xFile == null) return;
    setState(() {
      _avatarPath = xFile.path;
    });
  }

  Future<void> _pickPortfolioImage() async {
    if (_portfolioImages.length >= _portfolioImageLimit) {
      showAppToast(context, '作品集最多上传6张图片');
      return;
    }

    final xFile = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (xFile == null) return;
    setState(() {
      _portfolioImages.add(xFile.path);
    });
  }

  Future<void> _showDatePicker() async {
    final result = await showCupertinoModalPopup<DateTime>(
      context: context,
      barrierColor: const Color(0x8004010A),
      builder: (ctx) => _ProfileBirthdayPickerSheet(
        initialDate: _birthday,
        minDate: _minDate,
        maxDate: _maxDate,
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _birthday = result;
    });
  }

  Future<void> _handleComplete() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      showAppToast(context, '昵称不可为空');
      return;
    }

    final repo = AppRepository.instance;
    final userId = repo.currentUserId;
    final userIndex = repo.users.indexWhere((user) => user.id == userId);
    if (userIndex != -1) {
      final user = repo.users[userIndex];
      repo.users[userIndex] = user.copyWith(
        name: nickname,
        bio: _bioController.text.trim(),
        avatarUrl: _avatarPath ?? _avatarAssetPath,
        gender: _gender,
        birthday: _formatDate(_birthday),
        portfolioImages: _portfolioImages,
      );
    }

    if (widget.isEditMode) {
      await ref.read(authProvider.notifier).login(userId);
      ref.invalidate(homeFeedProvider);
      ref.invalidate(momentsFeedProvider);
      ref.invalidate(profilePostsProvider(userId));
      ref.invalidate(profileUserProvider(userId));
      if (!mounted) return;
      showAppToast(context, '保存成功');
      context.pop();
      return;
    }

    await ref.read(authProvider.notifier).setProfileCompleted(userId, true);
    if (!mounted) return;
    context.go('/style');
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditMode) {
      return _buildSetupLayout();
    }
    return _buildEditLayout();
  }

  // --- SETUP LAYOUT (Standard) ---
  Widget _buildSetupLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            const Positioned(
              top: -24,
              right: -12,
              child: IgnorePointer(child: _ProfileSetupTopGlow()),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildHeader('完善个人资料'),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 18, 14, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSetupAvatarSection(),
                          const SizedBox(height: 26),
                          _buildSectionLabel('昵称'),
                          const SizedBox(height: 12),
                          _buildSetupNicknameField(),
                          const SizedBox(height: 18),
                          _buildSectionLabel('年龄'),
                          const SizedBox(height: 12),
                          _buildSetupAgeField(),
                          const SizedBox(height: 18),
                          _buildSectionLabel('性别'),
                          const SizedBox(height: 12),
                          _buildSetupGenderField(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                    child: _buildCompleteButton('完成'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- EDIT LAYOUT (Custom List) ---
  Widget _buildEditLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8B5CF6), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('编辑资料', style: TextStyle(color: Color(0xFF222222), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(child: _buildEditAvatarSection()),
                  const SizedBox(height: 32),
                  _buildListTile('昵称', _nicknameController.text, onTap: _showNicknameDialog),
                  _buildListTile('年龄', '${DateTime.now().year - _birthday.year}岁', onTap: _showDatePicker),
                  _buildListTile('性别', _gender == 'male' ? '男' : '女'),
                  const SizedBox(height: 24),
                  const Text('作品集', style: TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  _buildPortfolioGrid(),
                  const SizedBox(height: 24),
                  const Text('摄影心得：', style: TextStyle(fontSize: 15, color: Color(0xFF222222), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  _buildBioField(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildCompleteButton('保存'),
          ),
        ],
      ),
    );
  }

  // --- Shared Setup Widgets ---
  Widget _buildHeader(String title) {
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (canPop)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF333333), size: 20),
                ),
              ),
            ),
          Text(title, style: const TextStyle(color: Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSetupAvatarSection() {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Center(
        child: SizedBox(
          width: 82, height: 82,
          child: Stack(
            children: [
              ClipOval(child: Image(image: _avatarProvider, fit: BoxFit.cover, width: 82, height: 82)),
              Positioned(right: 0, bottom: 0, child: Image.asset(_cameraBadgeAsset, width: 26, height: 26)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4, height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)]),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Color(0xFF333333), fontSize: 14)),
      ],
    );
  }

  Widget _buildSetupNicknameField() {
    return _buildSetupFieldShell(
      child: TextField(
        controller: _nicknameController,
        decoration: const InputDecoration(border: InputBorder.none, hintText: '请输入昵称', hintStyle: TextStyle(color: Color(0xFFC1C1C1))),
      ),
    );
  }

  Widget _buildSetupAgeField() {
    return GestureDetector(
      key: const Key('profileSetup.ageField'),
      onTap: _showDatePicker,
      child: _buildSetupFieldShell(
        child: Row(
          children: [
            Expanded(child: Text(_formatDate(_birthday), style: const TextStyle(fontSize: 16))),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8B8B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupFieldShell({required Widget child}) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFA994FF)),
      ),
      child: child,
    );
  }

  Widget _buildSetupGenderField() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _GenderCard(
                tapKey: const Key('profileSetup.genderMale'),
                label: '男',
                selected: _gender == 'male',
                backgroundGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEFFAFC), Color(0xFFF8F6FF)],
                  stops: [0.44, 0.97],
                ),
                borderColor: const Color(0xFFA9C7FF),
                iconAsset: _gender == 'male'
                    ? _maleSelectedAsset
                    : _maleUnselectedAsset,
                iconScale: _gender == 'male' ? null : 3,
                iconSize:
                    _gender == 'male' ? const Size(72, 95) : const Size(56, 77),
                iconTop: _gender == 'male' ? -9 : 12,
                onTap: () => setState(() => _gender = 'male'),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _GenderCard(
                tapKey: const Key('profileSetup.genderFemale'),
                label: '女',
                selected: _gender == 'female',
                backgroundGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE7FF), Color(0xFFFEF4FA)],
                  stops: [0.05, 0.94],
                ),
                borderColor: const Color(0xFFF1AFF3),
                iconAsset: _gender == 'female'
                    ? _femaleSelectedAsset
                    : _femaleUnselectedAsset,
                iconScale: _gender == 'female' ? 3 : null,
                iconSize: _gender == 'female'
                    ? const Size(72, 95)
                    : const Size(56, 77),
                iconTop: _gender == 'female' ? -9 : 12,
                onTap: () => setState(() => _gender = 'female'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          '性别设置后不可更改',
          style: TextStyle(color: Color(0xFF999999), fontSize: 14),
        ),
      ],
    );
  }

  // --- Edit Page Specific Widgets ---
  Widget _buildEditAvatarSection() {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        children: [
          ClipOval(child: Image(image: _avatarProvider, width: 88, height: 88, fit: BoxFit.cover)),
          Positioned(
            right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Color(0xFF444444), shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F3F5)))),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF999999))),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF222222))),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC), size: 20),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioGrid() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        ..._portfolioImages.map((path) => _buildPortfolioItem(path)),
        if (_portfolioImages.length < _portfolioImageLimit)
          GestureDetector(
            key: const Key('profileSetup.portfolioAddButton'),
            onTap: _pickPortfolioImage,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.add, color: Color(0xFFCCCCCC), size: 32),
            ),
          ),
      ],
    );
  }

  Widget _buildPortfolioItem(String path) {
    return Stack(
      children: [
        SizedBox(width: 80, height: 80, child: SmartImage(source: path, borderRadius: BorderRadius.circular(8))),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _portfolioImages.remove(path)),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _bioController,
        maxLines: 4,
        decoration: const InputDecoration(hintText: '写下你的摄影心得...', hintStyle: TextStyle(color: Color(0xFFBBBBBB)), border: InputBorder.none),
      ),
    );
  }

  Widget _buildCompleteButton(String label) {
    return GestureDetector(
      key: const Key('profileSetup.completeButton'),
      onTap: _handleComplete,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [Color(0xFFDA99FF), Color(0xFFA575FF)]),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
      ),
    );
  }

  void _showNicknameDialog() {
    final controller = TextEditingController(text: _nicknameController.text);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('修改昵称', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(border: InputBorder.none, hintText: '请输入昵称')),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: _buildDialogButton('取消', const Color(0xFFF5F5F5), const Color(0xFF999999), () => Navigator.pop(ctx))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogButton('确定', null, Colors.white, () {
                    setState(() => _nicknameController.text = controller.text);
                    Navigator.pop(ctx);
                  }, isPrimary: true)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String label, Color? bg, Color textCol, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          gradient: isPrimary ? const LinearGradient(colors: [Color(0xFFDA99FF), Color(0xFFA575FF)]) : null,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(label, style: TextStyle(color: textCol, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    this.tapKey,
    required this.label,
    required this.selected,
    required this.backgroundGradient,
    required this.borderColor,
    required this.iconAsset,
    required this.iconScale,
    required this.iconSize,
    required this.iconTop,
    required this.onTap,
  });

  final Key? tapKey;
  final String label;
  final bool selected;
  final Gradient backgroundGradient;
  final Color borderColor;
  final String iconAsset;
  final double? iconScale;
  final Size iconSize;
  final double iconTop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: tapKey,
      onTap: onTap,
      child: Container(
        height: 101,
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? borderColor : Colors.transparent,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 20,
              top: iconTop,
              child: SizedBox(
                key: ValueKey('profileSetup.genderIcon.$label'),
                width: iconSize.width,
                height: iconSize.height,
                child: iconAsset.endsWith('.svg')
                    ? SvgPicture.asset(
                        iconAsset,
                        fit: BoxFit.contain,
                        alignment: Alignment.topLeft,
                      )
                    : Image.asset(
                        iconAsset,
                        scale: iconScale,
                        fit: BoxFit.contain,
                        alignment: Alignment.topLeft,
                      ),
              ),
            ),
            Positioned(
              right: 29,
              top: 35,
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF333333)
                      : const Color(0xFF666666),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSetupTopGlow extends StatelessWidget {
  const _ProfileSetupTopGlow();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 209, height: 132,
      child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.85, -0.25), radius: 1.15, colors: [Color(0xFFEBD9FF), Color(0x00FFFFFF)]))),
    );
  }
}

// --- ORIGINAL BIRTHDAY PICKER SHEET ---
class _ProfileBirthdayPickerSheet extends StatefulWidget {
  const _ProfileBirthdayPickerSheet({
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
  });

  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;

  @override
  State<_ProfileBirthdayPickerSheet> createState() =>
      _ProfileBirthdayPickerSheetState();
}

class _ProfileBirthdayPickerSheetState
    extends State<_ProfileBirthdayPickerSheet> {
  static const _pickerTextColor = Color(0xFF1D2129);
  static const _sheetActionColor = Color(0xFF8B5CF6);
  static const _lineColor = Color(0xFFE5E6EB);
  static const _itemExtent = 44.0;

  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  List<int> get _years => [
        for (int year = widget.minDate.year;
            year <= widget.maxDate.year;
            year++)
          year,
      ];

  List<int> _monthsForYear(int year) {
    final start = year == widget.minDate.year ? widget.minDate.month : 1;
    final end = year == widget.maxDate.year ? widget.maxDate.month : 12;
    return [for (int month = start; month <= end; month++) month];
  }

  List<int> _daysForMonth(int year, int month) {
    final start = year == widget.minDate.year && month == widget.minDate.month
        ? widget.minDate.day
        : 1;
    final end = year == widget.maxDate.year && month == widget.maxDate.month
        ? widget.maxDate.day
        : DateUtils.getDaysInMonth(year, month);
    return [for (int day = start; day <= end; day++) day];
  }

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedYear),
    );
    _monthController = FixedExtentScrollController(
      initialItem: _monthsForYear(_selectedYear).indexOf(_selectedMonth),
    );
    _dayController = FixedExtentScrollController(
      initialItem:
          _daysForMonth(_selectedYear, _selectedMonth).indexOf(_selectedDay),
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    final monthIndex = _monthsForYear(_selectedYear).indexOf(_selectedMonth);
    final dayIndex =
        _daysForMonth(_selectedYear, _selectedMonth).indexOf(_selectedDay);
    if (_monthController.hasClients && monthIndex >= 0) {
      _monthController.jumpToItem(monthIndex);
    }
    if (_dayController.hasClients && dayIndex >= 0) {
      _dayController.jumpToItem(dayIndex);
    }
  }

  void _updateYear(int year) {
    final months = _monthsForYear(year);
    final month =
        months.contains(_selectedMonth) ? _selectedMonth : months.last;
    final days = _daysForMonth(year, month);
    final day = days.contains(_selectedDay) ? _selectedDay : days.last;
    setState(() {
      _selectedYear = year;
      _selectedMonth = month;
      _selectedDay = day;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncControllers());
  }

  void _updateMonth(int month) {
    final days = _daysForMonth(_selectedYear, month);
    final day = days.contains(_selectedDay) ? _selectedDay : days.last;
    setState(() {
      _selectedMonth = month;
      _selectedDay = day;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncControllers());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 53,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _SheetActionText(
                        label: '取消',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      _SheetActionText(
                        label: '确认',
                        onTap: () {
                          Navigator.of(context).pop(
                            DateTime(
                                _selectedYear, _selectedMonth, _selectedDay),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _PickerColumn(
                            controller: _yearController,
                            values: _years,
                            itemExtent: _itemExtent,
                            selectedValue: _selectedYear,
                            labelBuilder: (value) => '$value',
                            onSelectedItemChanged: (index) =>
                                _updateYear(_years[index]),
                          ),
                        ),
                        Expanded(
                          child: _PickerColumn(
                            controller: _monthController,
                            values: _monthsForYear(_selectedYear),
                            itemExtent: _itemExtent,
                            selectedValue: _selectedMonth,
                            labelBuilder: (value) => '$value月',
                            onSelectedItemChanged: (index) => _updateMonth(
                              _monthsForYear(_selectedYear)[index],
                            ),
                          ),
                        ),
                        Expanded(
                          child: _PickerColumn(
                            controller: _dayController,
                            values:
                                _daysForMonth(_selectedYear, _selectedMonth),
                            itemExtent: _itemExtent,
                            selectedValue: _selectedDay,
                            labelBuilder: (value) => '$value日',
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedDay = _daysForMonth(
                                  _selectedYear,
                                  _selectedMonth,
                                )[index];
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 88,
                      height: _itemExtent,
                      child: IgnorePointer(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: _lineColor),
                              bottom: BorderSide(color: _lineColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: bottomInset + 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  const _PickerColumn({
    required this.controller,
    required this.values,
    required this.itemExtent,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onSelectedItemChanged,
  });

  final FixedExtentScrollController controller;
  final List<int> values;
  final double itemExtent;
  final int selectedValue;
  final String Function(int value) labelBuilder;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: itemExtent,
      diameterRatio: 20,
      squeeze: 1.15,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: onSelectedItemChanged,
      childCount: values.length,
      itemBuilder: (context, index) {
        final value = values[index];
        final selected = value == selectedValue;
        return Center(
          child: Text(
            labelBuilder(value),
            style: TextStyle(
              color: _ProfileBirthdayPickerSheetState._pickerTextColor
                  .withValues(alpha: selected ? 1 : 0.22),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }
}

class _SheetActionText extends StatelessWidget {
  const _SheetActionText({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: _ProfileBirthdayPickerSheetState._sheetActionColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
