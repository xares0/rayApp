import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widgets/interaction_utils.dart';

// 反馈类型列表（Figma: 行1:ui/界面、功能建议、操作体验；行2:闪退/卡顿、单纯吐槽、侵权；行3:其他）
const List<String> _kFeedbackTypes = [
  'ui/界面',
  '功能建议',
  '操作体验',
  '闪退/卡顿',
  '单纯吐槽',
  '侵权',
  '其他',
];

// 主题渐变色（提交按钮激活态：Figma node 249:12013 from-[#da99ff] to-[#a575ff]）
const LinearGradient _kSubmitGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFDA99FF), Color(0xFFA575FF)],
);

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({
    super.key,
    this.initialSelectedTypes,
    this.initialImages = const [],
    this.initialContent = '',
    this.usePlaceholderThumbnails = false,
  });

  final Set<int>? initialSelectedTypes;
  final List<File> initialImages;
  final String initialContent;
  final bool usePlaceholderThumbnails;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late final Set<int> _selectedTypes;
  late final List<File> _images;
  late final TextEditingController _contentController;
  final ImagePicker _picker = ImagePicker();
  static const int _maxImages = 3;
  static const int _maxChars = 1000;

  bool get _canSubmit =>
      _selectedTypes.isNotEmpty &&
      (_images.isNotEmpty || _contentController.text.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _selectedTypes = {...?widget.initialSelectedTypes};
    _images = [...widget.initialImages];
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= _maxImages) {
      showAppToast(context, '最多上传 $_maxImages 张截图');
      return;
    }
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _images.add(File(file.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _toggleType(int index) {
    setState(() {
      if (_selectedTypes.contains(index)) {
        _selectedTypes.remove(index);
      } else {
        _selectedTypes.add(index);
      }
    });
  }

  void _submit() {
    if (!_canSubmit) return;
    showAppToast(context, '提交成功，感谢您的反馈！');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 174,
            child: _FeedbackTopBackground(),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _FeedbackNavBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _HeaderSection(),
                        const SizedBox(height: 0),
                        _SectionCard(
                          contentKey:
                              const ValueKey<String>('feedback.typeCard'),
                          height: 159,
                          title: '请选择反馈类型',
                          child: _TypeChipsGrid(
                            selected: _selectedTypes,
                            onToggle: _toggleType,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          contentKey:
                              const ValueKey<String>('feedback.uploadCard'),
                          height: 139,
                          bottomPadding: 10,
                          title: '请上传反馈截图',
                          child: _UploadArea(
                            images: _images,
                            maxImages: _maxImages,
                            usePlaceholderThumbnails:
                                widget.usePlaceholderThumbnails,
                            onAdd: _pickImage,
                            onRemove: _removeImage,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          contentKey:
                              const ValueKey<String>('feedback.detailCard'),
                          height: 190,
                          title: '请输入反馈详情',
                          child: _ContentInput(
                            controller: _contentController,
                            maxChars: _maxChars,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _SubmitButton(
                  canSubmit: _canSubmit,
                  onSubmit: _submit,
                ),
                SizedBox(height: _canSubmit ? 56 : 62),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackTopBackground extends StatelessWidget {
  const _FeedbackTopBackground();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _FeedbackTopBackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class _FeedbackTopBackgroundPainter extends CustomPainter {
  const _FeedbackTopBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF7C9),
          Color(0xFFFCFCFC),
          Color(0xFFF7F7F7),
        ],
        stops: [0, 0.58, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, basePaint);

    final yellow = Paint()
      ..color = const Color(0xFFFFF1B3).withValues(alpha: 0.86)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 46);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(76, -8),
        width: 250,
        height: 180,
      ),
      yellow,
    );

    final pink = Paint()
      ..color = const Color(0xFFFAB3FF).withValues(alpha: 0.74)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 56);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width - 22, 4),
        width: 230,
        height: 160,
      ),
      pink,
    );

    final veil = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          const Color(0xFFF7F7F7).withValues(alpha: 0.92),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, veil);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeedbackNavBar extends StatelessWidget {
  const _FeedbackNavBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
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
                    key: ValueKey<String>('feedback.backFrame'),
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
        ],
      ),
    );
  }
}

// ─── 顶部标题区 ──────────────────────────────────────────────────────────────
// Figma: 标题 "意见与反馈" PingFang SC Heavy 20px #333, top:100
//        副标题 "HI，给出你的小建议把~" PingFang SC Medium 16px #666, top:136
//        右上角笑脸装饰图（预留待确认 — 使用 SentimentSatisfied 近似）
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 18,
            top: 12,
            width: 120,
            height: 28,
            child: SizedBox(
              key: ValueKey<String>('feedback.headerTitle'),
              width: 120,
              height: 28,
              child: Text(
                '意见与反馈',
                style: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Color(0xFF333333),
                  height: 28 / 20,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 48,
            width: 210,
            height: 22,
            child: SizedBox(
              key: ValueKey<String>('feedback.headerSubtitle'),
              width: 210,
              height: 22,
              child: Text(
                'HI，给出你的小建议把~',
                style: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 22 / 16,
                ),
              ),
            ),
          ),
          Positioned(
            left: 248,
            top: 11,
            width: 109.5,
            height: 78.2,
            child: _SmileDecoration(
              key: ValueKey<String>('feedback.smileDecoration'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmileDecoration extends StatelessWidget {
  const _SmileDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SmilePainter());
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    stroke.color = const Color(0xFFDFA6FF);
    canvas.drawArc(
      Rect.fromLTWH(8, 10, size.width - 16, size.height - 20),
      0.18,
      2.78,
      false,
      stroke,
    );

    final dot = Paint()..color = const Color(0xFFFFB28A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(22, 0, 9, 28),
        const Radius.circular(5),
      ),
      dot,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(56, 0, 9, 28),
        const Radius.circular(5),
      ),
      dot,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── 通用卡片容器 ─────────────────────────────────────────────────────────────
// Figma: bg-white rounded-[13px] left-[14px] w-[347px]
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Key? contentKey;
  final double? height;
  final double bottomPadding;

  const _SectionCard({
    this.contentKey,
    this.height,
    this.bottomPadding = 14,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.fromLTRB(15, 10, 15, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF333333),
              height: 22 / 16,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        key: contentKey,
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: content,
      ),
    );
  }
}

// ─── 反馈类型 Chips ────────────────────────────────────────────────────────────
// Figma: 每个 chip w-[93px] h-[27px] rounded-[5px] border-[#999] 0.5px
//        文字 14px Regular #333
//        选中态：紫色渐变边框 + 紫色文字（Figma node 249:11980 Union 为选中态）
class _TypeChipsGrid extends StatelessWidget {
  final Set<int> selected;
  final ValueChanged<int> onToggle;

  const _TypeChipsGrid({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    const positions = <Offset>[
      Offset(0, 0),
      Offset(119, 0),
      Offset(231, 0),
      Offset(0, 39),
      Offset(119, 39),
      Offset(231, 39),
      Offset(0, 78),
    ];

    return SizedBox(
      height: 105,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(_kFeedbackTypes.length, (i) {
          final isSelected = selected.contains(i);
          return Positioned(
            left: positions[i].dx,
            top: positions[i].dy,
            width: 93,
            height: 27,
            child: GestureDetector(
              onTap: () => onToggle(i),
              child: _TypeChip(
                key: ValueKey<String>('feedback.typeChip.$i'),
                chipIndex: i,
                label: _kFeedbackTypes[i],
                isSelected: isSelected,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final int chipIndex;
  final String label;
  final bool isSelected;

  const _TypeChip({
    super.key,
    required this.chipIndex,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 未选中：border #999 0.5px，文字 #333
    // 选中：border 渐变紫色（用 Stack + Container 实现），文字紫色 #7C67D0
    return SizedBox(
      width: 93,
      height: 27,
      child: isSelected
          ? _GradientBorderChip(index: chipIndex, label: label)
          : Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF999999),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF333333),
                ),
              ),
            ),
    );
  }
}

// 选中 chip：渐变边框效果（Figma 中 Union 节点暗示紫色选中态）
// 【预留待确认】选中态颜色取自 Figma 7C67D0 紫色；边框渐变取主题渐变
class _GradientBorderChip extends StatelessWidget {
  final int index;
  final String label;

  const _GradientBorderChip({
    required this.index,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>('feedback.typeChipSelectedBorder.$index'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.all(0.8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.2),
              ),
            ),
          ),
          Center(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF7C67D0),
              ),
            ),
          ),
          const Positioned(
            right: -0.8,
            bottom: -0.8,
            width: 12,
            height: 12,
            child: _SelectedChipCorner(),
          ),
        ],
      ),
    );
  }
}

class _SelectedChipCorner extends StatelessWidget {
  const _SelectedChipCorner();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _SelectedChipCornerPainter());
  }
}

class _SelectedChipCornerPainter extends CustomPainter {
  const _SelectedChipCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7DDFFF), Color(0xFFDCA0FF)],
      ).createShader(Offset.zero & size);
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, fill);

    final check = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;
    final checkPath = Path()
      ..moveTo(size.width - 8, size.height - 4.5)
      ..lineTo(size.width - 5.6, size.height - 2.5)
      ..lineTo(size.width - 2.7, size.height - 7);
    canvas.drawPath(checkPath, check);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── 上传截图区 ───────────────────────────────────────────────────────────────
// Figma: 添加格 bg-[#f6f6f6] border border-[#999] size-[89px] rounded-[8px]
//        加号图标 21×21px 居中
//        计数 0/3，10px #999，居中于格下方
//        已传图：89×89px rounded-[8px]，右上角删除叉 16×16px
class _UploadArea extends StatelessWidget {
  final List<File> images;
  final int maxImages;
  final bool usePlaceholderThumbnails;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _UploadArea({
    required this.images,
    required this.maxImages,
    required this.usePlaceholderThumbnails,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.length < maxImages)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              key: const ValueKey<String>('feedback.addImageBox'),
              width: 89,
              height: 89,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                border: Border.all(
                  color: const Color(0xFF999999),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  const Positioned(
                    top: 31,
                    child: Icon(
                      Icons.add,
                      size: 21,
                      color: Color(0xFF999999),
                    ),
                  ),
                  Positioned(
                    top: 54,
                    child: Text(
                      '${images.length}/$maxImages',
                      style: const TextStyle(
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (images.length < maxImages && images.isNotEmpty)
          const SizedBox(width: 16),
        ...images.asMap().entries.map((entry) {
          final isLast = entry.key == images.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 16),
            child: _ThumbnailItem(
              index: entry.key,
              file: entry.value,
              usePlaceholder: usePlaceholderThumbnails,
              onRemove: () => onRemove(entry.key),
            ),
          );
        }),
      ],
    );
  }
}

// 已上传缩略图：89×89px + 右上角 16px 删除图标
class _ThumbnailItem extends StatelessWidget {
  final int index;
  final File file;
  final bool usePlaceholder;
  final VoidCallback onRemove;

  const _ThumbnailItem({
    required this.index,
    required this.file,
    required this.usePlaceholder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey<String>('feedback.thumbnail.$index'),
      width: 89,
      height: 89,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: usePlaceholder
                ? const ColoredBox(color: Color(0xFFB7D8FF))
                : Image.file(
                    file,
                    width: 89,
                    height: 89,
                    fit: BoxFit.cover,
                  ),
          ),
          // 右上角半透明渐变遮罩（Figma: bg-gradient-to-b from-[#2b2b2b]）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Container(
                key: ValueKey<String>('feedback.thumbnailMask.$index'),
                height: 32,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x992B2B2B), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          // 删除叉（Figma: right:[205px-134px=71px->16px from right] top:[387-385=2px]）
          // 即右上角 16×16px
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                key: ValueKey<String>('feedback.thumbnailDelete.$index'),
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0x99000000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 10,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 反馈详情输入框 ────────────────────────────────────────────────────────────
// Figma: border-[#999] border-[0.5px] h-[136px] w-[318px] rounded-[8px]
//        placeholder 14px #999
//        右下角计数 0/1000, 10px #999
class _ContentInput extends StatelessWidget {
  final TextEditingController controller;
  final int maxChars;
  final ValueChanged<String> onChanged;

  const _ContentInput({
    required this.controller,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('feedback.detailInput'),
      // Figma: w-[318px] h-[136px]，卡片内左右 padding 各 15px，318=347-29
      width: double.infinity,
      height: 136,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF999999),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: null,
            expands: true,
            maxLength: maxChars,
            buildCounter: (_,
                    {required currentLength, required isFocused, maxLength}) =>
                null,
            style: const TextStyle(
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xFF333333),
            ),
            decoration: const InputDecoration(
              hintText: '请详细反馈内容，您的反馈会成为我们不断优化的动力',
              hintStyle: TextStyle(
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF999999),
              ),
              contentPadding: EdgeInsets.fromLTRB(10, 9, 10, 28),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          // 右下角字数统计（Figma: 0/1000 10px #999 右对齐）
          Positioned(
            bottom: 6,
            right: 8,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                return Text(
                  '${value.text.length}/$maxChars',
                  style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    color: Color(0xFF999999),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 提交按钮 ──────────────────────────────────────────────────────────────────
// Figma 空态: bg-[#999] h-[48px] rounded-[24px] w-[347px]
// Figma 激活态: bg-gradient-to-r from-[#da99ff] to-[#a575ff]
// 文字: PingFang SC Heavy 16px 白色 leading-[22px]
class _SubmitButton extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.canSubmit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: canSubmit ? onSubmit : null,
        child: AnimatedContainer(
          key: const ValueKey<String>('feedback.submitButton'),
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: canSubmit ? _kSubmitGradient : null,
            color: canSubmit ? null : const Color(0xFF999999),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: const Text(
            '提交',
            style: TextStyle(
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Colors.white,
              height: 22 / 16,
            ),
          ),
        ),
      ),
    );
  }
}
