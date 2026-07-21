import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/router/user_profile_route.dart';
import '../../models/post.dart';
import '../../providers/feed_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/hi_greet_button.dart';
import '../../widgets/moment_text.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';

// 右下角「Hi」搭讪预设招呼语（与拍友列表 / 动态卡片一致）。
const String _kVideoGreeting = '你的照片很好看，可以教教我怎么拍吗！';

/// 动态视频全屏播放（第四次迭代 3.3）：竖向滑动切换的视频流。
/// 每页：视频（无源时帖子首图 poster 兜底）+ 头像/关注/点赞/搭讪/动态文本叠层。
class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({
    super.key,
    required this.posts,
    this.initialIndex = 0,
  });

  final List<Post> posts;
  final int initialIndex;

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late final PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.posts.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => _VideoFeedPage(
              key: ValueKey<String>('videoFeed.page.${widget.posts[i].id}'),
              post: widget.posts[i],
              isActive: i == _current,
            ),
          ),
          // 退出
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: GestureDetector(
              key: const ValueKey<String>('videoFeed.close'),
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoFeedPage extends ConsumerStatefulWidget {
  const _VideoFeedPage({super.key, required this.post, required this.isActive});

  final Post post;
  final bool isActive;

  @override
  ConsumerState<_VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends ConsumerState<_VideoFeedPage> {
  VideoPlayerController? _controller;
  bool _ready = false;
  late bool _liked = widget.post.isLiked;
  late int _likes = widget.post.likesCount;
  bool _following = false;
  bool _greeted = false;

  @override
  void initState() {
    super.initState();
    // 关注态以关系表为准（与用户主页一致），保证返回后状态同步。
    _following = AppRepository.instance
        .isFollowing(AppRepository.instance.currentUserId, widget.post.userId);
    _maybeInitVideo();
  }

  @override
  void didUpdateWidget(_VideoFeedPage old) {
    super.didUpdateWidget(old);
    if (widget.isActive != old.isActive) {
      if (widget.isActive) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  void _maybeInitVideo() {
    final url = widget.post.videoUrl;
    if (url == null || url.isEmpty) return;
    final c = url.startsWith('http')
        ? VideoPlayerController.networkUrl(Uri.parse(url))
        : (url.startsWith('assets/')
            ? VideoPlayerController.asset(url)
            : VideoPlayerController.file(File(url)));
    _controller = c;
    c.setLooping(true);
    c.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      if (widget.isActive) c.play();
    }).catchError((_) {
      // 视频源不可用：保留 poster 兜底
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    ref.read(homeFeedProvider.notifier).toggleLike(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final author = AppRepository.instance.getUser(widget.post.userId);
    final poster =
        widget.post.images.isNotEmpty ? widget.post.images.first : null;

    return GestureDetector(
      onTap: () {
        final c = _controller;
        if (c != null && c.value.isInitialized) {
          setState(() => c.value.isPlaying ? c.pause() : c.play());
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景：视频就绪显示视频，否则 poster 兜底
          if (_ready && _controller != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            )
          else if (poster != null)
            SmartImage(source: poster, fit: BoxFit.cover)
          else
            const ColoredBox(color: Colors.black),
          // 底部渐变，保证文字可读
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ),
          // 右侧操作列：头像+关注 / 点赞（Figma v4：搭讪移至右下角 Hi 钮）
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              children: [
                _AvatarFollow(
                  author: author,
                  following: _following,
                  onAvatar: () => openUserProfile(context, author.id),
                  onFollow: () {
                    final next = !_following;
                    AppRepository.instance.setFollowing(
                      AppRepository.instance.currentUserId,
                      widget.post.userId,
                      following: next,
                    );
                    setState(() => _following = next);
                  },
                ),
                const SizedBox(height: 20),
                _ActionIcon(
                  // Figma v4：❤️ 始终为品牌粉红色（点赞态加深一档），非白色
                  icon: Icons.favorite,
                  color: _liked
                      ? const Color(0xFFFF2D55)
                      : const Color(0xFFFF4D6A),
                  label: '$_likes',
                  onTap: _toggleLike,
                  keyName: 'videoFeed.like',
                ),
              ],
            ),
          ),
          // 右下角「Hi」搭讪钮（Figma v4：蓝→紫渐变圆钮，44×44，无标签）
          Positioned(
            right: 12,
            bottom: 44,
            child: GestureDetector(
              onTap: () {
                setState(() => _greeted = true);
                final uri = Uri(
                  path: '/chat/${widget.post.userId}',
                  queryParameters: const <String, String>{
                    'greeting': _kVideoGreeting,
                  },
                );
                context.push(uri.toString());
              },
              behavior: HitTestBehavior.opaque,
              child: HiGreetButton(
                key: const ValueKey<String>('videoFeed.hi'),
                contacted: _greeted,
                size: 44,
              ),
            ),
          ),
          // 左下：昵称 + 动态文本（翻译/展开收起与动态一致）
          Positioned(
            left: 14,
            right: 80,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@${author.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.post.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  MomentText(
                    translated: widget.post.content,
                    original: widget.post.contentOriginal,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    actionColor: const Color(0xFFD9C9FF),
                    translateIdleColor: Colors.white70,
                    maskColor: Colors.transparent,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFollow extends StatelessWidget {
  const _AvatarFollow({
    required this.author,
    required this.following,
    required this.onAvatar,
    required this.onFollow,
  });

  final dynamic author;
  final bool following;
  final VoidCallback onAvatar;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 60,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          GestureDetector(
            onTap: onAvatar,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: SmartAvatar(
                radius: 22,
                source: author.avatarUrl,
                fallbackName: author.name,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: GestureDetector(
              key: const ValueKey<String>('videoFeed.follow'),
              onTap: onFollow,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: following ? Colors.white : const Color(0xFFFF4D6A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Icon(
                  following ? Icons.check : Icons.add,
                  size: 14,
                  color: following ? const Color(0xFFFF4D6A) : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    required this.keyName,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey<String>(keyName),
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
