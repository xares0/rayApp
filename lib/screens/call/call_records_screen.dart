import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../repositories/app_repository.dart';
import '../../utils/permission_utils.dart';
import '../../widgets/smart_avatar.dart';

// ---------------------------------------------------------------------------
// Mock 数据模型
// ---------------------------------------------------------------------------

enum CallType {
  audioIncoming, // 语音-接听
  audioOutgoing, // 语音-拨出
  videoIncoming, // 视频-接听
  videoOutgoing, // 视频-拨出
  missedIncoming, // 未接来电
}

class CallRecord {
  const CallRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.durationLabel, // e.g. '02:00'
    required this.time,
  });

  final String id;
  final String userId;
  final CallType type;
  final String durationLabel;
  final DateTime time;
}

// ---------------------------------------------------------------------------
// Mock 通话记录数据（基于 AppRepository users u2-u11 头像/昵称）
// ---------------------------------------------------------------------------

List<CallRecord> _buildMockRecords() {
  final now = DateTime.now();
  return [
    CallRecord(
      id: 'cr1',
      userId: 'u4',
      type: CallType.audioIncoming,
      durationLabel: '02:00',
      time: now.subtract(const Duration(minutes: 3)),
    ),
  ];
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class CallRecordsScreen extends ConsumerStatefulWidget {
  const CallRecordsScreen({
    super.key,
    this.initialRecords,
  });

  final List<CallRecord>? initialRecords;

  @override
  ConsumerState<CallRecordsScreen> createState() => _CallRecordsScreenState();
}

class _CallRecordsScreenState extends ConsumerState<CallRecordsScreen> {
  late final List<CallRecord> _records;

  @override
  void initState() {
    super.initState();
    _records = widget.initialRecords ?? _buildMockRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _CallRecordsNavBar(),
            Expanded(
              child: _records.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无通话记录',
                        style: TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 14,
                          fontFamily: 'PingFang SC',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 21),
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        final record = _records[index];
                        final user =
                            AppRepository.instance.getUser(record.userId);
                        return _CallRecordItem(
                          key: ValueKey<String>('callRecords.item.$index'),
                          itemIndex: index,
                          record: record,
                          userName: user.name,
                          avatarUrl: user.avatarUrl,
                          showDivider: true,
                          onCallBack: () async {
                            final granted = await ensureMicrophonePermission(
                              context,
                              usage: '进行视频通话',
                            );
                            if (!granted || !context.mounted) return;
                            context.push(
                              '/call/video/${record.userId}?state=outgoingB',
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallRecordsNavBar extends StatelessWidget {
  const _CallRecordsNavBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 48,
              height: 44,
              child: Stack(
                children: [
                  Positioned(
                    key: ValueKey<String>('callRecords.backFrame'),
                    left: 14,
                    top: 18,
                    width: 20,
                    height: 20,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF333333),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 128,
            top: 14,
            width: 120,
            height: 28,
            child: Container(
              key: const ValueKey<String>('callRecords.titleFrame'),
              color: Colors.transparent,
              child: const Center(
                child: Text(
                  '通话记录',
                  key: ValueKey<String>('callRecords.title'),
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                    height: 28 / 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 列表行
// ---------------------------------------------------------------------------

class _CallRecordItem extends StatelessWidget {
  const _CallRecordItem({
    super.key,
    required this.itemIndex,
    required this.record,
    required this.userName,
    required this.avatarUrl,
    required this.showDivider,
    required this.onCallBack,
  });

  final int itemIndex;
  final CallRecord record;
  final String userName;
  final String avatarUrl;
  final bool showDivider;
  final VoidCallback onCallBack;

  /// 时间格式化（与 visitors_screen 保持一致）
  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inSeconds < 60) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays == 1) return '昨天';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${t.month}/${t.day}';
  }

  @override
  Widget build(BuildContext context) {
    final timeText = _formatTime(record.time);
    final isMissed = record.type == CallType.missedIncoming;

    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.only(left: 11, right: 11),
        child: Stack(
          children: [
            SmartAvatar(
              key: ValueKey<String>('callRecords.avatar.$itemIndex'),
              radius: 21,
              source: avatarUrl,
              fallbackName: userName,
            ),
            Positioned(
              left: 51,
              top: 3,
              right: 92,
              child: Text(
                userName,
                key: ValueKey<String>('callRecords.name.$itemIndex'),
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  height: 20 / 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 51,
              top: 26,
              child: Text(
                isMissed ? '未接来电' : record.durationLabel,
                key: ValueKey<String>('callRecords.duration.$itemIndex'),
                style: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: isMissed
                      ? const Color(0xFFFF4D4D)
                      : const Color(0xFF999999),
                  height: 14 / 10,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 3,
              width: 74,
              child: Text(
                timeText,
                textAlign: TextAlign.right,
                key: ValueKey<String>('callRecords.time.$itemIndex'),
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF999999),
                  height: 14 / 10,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 25,
              child: _CallBackButton(
                key: ValueKey<String>('callRecords.callback.$itemIndex'),
                itemIndex: itemIndex,
                type: record.type,
                onTap: onCallBack,
              ),
            ),
            if (showDivider)
              Positioned(
                left: 48,
                right: 3.5,
                top: 57,
                child: ColoredBox(
                  key: ValueKey<String>('callRecords.divider.$itemIndex'),
                  color: const Color(0xFFE8E8E8),
                  child: const SizedBox(height: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 回拨按钮：加宽避免与右侧时间一起显示时被裁切。
// ---------------------------------------------------------------------------

class _CallBackButton extends StatelessWidget {
  const _CallBackButton({
    super.key,
    required this.itemIndex,
    required this.type,
    required this.onTap,
  });

  final int itemIndex;
  final CallType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isVideo =
        type == CallType.videoIncoming || type == CallType.videoOutgoing;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 64,
        height: 22,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18.5),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 5,
              top: 4,
              width: 14,
              height: 14,
              child: Icon(
                key: ValueKey<String>('callRecords.callbackIcon.$itemIndex'),
                isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 22,
              top: 2,
              width: 34,
              height: 17,
              child: Text(
                '回拨',
                key: ValueKey<String>('callRecords.callbackText.$itemIndex'),
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 17 / 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
