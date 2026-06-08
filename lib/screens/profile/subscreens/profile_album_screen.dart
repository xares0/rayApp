import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/post.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../widgets/interaction_utils.dart';
import '../../../widgets/smart_image.dart';
import '../../moment/video_player_screen.dart';

class ProfileAlbumScreen extends ConsumerStatefulWidget {
  const ProfileAlbumScreen({super.key});

  @override
  ConsumerState<ProfileAlbumScreen> createState() => _ProfileAlbumScreenState();
}

class _ProfileAlbumScreenState extends ConsumerState<ProfileAlbumScreen> {
  static const _videoExtensions = {
    '.mp4',
    '.mov',
    '.avi',
    '.mkv',
    '.m4v',
    '.3gp',
    '.wmv'
  };
  static const _spKey = 'profile_album_local_media';

  final ImagePicker _picker = ImagePicker();
  final List<_AlbumItem> _localMedia = [];

  @override
  void initState() {
    super.initState();
    _loadCachedMedia();
  }

  // ── SP persistence ──
  Future<void> _loadCachedMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_spKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      final items = list
          .map((e) => _AlbumItem(
                source: e['source'] as String,
                isVideo: e['isVideo'] as bool,
              ))
          .where((item) {
        // Only keep items whose local files still exist
        return File(item.source).existsSync();
      }).toList();
      if (items.isNotEmpty && mounted) {
        setState(() => _localMedia.addAll(items));
      }
    } catch (_) {
      // Corrupted data – clear it
      await prefs.remove(_spKey);
    }
  }

  Future<void> _saveCachedMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(
      _localMedia
          .map((e) => {'source': e.source, 'isVideo': e.isVideo})
          .toList(),
    );
    await prefs.setString(_spKey, json);
  }

  // ── Permission check ──
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
          content: const Text('请在系统设置中允许访问相册，以便选择照片和视频。'),
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
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('相册权限未授予，无法选择图片')),
      );
      return false;
    }
    return true;
  }

  // ── Pick media ──
  Future<void> _pickMedia() async {
    final hasPermission = await _checkPhotoPermission();
    if (!hasPermission) return;

    try {
      final files = await _picker.pickMultipleMedia(imageQuality: 88);
      if (files.isEmpty) return;

      setState(() {
        for (final file in files) {
          final ext = file.path.contains('.')
              ? '.${file.path.split('.').last.toLowerCase()}'
              : '';
          final isVideo = _videoExtensions.contains(ext);
          // Avoid duplicates
          if (_localMedia.any((m) => m.source == file.path)) continue;
          _localMedia.add(_AlbumItem(source: file.path, isVideo: isVideo));
        }
      });
      // Persist to SP
      await _saveCachedMedia();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('读取相册失败，请检查权限后重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final List<Post> posts =
        user == null ? <Post>[] : ref.watch(profilePostsProvider(user.id));

    // Collect all media items: local picked + from posts
    final List<_AlbumItem> allMedia = [..._localMedia];
    for (final post in posts) {
      for (final img in post.images) {
        allMedia.add(_AlbumItem(source: img, isVideo: false));
      }
      if (post.videoUrl != null) {
        allMedia.add(_AlbumItem(source: post.videoUrl!, isVideo: true));
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '我的相册',
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: allMedia.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '暂无图片，去发布投稿吧',
                    style: TextStyle(color: Color(0xFF999999)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickMedia,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('选择照片/视频'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: allMedia.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddPhotoTile();
                }
                final item = allMedia[index - 1];
                return _buildMediaTile(item);
              },
            ),
    );
  }

  Widget _buildAddPhotoTile() {
    return GestureDetector(
      onTap: _pickMedia,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, color: Colors.black, size: 28),
            SizedBox(height: 8),
            Text(
              '照片/视频',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete local media ──
  Future<void> _deleteLocalMedia(_AlbumItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除确认'),
        content: const Text('确定要从相册中移除该项吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _localMedia.remove(item));
    await _saveCachedMedia();
  }

  Widget _buildMediaTile(_AlbumItem item) {
    final isLocal = item.source.startsWith('/');
    return GestureDetector(
      onTap: () {
        if (item.isVideo) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(videoUrl: item.source),
            ),
          );
        } else {
          showImagePreview(context, item.source);
        }
      },
      onLongPress: isLocal ? () => _deleteLocalMedia(item) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.isVideo)
              Container(
                color: const Color(0xFF1A1A2E),
                child: const Center(
                  child: Icon(Icons.videocam, color: Colors.white38, size: 28),
                ),
              )
            else if (isLocal)
              Image.file(
                File(item.source),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF2F2F2),
                  child:
                      const Icon(Icons.broken_image, color: Color(0xFFAAAAAA)),
                ),
              )
            else
              SmartImage(
                source: item.source,
                borderRadius: BorderRadius.circular(8),
              ),
            if (item.isVideo)
              Center(
                child: Icon(Icons.play_circle_fill,
                    color: Colors.white.withValues(alpha: 0.85), size: 32),
              ),
            // "本地" badge for locally picked items
            if (isLocal && !item.isVideo)
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '本地',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
            if (item.isVideo)
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '视频',
                    style: TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlbumItem {
  final String source;
  final bool isVideo;
  const _AlbumItem({required this.source, required this.isVideo});
}
