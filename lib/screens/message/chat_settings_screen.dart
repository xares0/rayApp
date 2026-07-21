import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/blocked_users_provider.dart';
import '../../providers/chat_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/smart_avatar.dart';

/// 消息设置页（vv2）：头像/昵称居中 + 备注 / 置顶 / 举报 / 拉黑 / 清空聊天记录。
class ChatSettingsScreen extends ConsumerStatefulWidget {
  const ChatSettingsScreen({super.key, required this.otherUserId});

  final String otherUserId;

  @override
  ConsumerState<ChatSettingsScreen> createState() =>
      _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends ConsumerState<ChatSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final other = AppRepository.instance.getUser(widget.otherUserId);
    final pinned = currentUser != null &&
        AppRepository.instance.getConversationPinUpdatedAt(
              currentUser.id,
              widget.otherUserId,
            ) !=
            null;
    final remark = other.remarkName ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          // 顶部紫色渐变区：导航栏 + 用户信息（头像/昵称居中）。
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE9E4FB), Color(0xFFF7F7F7)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        IconButton(
                          key: const ValueKey<String>('chatSettings.back'),
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              size: 18, color: Color(0xFF333333)),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              '消息设置',
                              style: TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SmartAvatar(
                    radius: 34,
                    source: other.avatarUrl,
                    fallbackName: other.name,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remark.isNotEmpty ? remark : other.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
          // 设置项卡片（单卡片承载全部行，行间细分割线）。
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _SettingRow(
                  label: '设置备注',
                  onTap: () => _editRemark(remark),
                ),
                const _RowDivider(),
                _PinRow(
                  value: pinned,
                  onChanged: currentUser == null
                      ? null
                      : (v) => _togglePin(currentUser.id, v),
                ),
                const _RowDivider(),
                _SettingRow(label: '举报', onTap: _report),
                const _RowDivider(),
                _SettingRow(label: '拉黑', onTap: _block),
                const _RowDivider(),
                _SettingRow(
                  label: '清空聊天记录',
                  onTap: () => _clearMessages(currentUser?.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editRemark(String current) async {
    final result = await showFigmaInputDialog(
      context,
      title: '设置备注',
      initialValue: current,
      hintText: '请输入备注（最多20字）',
      maxLength: 20, // 上限 20 字符，超出自动截断
    );
    if (result == null) return;
    AppRepository.instance.setRemarkName(widget.otherUserId, result);
    ref.invalidate(chatListProvider);
    if (!mounted) return;
    setState(() {});
    showAppToast(context, '备注已更新');
  }

  void _togglePin(String userId, bool pin) {
    if (pin) {
      AppRepository.instance
          .pinConversation(userId: userId, otherUserId: widget.otherUserId);
    } else {
      AppRepository.instance
          .unpinConversation(userId: userId, otherUserId: widget.otherUserId);
    }
    ref.invalidate(chatListProvider);
    setState(() {});
  }

  void _report() {
    context.push(
        '/report?targetType=user&targetId=${widget.otherUserId}');
  }

  void _block() {
    ref.read(blockedUsersProvider.notifier).blockUser(widget.otherUserId);
    showAppToast(context, '拉黑成功');
  }

  Future<void> _clearMessages(String? userId) async {
    if (userId == null) return;
    final confirm = await showFigmaSplitConfirmDialog(
      context,
      title: '确认全部删除',
      message: '删除后无法恢复，请确认是否继续。',
      cancelText: '取消',
      confirmText: '确认',
      cancelColor: const Color(0xFF666666),
    );
    if (!confirm) return;
    AppRepository.instance.clearConversationMessages(
      userId: userId,
      otherUserId: widget.otherUserId,
    );
    ref.invalidate(chatMessagesProvider(widget.otherUserId));
    ref.invalidate(chatListProvider);
    if (!mounted) return;
    showAppToast(context, '聊天记录已清除');
  }
}

/// 普通设置行：左侧文案 + 右侧灰色箭头，48 高。
class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF333333)),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    size: 18, color: Color(0xFFC9CDD4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 会话置顶行：文案 + 紫色开关。
class _PinRow extends StatelessWidget {
  const _PinRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Text(
              '会话置顶',
              style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
            const Spacer(),
            Switch(
              key: const ValueKey<String>('chatSettings.pin'),
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
              trackOutlineColor:
                  const WidgetStatePropertyAll<Color>(Colors.transparent),
              trackColor: WidgetStateProperty.resolveWith<Color>(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFFCBA6F7)
                    : const Color(0xFFE5E5E5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 卡片内行间分割线。
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0.5,
      thickness: 0.5,
      indent: 16,
      color: Color(0xFFEEEEEE),
    );
  }
}
