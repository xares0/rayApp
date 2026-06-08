import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../models/message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/blocked_users_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/gift_provider.dart';
import '../../repositories/app_repository.dart';
import '../../widgets/interaction_utils.dart';
import '../../widgets/smart_avatar.dart';
import '../../widgets/smart_image.dart';
import '../moment/video_player_screen.dart';
import 'voice_record_interaction.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String otherUserId;

  /// 进入会话时自动发送的预设消息（如从拍友卡片评论入口进入时的招呼语）。
  final String? initialGreeting;

  const ChatRoomScreen({
    super.key,
    required this.otherUserId,
    this.initialGreeting,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _recordTimer;
  bool _isSimulatingReply = false;
  bool _showEmojiPanel = false;
  bool _voiceMode = false;
  bool _isRecording = false;
  bool _voiceButtonPressed = false;
  bool _voiceGestureActive = false;
  VoiceHoverTarget _voiceHoverTarget = VoiceHoverTarget.none;
  int _recordPulseTick = 0;
  Offset? _cancelCircleCenter;
  Offset? _sendCircleCenter;
  String? _playingMessageId;
  DateTime? _recordStartedAt;

  static const List<_EmojiOption> _emojiList = [
    _EmojiOption('😀', '开心'),
    _EmojiOption('😁', '开心'),
    _EmojiOption('😂', '大笑'),
    _EmojiOption('🤣', '爆笑'),
    _EmojiOption('😊', '可爱'),
    _EmojiOption('😍', '喜欢'),
    _EmojiOption('😘', '亲亲'),
    _EmojiOption('😎', '酷'),
    _EmojiOption('🤔', '思考'),
    _EmojiOption('😭', '委屈'),
    _EmojiOption('😡', '生气'),
    _EmojiOption('🥳', '庆祝'),
    _EmojiOption('👍', '赞'),
    _EmojiOption('👎', '失望'),
    _EmojiOption('👏', '鼓掌'),
    _EmojiOption('🙏', '谢谢'),
    _EmojiOption('🔥', '火热'),
    _EmojiOption('💯', '满分'),
    _EmojiOption('🎉', '庆祝'),
    _EmojiOption('✨', '闪亮'),
    _EmojiOption('❤️', '爱心'),
    _EmojiOption('💔', '难过'),
    _EmojiOption('👌', 'OK'),
    _EmojiOption('🤝', '合作'),
  ];

  bool get _canSend => _inputController.text.trim().isNotEmpty;

  bool get _recordWillCancel => _voiceHoverTarget == VoiceHoverTarget.cancel;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
    _inputFocusNode.addListener(() {
      if (!mounted) return;
      if (_inputFocusNode.hasFocus && _showEmojiPanel) {
        setState(() {
          _showEmojiPanel = false;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playingMessageId = null;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _markConversationRead();
      _scrollToBottom();
      final greeting = widget.initialGreeting?.trim();
      if (greeting != null && greeting.isNotEmpty) {
        await _sendOutgoingMessage(
          content: greeting,
          type: MessageType.text,
        );
      }
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshChatProviders() {
    ref.invalidate(chatMessagesProvider(widget.otherUserId));
    ref.invalidate(chatListProvider);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 160,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _toggleEmojiPanel() {
    setState(() {
      _voiceMode = false;
      _showEmojiPanel = !_showEmojiPanel;
    });
    if (_showEmojiPanel) {
      _inputFocusNode.unfocus();
    } else {
      _inputFocusNode.requestFocus();
    }
  }

  void _toggleVoiceMode() {
    if (_isRecording) return;
    _dismissInputOverlays();
    setState(() {
      _voiceMode = !_voiceMode;
      _showEmojiPanel = false;
    });
  }

  void _dismissInputOverlays() {
    _inputFocusNode.unfocus();
    if (_showEmojiPanel) {
      setState(() {
        _showEmojiPanel = false;
      });
    }
  }

  void _markConversationRead() {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;
    AppRepository.instance.markConversationAsRead(
      userId: currentUser.id,
      otherUserId: widget.otherUserId,
    );
    _refreshChatProviders();
  }

  Future<void> _sendTextMessage() async {
    if (!_canSend) return;
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    await _sendOutgoingMessage(
      content: text,
      type: MessageType.text,
    );
  }

  Future<void> _sendEmojiMessage(_EmojiOption emoji) async {
    await _sendOutgoingMessage(
      content: emoji.value,
      type: MessageType.emoji,
      emojiLabel: emoji.label,
    );
  }

  Future<void> _pickAndSendImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1440,
    );
    if (file == null) return;
    await _sendOutgoingMessage(
      content: '',
      type: MessageType.image,
      mediaPath: file.path,
      thumbnailPath: file.path,
    );
  }

  Future<void> _pickAndSendVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    await _sendOutgoingMessage(
      content: '',
      type: MessageType.video,
      mediaPath: file.path,
    );
  }

  Future<void> _sendOutgoingMessage({
    required String content,
    required MessageType type,
    String? mediaPath,
    String? thumbnailPath,
    int? voiceDurationSeconds,
    String? emojiLabel,
  }) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    final repo = AppRepository.instance;
    final draftMessage = repo.addMessage(
      senderId: currentUser.id,
      receiverId: widget.otherUserId,
      content: content,
      isRead: true,
      type: type,
      mediaPath: mediaPath,
      thumbnailPath: thumbnailPath,
      voiceDurationSeconds: voiceDurationSeconds,
      emojiLabel: emojiLabel,
      sendStatus: MessageSendStatus.sending,
    );
    _refreshChatProviders();
    _scrollToBottom();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 320));
      repo.updateMessage(
        draftMessage.id,
        draftMessage.copyWith(
          sendStatus: MessageSendStatus.sent,
          createdAt: DateTime.now(),
        ),
      );
      _refreshChatProviders();
      _scrollToBottom();
      unawaited(_simulateReply(type, content));
    } catch (_) {
      repo.updateMessage(
        draftMessage.id,
        draftMessage.copyWith(sendStatus: MessageSendStatus.failed),
      );
      _refreshChatProviders();
      if (mounted) {
        showAppToast(context, '发送失败，请重试');
      }
    }
  }

  Future<void> _simulateReply(MessageType type, String content) async {
    if (!mounted) return;
    setState(() {
      _isSimulatingReply = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    final reply = _buildAutoReply(type, content);
    AppRepository.instance.addMessage(
      senderId: widget.otherUserId,
      receiverId: currentUser.id,
      content: reply.content,
      isRead: true,
      type: reply.type,
      emojiLabel: reply.emojiLabel,
    );
    _refreshChatProviders();

    setState(() {
      _isSimulatingReply = false;
    });
    _scrollToBottom();
  }

  _ReplyDraft _buildAutoReply(MessageType type, String content) {
    if (AppRepository.instance.isOfficialSupportUser(widget.otherUserId)) {
      return _ReplyDraft(
        content: AppRepository.instance.buildOfficialSupportReply(content),
      );
    }

    switch (type) {
      case MessageType.image:
        return const _ReplyDraft(content: '这张图的色调很好看。');
      case MessageType.video:
        return const _ReplyDraft(content: '视频节奏不错，运镜挺稳。');
      case MessageType.voice:
        return const _ReplyDraft(content: '语音听到了，我晚点细说。');
      case MessageType.emoji:
        return const _ReplyDraft(
          content: '😊',
          type: MessageType.emoji,
          emojiLabel: '可爱',
        );
      case MessageType.text:
        if (content.contains('?') || content.contains('？')) {
          return const _ReplyDraft(content: '我理解你的意思，我们可以详细聊聊。');
        }
        if (content.length <= 4) {
          return const _ReplyDraft(content: '收到');
        }
        return const _ReplyDraft(content: '看到了，我晚点给你更完整的反馈。');
      case MessageType.recall:
      case MessageType.system:
        return const _ReplyDraft(content: '收到');
    }
  }

  /// 08节点：点「+」弹出的通话 action sheet（视频通话/语音通话/取消）
  Future<void> _showCallActionSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x80040110),
      builder: (sheetContext) => const _CallActionSheet(),
    );
    if (!mounted || result == null) return;
    if (result == 'video') {
      context.push('/call/video/${widget.otherUserId}?state=outgoingB');
    } else if (result == 'voice') {
      context.push('/call/voice/${widget.otherUserId}?callState=outgoing');
    }
  }

  Future<void> _handleMoreAction(_ChatMoreAction action) async {
    if (action == _ChatMoreAction.report) {
      showAppToast(context, '举报成功，感谢您对平台的支持');
      return;
    }
    final confirmed = await showBlockConfirmDialog(context);
    if (!mounted || confirmed != true) return;
    ref.read(blockedUsersProvider.notifier).blockUser(widget.otherUserId);
    _refreshChatProviders();
    showAppToast(context, '拉黑成功');
  }

  Future<void> _startRecording() async {
    if (_isRecording || !_voiceGestureActive) return;
    final microphonePermission = await Permission.microphone.request();
    if (!microphonePermission.isGranted) {
      _voiceGestureActive = false;
      if (!mounted) return;
      setState(() {
        _voiceButtonPressed = false;
      });
      showAppToast(context, '请先允许麦克风权限');
      if (microphonePermission.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }
    if (!_voiceGestureActive) return;

    final tempDirectory = await getTemporaryDirectory();
    final path =
        '${tempDirectory.path}/voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      if (!_voiceGestureActive) {
        await _audioRecorder.cancel();
        return;
      }
      _recordTimer?.cancel();
      _recordStartedAt = DateTime.now();
      _recordPulseTick = 0;
      _recordTimer = Timer.periodic(const Duration(milliseconds: 160), (_) {
        if (!mounted) return;
        setState(() {
          _recordPulseTick += 1;
        });
      });
      await HapticFeedback.mediumImpact();
      setState(() {
        _isRecording = true;
        _voiceHoverTarget = VoiceHoverTarget.none;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _voiceButtonPressed = false;
      });
      showAppToast(context, '录音启动失败，请稍后再试');
    }
  }

  Duration get _currentRecordDuration {
    final startedAt = _recordStartedAt;
    if (startedAt == null) return Duration.zero;
    return DateTime.now().difference(startedAt);
  }

  VoiceUiStage? get _voiceUiStage => deriveVoiceUiStage(
        voiceMode: _voiceMode,
        isRecording: _isRecording,
        willCancel: _recordWillCancel,
        hoverSend: _voiceHoverTarget == VoiceHoverTarget.send,
        duration: _currentRecordDuration,
      );

  Future<void> _finishRecording({bool forceCancel = false}) async {
    if (!_isRecording) return;
    _recordTimer?.cancel();
    final duration = _currentRecordDuration;
    final shouldCancel = forceCancel || _recordWillCancel;
    final isTooShort = !shouldCancel && isVoiceMessageTooShort(duration);
    final voiceDurationSeconds =
        duration.inSeconds == 0 ? 1 : duration.inSeconds;

    try {
      if (shouldCancel || isTooShort) {
        await _audioRecorder.cancel();
      } else {
        final path = await _audioRecorder.stop();
        if (path != null && path.isNotEmpty) {
          await _sendOutgoingMessage(
            content: '',
            type: MessageType.voice,
            mediaPath: path,
            voiceDurationSeconds: voiceDurationSeconds,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        showAppToast(context, '录音发送失败');
      }
    } finally {
      final toastMessage = shouldCancel
          ? '已取消发送'
          : isTooShort
              ? '说话时间太短'
              : null;
      if (mounted) {
        setState(() {
          _isRecording = false;
          _voiceButtonPressed = false;
          _voiceGestureActive = false;
          _voiceHoverTarget = VoiceHoverTarget.none;
          _recordPulseTick = 0;
          _recordStartedAt = null;
          _cancelCircleCenter = null;
          _sendCircleCenter = null;
        });
        if (toastMessage != null) {
          showAppToast(context, toastMessage);
        }
      }
    }
  }

  VoiceHoverTarget _hitTestVoiceTarget(Offset globalPosition) {
    const hitRadius = 54.0;
    if (_cancelCircleCenter != null &&
        (globalPosition - _cancelCircleCenter!).distance <= hitRadius) {
      return VoiceHoverTarget.cancel;
    }
    if (_sendCircleCenter != null &&
        (globalPosition - _sendCircleCenter!).distance <= hitRadius) {
      return VoiceHoverTarget.send;
    }
    return VoiceHoverTarget.none;
  }

  void _updateVoiceHoverTarget(VoiceHoverTarget target) {
    if (!mounted) return;
    if (_voiceHoverTarget == target) return;
    HapticFeedback.selectionClick();
    setState(() {
      _voiceHoverTarget = target;
    });
  }

  void _handleVoiceLongPressDown(_) {
    if (_voiceButtonPressed || _isRecording) return;
    _dismissInputOverlays();
    setState(() {
      _voiceButtonPressed = true;
    });
  }

  Future<void> _handleVoiceLongPressStart(LongPressStartDetails details) async {
    _voiceGestureActive = true;
    await _startRecording();
  }

  Future<void> _handleVoiceLongPressEnd(LongPressEndDetails details) async {
    _voiceGestureActive = false;
    final target = _voiceHoverTarget;
    if (mounted) {
      setState(() {
        _voiceButtonPressed = false;
      });
    }
    if (target == VoiceHoverTarget.cancel) {
      await _finishRecording(forceCancel: true);
    } else {
      await _finishRecording();
    }
  }

  Future<void> _handleVoiceLongPressCancel() async {
    _voiceGestureActive = false;
    if (mounted) {
      setState(() {
        _voiceButtonPressed = false;
      });
    }
    if (_isRecording) {
      await _finishRecording(forceCancel: true);
    }
  }

  Future<void> _toggleVoicePlayback(Message message) async {
    final source = message.mediaPath;
    if (source == null || source.isEmpty) return;

    if (_playingMessageId == message.id) {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        _playingMessageId = null;
      });
      return;
    }

    try {
      await _audioPlayer.stop();
      final normalizedPath = _normalizeLocalPath(source);
      if (normalizedPath != null && File(normalizedPath).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(normalizedPath));
      } else if (source.startsWith('assets/')) {
        await _audioPlayer.play(
          AssetSource(source.replaceFirst('assets/', '')),
        );
      } else {
        await _audioPlayer.play(UrlSource(source));
      }
      if (!mounted) return;
      setState(() {
        _playingMessageId = message.id;
      });
    } catch (_) {
      if (mounted) {
        showAppToast(context, '语音播放失败');
      }
    }
  }

  String? _normalizeLocalPath(String value) {
    if (value.startsWith('file://')) {
      return Uri.parse(value).toFilePath();
    }
    if (value.startsWith('/')) {
      return value;
    }
    return null;
  }

  Future<void> _saveMessageMedia(Message message) async {
    try {
      final success = await AppRepository.instance.saveMessageMediaToGallery(
        message,
      );
      if (!mounted) return;
      if (success) {
        showAppToast(context, '已保存到系统相册');
      } else {
        showAppToast(context, '保存失败，请检查系统相册权限');
      }
    } catch (_) {
      if (!mounted) return;
      showAppToast(context, '保存失败，请检查系统相册权限');
      await openAppSettings();
    }
  }

  Future<void> _showMessageActions(
    Message message,
    Offset anchorPosition,
  ) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;
    final isMe = message.senderId == currentUser.id;
    final canRecall = AppRepository.instance.canRecallMessage(
      message: message,
      userId: currentUser.id,
    );
    final actions = <_MessageAction>[];

    switch (message.type) {
      case MessageType.text:
        if (isMe && canRecall) {
          actions.add(const _MessageAction(_MessageActionType.recall, '撤回'));
        }
        actions.add(const _MessageAction(_MessageActionType.delete, '删除'));
        actions.add(const _MessageAction(_MessageActionType.copy, '复制'));
        break;
      case MessageType.emoji:
        actions.add(const _MessageAction(_MessageActionType.delete, '删除'));
        break;
      case MessageType.image:
      case MessageType.video:
        if (isMe && canRecall) {
          actions.add(const _MessageAction(_MessageActionType.recall, '撤回'));
        }
        actions.add(const _MessageAction(_MessageActionType.delete, '删除'));
        actions.add(const _MessageAction(_MessageActionType.save, '保存'));
        break;
      case MessageType.voice:
        if (isMe && canRecall) {
          actions.add(const _MessageAction(_MessageActionType.recall, '撤回'));
        }
        actions.add(const _MessageAction(_MessageActionType.delete, '删除'));
        break;
      case MessageType.recall:
      case MessageType.system:
        actions.add(const _MessageAction(_MessageActionType.delete, '删除'));
        break;
    }

    if (message.sendStatus == MessageSendStatus.failed && isMe) {
      actions.insert(
        0,
        const _MessageAction(_MessageActionType.retry, '重发'),
      );
    }

    if (actions.isEmpty) return;

    final selectedAction = await showGeneralDialog<_MessageActionType>(
      context: context,
      barrierLabel: '消息操作',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (dialogContext, _, __) => _MessageActionMenu(
        anchorPosition: anchorPosition,
        actions: actions,
      ),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );

    if (selectedAction == null) return;

    switch (selectedAction) {
      case _MessageActionType.copy:
        await Clipboard.setData(
          ClipboardData(text: message.content),
        );
        if (mounted) {
          showAppToast(context, '已复制');
        }
        break;
      case _MessageActionType.delete:
        AppRepository.instance.deleteMessageForUser(
          messageId: message.id,
          userId: currentUser.id,
        );
        _refreshChatProviders();
        break;
      case _MessageActionType.recall:
        AppRepository.instance.recallMessage(
          messageId: message.id,
          operatorUserId: currentUser.id,
        );
        _refreshChatProviders();
        break;
      case _MessageActionType.save:
        await _saveMessageMedia(message);
        break;
      case _MessageActionType.retry:
        AppRepository.instance.retryMessage(message.id);
        _refreshChatProviders();
        break;
    }
  }

  void _openMediaMessage(Message message) {
    if (message.type == MessageType.image) {
      final source = message.mediaPath ?? message.thumbnailPath;
      if (source != null) {
        showImagePreview(context, source);
      }
      return;
    }
    if (message.type == MessageType.video && message.mediaPath != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoUrl: message.mediaPath!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final blockedUsers = ref.watch(blockedUsersProvider);
    final otherUser = AppRepository.instance.getUser(widget.otherUserId);
    final messages = ref.watch(chatMessagesProvider(widget.otherUserId));
    final isBlocked = blockedUsers.contains(widget.otherUserId);
    final isOfficialSupport =
        AppRepository.instance.isOfficialSupportUser(widget.otherUserId);
    final displayName = (otherUser.remarkName?.trim().isNotEmpty ?? false)
        ? otherUser.remarkName!
        : otherUser.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 56,
        leadingWidth: 48,
        leading: GestureDetector(
          key: const ValueKey<String>('chat.backButton'),
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: const SizedBox(
            width: 48,
            height: 56,
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  top: 17,
                  width: 20,
                  height: 20,
                  child: SizedBox(
                    key: ValueKey<String>('chat.backIconFrame'),
                    width: 20,
                    height: 20,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF222222),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Transform.translate(
          offset: const Offset(0, -1),
          child: Column(
            children: [
              Text(
                displayName,
                key: const ValueKey<String>('chat.title'),
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 22 / 16,
                ),
              ),
              Text(
                _buildOnlineStatus(otherUser.id),
                key: const ValueKey<String>('chat.subtitle'),
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 10,
                  height: 14 / 10,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        actions: isOfficialSupport
            ? const []
            : [
                PopupMenuButton<_ChatMoreAction>(
                  key: const ValueKey<String>('chat.moreMenuButton'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 56,
                  ),
                  color: const Color(0xFF4A4A4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: _handleMoreAction,
                  itemBuilder: (_) => const [
                    PopupMenuItem<_ChatMoreAction>(
                      value: _ChatMoreAction.report,
                      child: Center(
                        child: Text(
                          '举报',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    PopupMenuItem<_ChatMoreAction>(
                      value: _ChatMoreAction.block,
                      child: Center(
                        child: Text(
                          '拉黑',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                  child: const SizedBox(
                    width: 48,
                    height: 56,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 14,
                          top: 15,
                          width: 20,
                          height: 20,
                          child: SizedBox(
                            key: ValueKey<String>('chat.moreNavIconFrame'),
                            width: 20,
                            height: 20,
                            child: Icon(
                              Icons.more_horiz_rounded,
                              color: Color(0xFF222222),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
      ),
      body: Stack(
        children: [
          if (isBlocked)
            const Center(
              child: Text(
                '该用户内容已隐藏',
                style: TextStyle(color: Color(0xFF999999), fontSize: 14),
              ),
            )
          else
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _dismissInputOverlays,
                        behavior: HitTestBehavior.translucent,
                        child: ListView(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(14, 3, 14, 22),
                          children: [
                            isOfficialSupport
                                ? _buildServiceCard()
                                : _buildGalleryCard(otherUser),
                            if (messages.isNotEmpty) const SizedBox(height: 14),
                            ...messages.map((message) {
                              final isMe = currentUser != null &&
                                  message.senderId == currentUser.id;
                              final avatar = isMe
                                  ? currentUser.avatarUrl
                                  : otherUser.avatarUrl;
                              final avatarName =
                                  isMe ? currentUser.name : otherUser.name;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: _buildMessageItem(
                                  message: message,
                                  isMe: isMe,
                                  avatarUrl: avatar,
                                  avatarName: avatarName,
                                ),
                              );
                            }),
                            if (_isSimulatingReply)
                              _buildTypingIndicator(
                                otherUser.avatarUrl,
                                otherUser.name,
                              ),
                            const SizedBox(height: 76),
                          ],
                        ),
                      ),
                      if (!isOfficialSupport)
                        Positioned(
                          right: 14,
                          bottom: 39,
                          child: _buildGiftFloatingButton(
                            ref.watch(giftBalanceProvider),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildMessageInput(),
                _buildEmojiPanel(),
              ],
            ),
          if (shouldShowVoiceRecordingOverlay(_voiceUiStage))
            VoiceRecordingOverlay(
              stage: _voiceUiStage!,
              duration: _currentRecordDuration,
              pulseTick: _recordPulseTick,
              bottomInset: MediaQuery.of(context).padding.bottom,
              hoverTarget: _voiceHoverTarget,
              onCirclePositionsReady: (cancelCenter, sendCenter) {
                _cancelCircleCenter = cancelCenter;
                _sendCircleCenter = sendCenter;
              },
            ),
        ],
      ),
    );
  }

  String _buildOnlineStatus(String userId) {
    if (AppRepository.instance.isOfficialSupportUser(userId)) {
      return '官方在线';
    }
    final lastSeen = AppRepository.instance.getLastSeenAt(userId);
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return '刚刚在线';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前在线';
    if (diff.inDays < 1) return '${diff.inHours}小时前在线';
    return '${diff.inDays}天前在线';
  }

  Widget _buildServiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '官方客服',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF4D4D4D),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '可咨询：账号、支付、举报、建议；发送“转人工”可转接人工客服。',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(otherUser) {
    final images = otherUser.portfolioImages.take(3).toList();

    return SizedBox(
      key: const ValueKey<String>('chat.galleryCard'),
      width: 347,
      height: 158,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            const Positioned(
              left: 14,
              top: 14,
              width: 56,
              height: 20,
              child: Text(
                '摄影作品',
                style: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF333333),
                  height: 20 / 14,
                ),
              ),
            ),
            if (images.isEmpty)
              const Positioned(
                left: 14,
                top: 44,
                child: Text(
                  '暂无作品',
                  style: TextStyle(color: Color(0xFF999999), fontSize: 12),
                ),
              )
            else
              for (var index = 0; index < images.length; index++)
                Positioned(
                  left: 14 + index * 109,
                  top: 40,
                  width: 102,
                  height: 104,
                  child: GestureDetector(
                    onTap: () => showImagePreview(context, images[index]),
                    child: SizedBox(
                      key: ValueKey<String>('chat.galleryImage.$index'),
                      width: 102,
                      height: 104,
                      child: SmartImage(
                        source: images[index],
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem({
    required Message message,
    required bool isMe,
    required String? avatarUrl,
    required String avatarName,
  }) {
    if (message.type == MessageType.recall) {
      final currentUser = ref.read(authProvider);
      final recalledByMe =
          currentUser != null && message.recalledByUserId == currentUser.id;
      return Center(
        child: Text(
          recalledByMe ? '你撤回了一条消息' : '$avatarName撤回了一条消息',
          style: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 12,
          ),
        ),
      );
    }

    final bubble = Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GestureDetector(
        onLongPressStart: (details) =>
            _showMessageActions(message, details.globalPosition),
        onTap: () {
          if (message.type == MessageType.image ||
              message.type == MessageType.video) {
            _openMediaMessage(message);
          }
          if (message.type == MessageType.voice) {
            _toggleVoicePlayback(message);
          }
        },
        child: _buildMessageBubble(message, isMe),
      ),
    );

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe) ...[
          SmartAvatar(
            key: ValueKey<String>('chat.messageAvatar.${message.id}'),
            radius: 25,
            source: avatarUrl,
            fallbackName: avatarName,
          ),
          const SizedBox(width: 12),
        ],
        if (isMe && message.sendStatus == MessageSendStatus.failed)
          GestureDetector(
            onTap: () {
              AppRepository.instance.retryMessage(message.id);
              _refreshChatProviders();
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 8, bottom: 10),
              child: Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE15D5D),
                size: 18,
              ),
            ),
          ),
        bubble,
        if (isMe) ...[
          const SizedBox(width: 12),
          SmartAvatar(
            key: ValueKey<String>('chat.messageAvatar.${message.id}'),
            radius: 25,
            source: avatarUrl,
            fallbackName: avatarName,
          ),
        ],
      ],
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    switch (message.type) {
      case MessageType.emoji:
        return Text(
          message.content,
          style: const TextStyle(fontSize: 36),
        );
      case MessageType.image:
        final source = message.mediaPath ?? message.thumbnailPath ?? '';
        final isCameraImage = source == 'assets/images/checkin/camera.png';
        return SizedBox(
          key: ValueKey<String>('chat.imageBubble.${message.id}'),
          width: isCameraImage ? 99 : 81,
          height: isCameraImage ? 99 : 69,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SmartImage(source: source, fit: BoxFit.cover),
          ),
        );
      case MessageType.video:
        return Container(
          width: 168,
          height: 112,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2230),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (message.thumbnailPath != null &&
                  message.thumbnailPath!.isNotEmpty)
                Positioned.fill(
                  child: SmartImage(
                    source: message.thumbnailPath!,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              Container(color: Colors.black.withValues(alpha: 0.25)),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Positioned(
                bottom: 12,
                left: 14,
                child: Text(
                  '点击播放视频',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      case MessageType.voice:
        final isPlaying = _playingMessageId == message.id;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(minWidth: 110),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFFD9D2FF) : const Color(0xFFF1F2F6),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: isMe ? const Color(0xFF3D3D45) : const Color(0xFF7B7F8E),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "${message.voiceDurationSeconds ?? 0}'",
                style: const TextStyle(
                  color: Color(0xFF3D3D45),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case MessageType.text:
      case MessageType.system:
      case MessageType.recall:
        return Container(
          key: ValueKey<String>('chat.textBubble.${message.id}'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.62,
          ),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFFD9D2FF) : const Color(0xFFF1F2F6),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            key: ValueKey<String>('chat.messageText.${message.id}'),
            message.content,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        );
    }
  }

  Widget _buildTypingIndicator(String avatarUrl, String avatarName) {
    return Row(
      children: [
        SmartAvatar(
          radius: 18,
          source: avatarUrl,
          fallbackName: avatarName,
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '对方正在输入...',
            style: TextStyle(color: Color(0xFF9AA0AA), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    final sendActive = _canSend;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: const ValueKey<String>('chat.inputBar'),
          width: double.infinity,
          height: 84,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF3F3F5), width: 0.5),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  top: 10,
                  width: 292,
                  height: 40,
                  child:
                      _voiceMode ? _buildVoiceHoldButton() : _buildTextInput(),
                ),
                Positioned(
                  left: 322.56,
                  top: 10,
                  width: 38,
                  height: 38,
                  child: GestureDetector(
                    onTap: sendActive ? _sendTextMessage : null,
                    child: Opacity(
                      opacity: sendActive ? 1.0 : 0.5,
                      child: Image.asset(
                        'assets/icons/chat/send.png',
                        width: 38,
                        height: 38,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 26.25,
                  top: 54,
                  child: _buildInputIconButton(
                    'assets/icons/chat/emoji.png',
                    _toggleEmojiPanel,
                  ),
                ),
                Positioned(
                  left: 77.25,
                  top: 54,
                  child: _buildInputIconButton(
                    'assets/icons/chat/image.png',
                    _pickAndSendImage,
                  ),
                ),
                Positioned(
                  left: 128.25,
                  top: 54,
                  child: _buildInputIconButton(
                    'assets/icons/chat/video.png',
                    _pickAndSendVideo,
                  ),
                ),
                Positioned(
                  left: 179.25,
                  top: 54,
                  child: _buildMoreIconButton(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Widget _buildInputIconButton(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: ValueKey<String>('chat.inputIcon.$asset'),
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(5),
        child: Image.asset(asset),
      ),
    );
  }

  /// 礼物发送：消耗一个礼物并发消息
  Future<void> _sendGift() async {
    final success = await ref.read(giftBalanceProvider.notifier).consumeOne();
    if (!mounted) return;
    if (!success) {
      showAppToast(context, '礼物不足');
      return;
    }
    await _sendOutgoingMessage(
      content: '🎁 送出一个礼物',
      type: MessageType.image,
      mediaPath: 'assets/images/checkin/camera.png',
      thumbnailPath: 'assets/images/checkin/camera.png',
    );
  }

  /// 礼物悬浮入口（余额 > 0 时显示）
  Widget _buildGiftFloatingButton(int balance) {
    if (balance <= 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _sendGift,
      child: SizedBox(
        key: const ValueKey<String>('chat.giftButton'),
        width: 46,
        height: 47,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFD8D8D8),
                shape: BoxShape.circle,
              ),
            ),
            const Positioned(
              top: 6,
              child: Text('👏🏻', style: TextStyle(fontSize: 24)),
            ),
            Positioned(
              bottom: -1,
              child: Container(
                height: 14,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8CC8FF), Color(0xFFC987FF)],
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  '鼓掌',
                  style: TextStyle(
                    height: 1.1,
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -2,
              top: -4,
              child: Text(
                '$balance',
                style: const TextStyle(
                  color: Color(0xFF8D9298),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 「+」按钮，点击弹出通话 action sheet（08节点还原）
  Widget _buildMoreIconButton() {
    return GestureDetector(
      key: const ValueKey('chat.moreButton'),
      onTap: _showCallActionSheet,
      child: Container(
        key: const ValueKey<String>('chat.moreIcon'),
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.add,
          size: 20,
          color: Color(0xFF8D9298),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      key: const ValueKey<String>('chat.textInputBox'),
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(41),
      ),
      child: Row(
        children: [
          GestureDetector(
            key: const ValueKey('chat.voiceModeButton'),
            onTap: _toggleVoiceMode,
            child: Image.asset(
              'assets/icons/chat/voice_icon.png',
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendTextMessage(),
              onTap: () {
                if (_showEmojiPanel) {
                  setState(() {
                    _showEmojiPanel = false;
                  });
                }
              },
              decoration: const InputDecoration(
                hintText: '发送一条炫技中心把~',
                hintStyle: TextStyle(
                  color: Color(0xFF8D9298),
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceHoldButton() {
    final isActive = _voiceButtonPressed || _isRecording;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressDown: _handleVoiceLongPressDown,
      onLongPressStart: _handleVoiceLongPressStart,
      onLongPressMoveUpdate: (details) {
        if (!_isRecording) return;
        final target = _hitTestVoiceTarget(details.globalPosition);
        _updateVoiceHoverTarget(target);
      },
      onLongPressEnd: _handleVoiceLongPressEnd,
      onLongPressCancel: _handleVoiceLongPressCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _recordWillCancel
              ? const Color(0xFFFFF0F0)
              : isActive
                  ? const Color(0xFFEAEFF6)
                  : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(41),
          border: Border.all(
            color: _isRecording
                ? (_recordWillCancel
                    ? const Color(0xFFE15D5D)
                    : const Color(0xFF8B5CF6))
                : isActive
                    ? const Color(0xFFD9DFEA)
                    : Colors.transparent,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isRecording)
              GestureDetector(
                onTap: _toggleVoiceMode,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.keyboard_alt_outlined,
                    color: Color(0xFF8D92A1),
                    size: 24,
                  ),
                ),
              ),
            Icon(
              _recordWillCancel ? Icons.delete_outline : Icons.mic_none_rounded,
              color: _isRecording
                  ? (_recordWillCancel
                      ? const Color(0xFFE15D5D)
                      : const Color(0xFF8B5CF6))
                  : const Color(0xFF666666),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              buildVoiceHoldButtonText(
                isRecording: _isRecording,
                willCancel: _recordWillCancel,
                hoverSend: _voiceHoverTarget == VoiceHoverTarget.send,
              ),
              style: TextStyle(
                color: _isRecording
                    ? (_recordWillCancel
                        ? const Color(0xFFE15D5D)
                        : const Color(0xFF8B5CF6))
                    : const Color(0xFF666666),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      height: _showEmojiPanel ? 220 : 0,
      width: double.infinity,
      color: const Color(0xFFF0F2F5),
      child: _showEmojiPanel
          ? GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
              ),
              itemCount: _emojiList.length,
              itemBuilder: (context, index) {
                final emoji = _emojiList[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _sendEmojiMessage(emoji),
                  child: Center(
                    child: Text(
                      emoji.value,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                );
              },
            )
          : null,
    );
  }
}

class _EmojiOption {
  const _EmojiOption(this.value, this.label);

  final String value;
  final String label;
}

class _ReplyDraft {
  const _ReplyDraft({
    required this.content,
    this.type = MessageType.text,
    this.emojiLabel,
  });

  final String content;
  final MessageType type;
  final String? emojiLabel;
}

class _MessageAction {
  const _MessageAction(this.type, this.label);

  final _MessageActionType type;
  final String label;
}

enum _ChatMoreAction { report, block }

enum _MessageActionType { copy, delete, recall, save, retry }

Widget _buildMessageActionIcon(_MessageActionType type) {
  if (type == _MessageActionType.recall) {
    return Image.asset(
      'assets/icons/chat/recall.png',
      width: 18,
      height: 18,
      color: Colors.white,
    );
  }

  IconData iconData;
  switch (type) {
    case _MessageActionType.copy:
      iconData = Icons.content_copy_rounded;
      break;
    case _MessageActionType.delete:
      iconData = Icons.delete_outline_rounded;
      break;
    case _MessageActionType.save:
      iconData = Icons.file_download_outlined;
      break;
    case _MessageActionType.retry:
      iconData = Icons.refresh_rounded;
      break;
    default:
      iconData = Icons.help_outline_rounded;
  }

  return Icon(
    iconData,
    color: Colors.white,
    size: 17,
  );
}

class _MessageActionMenu extends StatelessWidget {
  const _MessageActionMenu({
    required this.anchorPosition,
    required this.actions,
  });

  final Offset anchorPosition;
  final List<_MessageAction> actions;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final safeTop = mediaQuery.padding.top + 8;
    final menuWidth = (actions.length * 44.0 + 12.0).clamp(56.0, 188.0);
    const menuHeight = 54.0;
    const pointerWidth = 16.0;
    const pointerHeight = 8.0;
    const sidePadding = 12.0;
    const verticalGap = 10.0;
    final desiredTop =
        anchorPosition.dy - menuHeight - pointerHeight - verticalGap;
    final showAbove = desiredTop >= safeTop;
    final left = (anchorPosition.dx - menuWidth / 2)
        .clamp(sidePadding, screenWidth - menuWidth - sidePadding)
        .toDouble();
    final top = showAbove
        ? desiredTop
        : anchorPosition.dy + verticalGap + pointerHeight;
    final pointerLeft = (anchorPosition.dx - left - pointerWidth / 2)
        .clamp(18.0, menuWidth - 18.0)
        .toDouble();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!showAbove)
                  Padding(
                    padding: EdgeInsets.only(left: pointerLeft),
                    child: const CustomPaint(
                      size: Size(pointerWidth, pointerHeight),
                      painter: _MenuPointerPainter(pointUp: true),
                    ),
                  ),
                Container(
                  height: menuHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF696969),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final action in actions)
                        SizedBox(
                          width: 44,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.of(context).pop(action.type),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildMessageActionIcon(action.type),
                                  Text(
                                    action.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (showAbove)
                  Padding(
                    padding: EdgeInsets.only(left: pointerLeft),
                    child: const CustomPaint(
                      size: Size(pointerWidth, pointerHeight),
                      painter: _MenuPointerPainter(pointUp: false),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuPointerPainter extends CustomPainter {
  const _MenuPointerPainter({required this.pointUp});

  final bool pointUp;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF696969);
    final path = Path();

    if (pointUp) {
      path
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, 0);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MenuPointerPainter oldDelegate) {
    return oldDelegate.pointUp != pointUp;
  }
}

/// 08节点：视频通话/语音通话弹出 action sheet
/// Figma 249:11513 — 白色底部 sheet，高约 181px，顶部圆角约 14px
/// 行高：约 60px，字号 18px PingFang SC，颜色 #333
/// 分割线：1px，颜色约 #E5E5E5
/// 视频通话图标 24px，语音通话图标 24px（预留待确认 Material icon 近似）
class _CallActionSheet extends StatelessWidget {
  const _CallActionSheet();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      key: const ValueKey<String>('chat.callActionSheet'),
      height: 181 + bottomPadding,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _CallActionItem(
              icon: Icons.videocam_outlined, // 预留待确认：与 Figma icon 近似
              label: '视频通话',
              result: 'video',
            ),
            const Divider(
              key: ValueKey<String>('chat.callAction.divider.video'),
              height: 1,
              thickness: 1,
              color: Color(0xFFE8E8E8),
            ),
            const _CallActionItem(
              icon: Icons.phone_outlined, // 预留待确认：与 Figma icon 近似
              label: '语音通话',
              result: 'voice',
            ),
            const Divider(
              key: ValueKey<String>('chat.callAction.divider.voice'),
              height: 1,
              thickness: 1,
              color: Color(0xFFE8E8E8),
            ),
            const Expanded(
              child: _CallCancelItem(),
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}

class _CallCancelItem extends StatelessWidget {
  const _CallCancelItem();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey<String>('chat.callAction.cancel'),
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: const SizedBox.expand(
        child: Center(
          child: Text(
            '取消',
            key: ValueKey<String>('chat.callAction.cancelText'),
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Color(0xFF333333),
              height: 25 / 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _CallActionItem extends StatelessWidget {
  const _CallActionItem({
    required this.icon,
    required this.label,
    required this.result,
  });

  final IconData icon;
  final String label;
  final String result;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey<String>('chat.callAction.$result'),
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(result),
      child: SizedBox(
        height: 60,
        child: Center(
          child: Row(
            key: ValueKey<String>('chat.callAction.content.$result'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                key: ValueKey<String>('chat.callAction.icon.$result'),
                size: 24,
                color: const Color(0xFF333333),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                key: ValueKey<String>('chat.callAction.label.$result'),
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  height: 25 / 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
