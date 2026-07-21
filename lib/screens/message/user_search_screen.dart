import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/smart_avatar.dart';

// 搜索结果「搭讪」预设招呼语（与拍友列表 / 动态卡片一致）。
const String _kSearchGreeting = '你的照片很好看，可以教教我怎么拍吗！';

/// 搜索功能（vv2）：按昵称模糊匹配 + ID 匹配，结果显示头像/昵称/ID/搭讪，
/// 无结果或未搜索时显示「啥也搜不到」缺省页。
class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<User> _results = const [];
  bool _searched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _doSearch() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searched = false;
        _results = const [];
      });
      return;
    }
    // 模糊搜索：昵称 / 备注名 / ID / 展示 ID 任一包含关键词即命中（大小写不敏感）。
    final keyword = query.toLowerCase();
    final results = AppRepository.instance.users.where((u) {
      final name = u.name.toLowerCase();
      final remark = (u.remarkName ?? '').toLowerCase();
      final displayId = (u.displayId ?? '').toLowerCase();
      final id = u.id.toLowerCase();
      return name.contains(keyword) ||
          remark.contains(keyword) ||
          displayId.contains(keyword) ||
          id.contains(keyword);
    }).toList();
    setState(() {
      _searched = true;
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        titleSpacing: 0,
        // Figma vv2：圆角灰底输入框（无内嵌图标），右侧为放大镜按钮。
        title: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            key: const ValueKey<String>('search.input'),
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _doSearch(),
            style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              hintText: 'Enter ID',
              hintStyle: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
            ),
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey<String>('search.button'),
            onPressed: _doSearch,
            icon: const Icon(Icons.search, size: 22, color: Color(0xFF333333)),
          ),
        ],
      ),
      body: !_searched || _results.isEmpty
          ? const _SearchEmpty()
          : ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFF0F0F0),
              ),
              itemBuilder: (context, i) => _SearchResultRow(user: _results[i]),
            ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  const _SearchResultRow({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SmartAvatar(
              radius: 21.5, source: user.avatarUrl, fallbackName: user.name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF202020)),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID：${user.displayId ?? user.id}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          // Figma vv2：搭讪入口为圆形纯色钮（#DCA0FF）+ 聊天气泡图标。
          GestureDetector(
            key: ValueKey<String>('search.hi.${user.id}'),
            onTap: () {
              final uri = Uri(
                path: '/chat/${user.id}',
                queryParameters: const <String, String>{
                  'greeting': _kSearchGreeting,
                },
              );
              context.push(uri.toString());
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDCA0FF),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.forum_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/message/search_empty.png',
            key: const ValueKey<String>('search_empty_illustration'),
            width: 184,
            height: 184,
            fit: BoxFit.contain,
          ),
          // 插画 184x184 底部留白较多，上移文案贴合视觉重心。
          Transform.translate(
            offset: const Offset(0, -38),
            child: const Text(
              '啥也搜不到...',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
