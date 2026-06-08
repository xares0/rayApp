import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/log_utils.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/smart_image.dart';

class AddMomentScreen extends ConsumerStatefulWidget {
  const AddMomentScreen({super.key});

  @override
  ConsumerState<AddMomentScreen> createState() => _AddMomentScreenState();
}

class _AddMomentScreenState extends ConsumerState<AddMomentScreen> {
  static const int _maxMediaCount = 9;
  static const String _draftKey = 'add_moment_draft_v1';

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final List<_SelectableMedia> _selectedMedia = [];
  final List<_SelectableMedia> _localMediaLibrary = [];

  static const _videoExtensions = {
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.m4v',
    '.3gp',
    '.wmv'
  };

  Timer? _draftDebounce;
  bool _isDraftInitializing = true;
  bool _isSubmitting = false;
  String? _inlineError;

  static const List<String> _categories = ['风景', '人物', '写真'];
  String _selectedCategory = '风景';

  bool get _hasContent => _controller.text.trim().isNotEmpty;
  bool get _hasDraftContent => _hasContent || _selectedMedia.isNotEmpty;
  bool get _canPublish =>
      !_isSubmitting && _hasContent && _selectedMedia.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _restoreDraft();
  }

  @override
  void dispose() {
    _draftDebounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isDraftInitializing) return;
    setState(() {
      if (_inlineError != null && _hasContent && _selectedMedia.isNotEmpty) {
        _inlineError = null;
      }
    });
    _saveDraftDebounced();
  }

  Future<void> _restoreDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_draftKey);
    if (raw == null || raw.isEmpty) {
      _isDraftInitializing = false;
      return;
    }

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final content = (data['content'] as String?) ?? '';
      final mediaList = (data['media'] as List<dynamic>? ?? const []);
      final restored = mediaList
          .map((e) => _SelectableMedia.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _controller.text = content;
        _selectedMedia
          ..clear()
          ..addAll(restored);
        _localMediaLibrary
          ..clear()
          ..addAll(restored);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已恢复上次草稿')));
      });
    } catch (_) {
      await prefs.remove(_draftKey);
    } finally {
      _isDraftInitializing = false;
    }
  }

  void _saveDraftDebounced() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(milliseconds: 280), _saveDraft);
  }

  Future<void> _saveDraft() async {
    if (_isDraftInitializing) return;
    final prefs = await SharedPreferences.getInstance();
    if (!_hasDraftContent) {
      await prefs.remove(_draftKey);
      return;
    }

    final payload = jsonEncode({
      'content': _controller.text,
      'media': _selectedMedia.map((m) => m.toJson()).toList(),
      'savedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_draftKey, payload);
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  Future<bool> _confirmExitIfNeeded({bool showSavedToast = false}) async {
    if (_isSubmitting) return false;
    if (!_hasDraftContent) {
      return true;
    }

    final action = await showDialog<_ExitAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('退出发布'),
          content: const Text('当前内容还未发布，是否保存草稿？'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ExitAction.cancel),
              child: const Text('继续编辑'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ExitAction.discardAndExit),
              child: const Text('不保存'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ExitAction.saveAndExit),
              child: const Text('保存草稿'),
            ),
          ],
        );
      },
    );

    if (action == null || action == _ExitAction.cancel) return false;
    if (action == _ExitAction.discardAndExit) {
      await _clearDraft();
      return true;
    }

    await _saveDraft();
    if (mounted && showSavedToast) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('草稿已保存')));
    }
    return true;
  }

  Future<void> _onClosePressed() async {
    final shouldExit = await _confirmExitIfNeeded(showSavedToast: true);
    if (!mounted || !shouldExit) return;
    context.pop();
  }

  Future<void> _submitMoment() async {
    if (_isSubmitting) return;
    if (!_hasContent) {
      _showValidation('请填写文案');
      return;
    }
    if (_selectedMedia.isEmpty) {
      _showValidation('请先选择至少1张图片');
      return;
    }

    final user = ref.read(authProvider);
    if (user == null) {
      _showValidation('当前未登录，暂时无法发布');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _inlineError = null;
    });

    try {
      final messenger = ScaffoldMessenger.of(context);
      await Future<void>.delayed(const Duration(milliseconds: 400));

      // Separate images and video
      final imageMedia = _selectedMedia.where((e) => !e.isVideo).toList();
      final videoMedia = _selectedMedia.where((e) => e.isVideo).toList();
      final videoUrl = videoMedia.isNotEmpty ? videoMedia.first.value : null;

      "[gif_bug_fix] 开始发布动态, 分类: $_selectedCategory".jarLog();

      ref.read(homeFeedProvider.notifier).createPost(
            userId: user.id,
            content: _controller.text.trim(),
            images: imageMedia.map((e) => e.value).toList(),
            videoUrl: videoUrl,
            category: _selectedCategory,
          );
      await ref.read(homeFeedProvider.notifier).refresh();
      ref.invalidate(momentsFeedProvider);
      ref.invalidate(profilePostsProvider(user.id));
      await _clearDraft();

      if (!mounted) return;
      context.pop();
      messenger.showSnackBar(const SnackBar(content: Text('发布成功')));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      _showValidation('发布失败，请重试');
    }
  }

  void _showValidation(String message) {
    setState(() {
      _inlineError = message;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isSelected(_SelectableMedia media) {
    return _selectedMedia.any((item) => item.id == media.id);
  }

  void _toggleMedia(_SelectableMedia media) {
    final exists = _isSelected(media);
    if (exists) {
      setState(() {
        _selectedMedia.removeWhere((item) => item.id == media.id);
      });
      _saveDraftDebounced();
      return;
    }
    if (_selectedMedia.length >= _maxMediaCount) {
      _showValidation('最多选择$_maxMediaCount张图片');
      return;
    }

    setState(() {
      _selectedMedia.add(media);
      if (_inlineError != null && _hasContent) {
        _inlineError = null;
      }
    });
    _saveDraftDebounced();
  }

  Future<bool> _checkPhotoPermission() async {
    PermissionStatus status;
    if (Platform.isIOS) {
      status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
    } else {
      final statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.storage
      ].request();
      final photosStatus =
          statuses[Permission.photos] ?? PermissionStatus.denied;
      final videosStatus =
          statuses[Permission.videos] ?? PermissionStatus.denied;
      final storageStatus =
          statuses[Permission.storage] ?? PermissionStatus.denied;

      final hasMediaAccess = photosStatus.isGranted ||
          photosStatus.isLimited ||
          videosStatus.isGranted ||
          videosStatus.isLimited ||
          storageStatus.isGranted;
      if (hasMediaAccess) {
        return true;
      }

      final permanentlyDenied = photosStatus.isPermanentlyDenied &&
          videosStatus.isPermanentlyDenied &&
          storageStatus.isPermanentlyDenied;
      status = permanentlyDenied
          ? PermissionStatus.permanentlyDenied
          : PermissionStatus.denied;
    }

    if (status.isPermanentlyDenied) {
      if (!mounted) return false;
      final goSettings = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('需要相册权限'),
          content: const Text('请在系统设置中允许访问相册，以便选择照片发布投稿。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('去设置'),
            ),
          ],
        ),
      );
      if (goSettings == true) {
        await openAppSettings();
      }
      return false;
    }

    if (!status.isGranted && !status.isLimited) {
      _showValidation('相册权限未授予，无法选择图片');
      return false;
    }
    return true;
  }

  Future<void> _pickFromSystemAlbum(VoidCallback refreshSheet) async {
    final remain = _maxMediaCount - _selectedMedia.length;
    if (remain <= 0) {
      _showValidation('最多选择$_maxMediaCount张图片');
      return;
    }

    final hasPermission = await _checkPhotoPermission();
    if (!hasPermission) return;

    try {
      final files = await _picker.pickMultipleMedia(
        imageQuality: 88,
        limit: remain,
      );
      if (files.isEmpty) return;

      setState(() {
        for (int i = 0; i < files.length; i++) {
          final file = files[i];
          final ext = file.path.contains('.')
              ? '.${file.path.split('.').last.toLowerCase()}'
              : '';
          final isVideo = _videoExtensions.contains(ext);
          final media = _SelectableMedia(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            value: file.path,
            isVideo: isVideo,
          );

          _localMediaLibrary.add(media);
          if (_selectedMedia.length < _maxMediaCount) {
            _selectedMedia.add(media);
          }
        }
      });
      refreshSheet();
      _saveDraftDebounced();
    } catch (_) {
      _showValidation('读取相册失败，请检查权限后重试');
    }
  }

  Future<void> _openMediaPickerSheet() async {
    _focusNode.unfocus();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final pool = _localMediaLibrary;
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDEDEDE),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '选择图片',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickFromSystemAlbum(() {
                            setSheetState(() {});
                          }),
                          icon: const Icon(Icons.photo_library_outlined,
                              size: 18),
                          label: const Text('从系统相册选择'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '已选择 ${_selectedMedia.length}/$_maxMediaCount',
                          style: const TextStyle(
                              color: Color(0xFF888888), fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: pool.isEmpty
                          ? const Center(
                              child: Text(
                                '暂无本地图片，点击上方按钮导入',
                                style: TextStyle(color: Color(0xFF999999)),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: pool.length,
                              itemBuilder: (context, index) {
                                final media = pool[index];
                                final selected = _isSelected(media);
                                return InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    _toggleMedia(media);
                                    setSheetState(() {});
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _buildMediaPreview(media,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      if (selected)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withValues(alpha: 0.32),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? const Color(0xFF8B5CF6)
                                                : Colors.black
                                                    .withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            selected ? Icons.check : Icons.add,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('完成 (${_selectedMedia.length})'),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasDraftContent || _isSubmitting,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _onClosePressed();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 24),
            onPressed: _onClosePressed,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _isSubmitting ? null : _submitMoment,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        '发布',
                        style: TextStyle(
                          color: _canPublish
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFFD0D3DE),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView(
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: 200,
                maxLines: 4,
                minLines: 4,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: const InputDecoration(
                  hintText: '探索未知，感受自然之美。',
                  hintStyle: TextStyle(
                    color: Color(0xFFD0D3DE),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  counter: null,
                ),
                buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) {
                  return Text(
                    '$currentLength/$maxLength',
                    style:
                        const TextStyle(color: Color(0xFFD0D3DE), fontSize: 13),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._selectedMedia.map(_buildSelectedTile),
                  if (_selectedMedia.length < _maxMediaCount)
                    _buildAddMediaTile(),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _inlineError ?? '请选择1-$_maxMediaCount张图片并填写文案后发布',
                style: TextStyle(
                  color: _inlineError == null
                      ? const Color(0xFF999999)
                      : const Color(0xFFD14343),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(_SelectableMedia media,
      {BorderRadius? borderRadius}) {
    final br = borderRadius ?? BorderRadius.circular(8);
    if (media.isVideo) {
      return ClipRRect(
        borderRadius: br,
        child: Container(
          color: const Color(0xFF1A1A2E),
          child: const Center(
            child:
                Icon(Icons.play_circle_fill, color: Colors.white70, size: 32),
          ),
        ),
      );
    }
    return SmartImage(
      source: media.value,
      borderRadius: br,
    );
  }

  Widget _buildSelectedTile(_SelectableMedia media) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => showImagePreview(context, media.value),
              child: _buildMediaPreview(media),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _toggleMedia(media),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                media.isVideo ? '视频' : '本地',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '分类',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isSelected ? Colors.white : const Color(0xFF666666),
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAddMediaTile() {
    return GestureDetector(
      onTap: _openMediaPickerSheet,
      child: CustomPaint(
        painter: DashedRectPainter(
          color: const Color(0xFFE3E8F2),
          strokeWidth: 1,
          radius: 6,
          dashWidth: 4,
          dashSpace: 4,
        ),
        child: Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: const Icon(Icons.add, color: Color(0xFFD0D3DE), size: 28),
        ),
      ),
    );
  }
}

enum _ExitAction {
  cancel,
  discardAndExit,
  saveAndExit,
}

class _SelectableMedia {
  final String id;
  final String value;
  final bool isVideo;

  const _SelectableMedia({
    required this.id,
    required this.value,
    this.isVideo = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'isVideo': isVideo,
    };
  }

  factory _SelectableMedia.fromJson(Map<String, dynamic> json) {
    return _SelectableMedia(
      id: json['id'] as String,
      value: json['value'] as String,
      isVideo: (json['isVideo'] as bool?) ?? false,
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1,
    this.radius = 6,
    this.dashWidth = 4,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashPath = Path();
    for (final measurePath in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
