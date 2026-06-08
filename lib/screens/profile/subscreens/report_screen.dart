import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../widgets/interaction_utils.dart';

enum ReportTargetType { user, post, moment }

class ReportScreen extends StatefulWidget {
  const ReportScreen({
    super.key,
    required this.targetType,
    required this.targetId,
    this.initialSelectedReason,
    this.initialImagePaths = const [],
    this.initialDescription,
    this.usePlaceholderThumbnails = false,
  });

  final ReportTargetType targetType;
  final String targetId;
  final String? initialSelectedReason;
  final List<String> initialImagePaths;
  final String? initialDescription;
  final bool usePlaceholderThumbnails;

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const _reasons = [
    '资料造假',
    '色情低俗',
    '涉政、涉毒',
    '违法违禁',
    '未成年相关',
    '涉美欺诈',
    '恶意骚扰',
    '侮辱谩骂',
    '其他',
  ];

  static const _designW = 375.0;
  static const _designH = 812.0;
  static const _maxImages = 3;
  static const _maxDesc = 1000;

  final _descController = TextEditingController();
  final _picker = ImagePicker();
  final List<File> _images = [];
  String? _selectedReason;
  bool _submitting = false;

  bool get _canSubmit =>
      _selectedReason != null && _descController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedReason = widget.initialSelectedReason;
    _images.addAll(widget.initialImagePaths.map(File.new));
    _descController.text = widget.initialDescription ?? '';
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= _maxImages) return;
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() => _images.add(File(file.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final noType = _selectedReason == null;
    final noReason = _descController.text.trim().isEmpty;
    if (noType && noReason) {
      showAppToast(context, '请选择举报类型并填写举报原因');
      return;
    }
    if (noType) {
      showAppToast(context, '请选择举报类型');
      return;
    }
    if (noReason) {
      showAppToast(context, '请填写举报原因');
      return;
    }

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _submitting = false);
    showAppToast(context, '举报成功，感谢您对平台的支持');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = (constraints.maxWidth / _designW)
              .clamp(0.0, constraints.maxHeight / _designH);

          return Align(
            alignment: Alignment.topCenter,
            child: Transform.scale(
              alignment: Alignment.topCenter,
              scale: scale,
              child: SizedBox(
                width: _designW,
                height: _designH,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Color(0xFFF7F7F7)),
                    ),
                    const Positioned(
                      left: 0,
                      top: 0,
                      width: _designW,
                      height: 300,
                      child: _TopBackground(),
                    ),
                    Positioned(
                      left: 14,
                      top: 62,
                      width: 20,
                      height: 20,
                      child: GestureDetector(
                        key: const ValueKey<String>('report.backButton'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 18,
                      top: 100,
                      width: 80,
                      height: 28,
                      child: Text(
                        key: ValueKey<String>('report.title'),
                        '举报',
                        style: TextStyle(
                          fontFamily: 'PingFang SC',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF333333),
                          height: 28 / 20,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 18,
                      top: 136,
                      width: 168,
                      height: 22,
                      child: Text(
                        key: ValueKey<String>('report.subtitle'),
                        'HI，给出你的小建议把~',
                        style: TextStyle(
                          fontFamily: 'PingFang SC',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                          height: 22 / 16,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 248,
                      top: 99,
                      width: 109.5,
                      height: 78.2,
                      child: _SmileDecoration(
                        key: ValueKey<String>('report.smileDecoration'),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 172,
                      width: 347,
                      height: 159,
                      child: _ReasonCard(
                        key: const ValueKey<String>('report.reasonCard'),
                        reasons: _reasons,
                        selectedReason: _selectedReason,
                        onSelect: (reason) =>
                            setState(() => _selectedReason = reason),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 345,
                      width: 347,
                      height: 139,
                      child: _UploadCard(
                        key: const ValueKey<String>('report.uploadCard'),
                        images: _images,
                        maxImages: _maxImages,
                        usePlaceholderThumbnails:
                            widget.usePlaceholderThumbnails,
                        onAdd: _pickImage,
                        onRemove: _removeImage,
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 498,
                      width: 347,
                      height: 190,
                      child: _DescCard(
                        key: const ValueKey<String>('report.descCard'),
                        controller: _descController,
                        maxDesc: _maxDesc,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 702,
                      width: 347,
                      height: 48,
                      child: _SubmitButton(
                        key: const ValueKey<String>('report.submitButton'),
                        canSubmit: _canSubmit,
                        submitting: _submitting,
                        onSubmit: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBackground extends StatelessWidget {
  const _TopBackground();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -94.2658,
            top: -163.59,
            width: 606.857,
            height: 463.59,
            child: SvgPicture.asset(
              'assets/images/style_top/top_bg.svg',
              fit: BoxFit.fill,
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
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFFDCA0FF), Color(0xFF7DDFFF)],
      ).createShader(const Rect.fromLTWH(0, 0, 108, 56));

    canvas.drawArc(
      const Rect.fromLTWH(8, -8, 92, 74),
      0.23,
      2.7,
      false,
      stroke,
    );

    final eyePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF4B59E), Color(0xFFDCA0FF)],
      ).createShader(const Rect.fromLTWH(0, 0, 108, 56));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 0, 15, 28),
        const Radius.circular(8),
      ),
      eyePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(72, 0, 15, 28),
        const Radius.circular(8),
      ),
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 14, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key: ValueKey<String>('report.cardTitle.$title'),
              title,
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
                height: 22 / 16,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ReasonCard extends StatelessWidget {
  const _ReasonCard({
    super.key,
    required this.reasons,
    required this.selectedReason,
    required this.onSelect,
  });

  final List<String> reasons;
  final String? selectedReason;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Stack(
        children: [
          const Positioned(
            left: 14,
            top: 10,
            height: 22,
            child: Text(
              '请选择举报类型',
              style: TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
                height: 22 / 16,
              ),
            ),
          ),
          for (var i = 0; i < reasons.length; i++)
            Positioned(
              left: _reasonChipLeft(i),
              top: _reasonChipTop(i),
              width: 93,
              height: 27,
              child: _ReasonChip(
                key: ValueKey<String>('report.reasonChip.$i'),
                index: i,
                label: reasons[i],
                selected: selectedReason == reasons[i],
                onTap: () => onSelect(reasons[i]),
              ),
            ),
        ],
      ),
    );
  }

  static double _reasonChipLeft(int index) {
    const lefts = [15.0, 134.0, 246.0];
    return lefts[index % 3];
  }

  static double _reasonChipTop(int index) {
    const tops = [40.0, 79.0, 118.0];
    return tops[index ~/ 3];
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    super.key,
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 93,
        height: 27,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF7C67D0)
                        : const Color(0xFF999999),
                    width: selected ? 1 : 0.5,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: selected
                      ? const Color(0xFF7C67D0)
                      : const Color(0xFF333333),
                  height: 20 / 14,
                ),
              ),
            ),
            if (selected)
              Positioned(
                right: 0,
                bottom: 0,
                child: Icon(
                  key: ValueKey<String>('report.reasonSelectedMark.$index'),
                  Icons.check_box_rounded,
                  size: 10,
                  color: const Color(0xFF7C67D0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    super.key,
    required this.images,
    required this.maxImages,
    required this.usePlaceholderThumbnails,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> images;
  final int maxImages;
  final bool usePlaceholderThumbnails;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      title: '请上传举报截图',
      child: SizedBox(
        width: double.infinity,
        height: 89,
        child: Stack(
          children: [
            if (images.length < maxImages)
              _AddImageCell(count: images.length, max: maxImages, onTap: onAdd),
            for (final entry in images.asMap().entries)
              Positioned(
                left: images.length >= maxImages
                    ? entry.key * 105
                    : 105 + entry.key * 99,
                top: 0,
                width: 89,
                height: 89,
                child: _ImageThumb(
                  index: entry.key,
                  file: entry.value,
                  usePlaceholder: usePlaceholderThumbnails,
                  onRemove: () => onRemove(entry.key),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddImageCell extends StatelessWidget {
  const _AddImageCell({
    required this.count,
    required this.max,
    required this.onTap,
  });

  final int count;
  final int max;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        key: const ValueKey<String>('report.addImageCell'),
        width: 89,
        height: 89,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            border: Border.all(color: const Color(0xFF999999), width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              const Positioned(
                top: 34,
                child: Icon(
                  Icons.add,
                  key: ValueKey<String>('report.addImageIcon'),
                  size: 21,
                  color: Color(0xFF999999),
                ),
              ),
              Positioned(
                left: 37,
                top: 55,
                width: 17,
                height: 14,
                child: SizedBox(
                  key: const ValueKey<String>('report.addImageCount'),
                  width: 17,
                  height: 14,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$count/$max',
                      style: const TextStyle(
                        fontFamily: 'PingFang SC',
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF999999),
                        height: 14 / 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({
    required this.index,
    required this.file,
    required this.usePlaceholder,
    required this.onRemove,
  });

  final int index;
  final File file;
  final bool usePlaceholder;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey<String>('report.imageThumb.$index'),
      width: 89,
      height: 89,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: usePlaceholder
                ? const ColoredBox(
                    color: Color(0xFFD8D8D8),
                    child: SizedBox(width: 89, height: 89),
                  )
                : Image.file(file, width: 89, height: 89, fit: BoxFit.cover),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 32,
            child: ClipRRect(
              key: ValueKey<String>('report.imageThumbMask.$index'),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2B2B2B).withValues(alpha: 0.58),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              key: ValueKey<String>('report.imageThumbDelete.$index'),
              onTap: onRemove,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x99000000),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.close, color: Colors.white, size: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescCard extends StatelessWidget {
  const _DescCard({
    super.key,
    required this.controller,
    required this.maxDesc,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int maxDesc;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      title: '请输入举报原因',
      child: Container(
        key: const ValueKey<String>('report.descInput'),
        width: 318,
        height: 136,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF999999), width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            TextField(
              controller: controller,
              maxLength: maxDesc,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontFamily: 'PingFang SC',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF333333),
              ),
              decoration: const InputDecoration(
                hintText: '请详细描述举报原因，方便我们更加精准的进行审核',
                hintStyle: TextStyle(
                  fontFamily: 'PingFang SC',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF999999),
                  height: 20 / 14,
                ),
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(9, 9, 9, 28),
              ),
              onChanged: onChanged,
            ),
            Positioned(
              right: 8,
              bottom: 10,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) {
                  return Text(
                    key: const ValueKey<String>('report.descCount'),
                    '${value.text.length}/$maxDesc',
                    style: const TextStyle(
                      fontFamily: 'PingFang SC',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF999999),
                      height: 14 / 10,
                    ),
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

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    super.key,
    required this.canSubmit,
    required this.submitting,
    required this.onSubmit,
  });

  final bool canSubmit;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: submitting ? null : onSubmit,
      child: DecoratedBox(
        key: const ValueKey<String>('report.submitBackground'),
        decoration: BoxDecoration(
          color: canSubmit ? null : const Color(0xFF999999),
          gradient: canSubmit
              ? const LinearGradient(
                  colors: [Color(0xFFDA99FF), Color(0xFFA575FF)],
                )
              : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  key: ValueKey<String>('report.submitText'),
                  '提交',
                  style: TextStyle(
                    fontFamily: 'PingFang SC',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 22 / 16,
                  ),
                ),
        ),
      ),
    );
  }
}
