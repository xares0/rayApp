import 'package:flutter/material.dart';

import 'smart_image.dart';

const Color _kDialogPurple = Color(0xFF7C67D0);
const Color _kDialogBarrier = Color(0x8004010A);
const LinearGradient _kDialogConfirmGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xFFDA99FF),
    Color(0xFFA575FF),
  ],
);
const String _kFollowBellAsset = 'assets/images/dialogs/follow_bell_figma.png';
const String _kDeleteTrashAsset =
    'assets/images/dialogs/delete_trash_figma_clean.png';

void showAppToast(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

Future<bool> showBlockConfirmDialog(BuildContext context) async {
  return showFigmaBellConfirmDialog(
    context,
    title: '温馨提示',
    message: '确定要拉黑对方？',
  );
}

Future<bool> showFigmaBellConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelText = '取消',
  String confirmText = '确认',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: _kDialogBarrier,
    builder: (context) {
      return _TransparentDialog(
        child: _FigmaBellConfirmDialog(
          title: title,
          message: message,
          cancelText: cancelText,
          confirmText: confirmText,
        ),
      );
    },
  );
  return result ?? false;
}

Future<bool> showFigmaDeletePostDialog(BuildContext context) async {
  return showFigmaTrashConfirmDialog(
    context,
    title: '删除投稿',
    message: '投稿删除后不可恢复，\n是否删除投稿？',
  );
}

/// 垃圾桶图标 + 标题 + 文案 + 取消/确认胶囊钮的确认弹窗（Figma「动态清除」同款）。
Future<bool> showFigmaTrashConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelText = '取消',
  String confirmText = '确认',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: _kDialogBarrier,
    builder: (context) {
      return _TransparentDialog(
        child: _FigmaTrashConfirmDialog(
          title: title,
          message: message,
          cancelText: cancelText,
          confirmText: confirmText,
        ),
      );
    },
  );
  return result ?? false;
}

Future<bool> showFigmaSplitConfirmDialog(
  BuildContext context, {
  required String message,
  String? title,
  String cancelText = '取消',
  String confirmText = '确定',
  Color cancelColor = _kDialogPurple,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: _kDialogBarrier,
    builder: (context) {
      return _TransparentDialog(
        child: _FigmaSplitConfirmDialog(
          message: message,
          title: title,
          cancelText: cancelText,
          confirmText: confirmText,
          cancelColor: cancelColor,
        ),
      );
    },
  );
  return result ?? false;
}

/// 标题 + 居中输入框（带清除钮）+ 取消/确认分栏钮的输入弹窗（Figma「设置备注」同款）。
/// 返回输入文本；取消 / 点击蒙层返回 null。
Future<String?> showFigmaInputDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String hintText = '',
  int maxLength = 20,
  String cancelText = '取消',
  String confirmText = '确认',
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    barrierColor: _kDialogBarrier,
    builder: (context) {
      return _TransparentDialog(
        child: _FigmaInputDialog(
          title: title,
          initialValue: initialValue,
          hintText: hintText,
          maxLength: maxLength,
          cancelText: cancelText,
          confirmText: confirmText,
        ),
      );
    },
  );
}

Future<void> showImagePreview(BuildContext context, String imageUrl) async {
  if (imageUrl.isEmpty) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _ImagePreviewScreen(imageUrl: imageUrl),
      fullscreenDialog: true,
    ),
  );
}

class _TransparentDialog extends StatelessWidget {
  const _TransparentDialog({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      elevation: 0,
      child: child,
    );
  }
}

class _FigmaBellConfirmDialog extends StatelessWidget {
  const _FigmaBellConfirmDialog({
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
  });

  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 164,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: _DialogFigmaCard(
              borderRadius: 18,
              child: Stack(
                children: [
                  Positioned(
                    left: -18,
                    top: -22,
                    child: _DialogBlurCircle(
                      size: 104,
                      color: const Color(0xFFDCCBFF).withValues(alpha: 0.22),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 18,
                    child: _DialogBlurCircle(
                      size: 74,
                      color: const Color(0xFFE6F0FF).withValues(alpha: 0.18),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 10,
                    child: _DialogSparkle(
                      size: 16,
                      color: const Color(0xFFEACBFF).withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 167,
            top: -18,
            width: 113,
            height: 119,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: 0.47,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE9D9FF).withValues(alpha: 0.68),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFE8DBFF).withValues(alpha: 0.92),
                            blurRadius: 28,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 1.08,
                      child: Image.asset(
                        _kFollowBellAsset,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 22,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 58,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
                height: 1.3,
              ),
            ),
          ),
          Positioned(
            left: 19,
            top: 106,
            width: 110,
            height: 34,
            child: _DialogOutlinedPillButton(
              label: cancelText,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
          Positioned(
            left: 152,
            top: 106,
            width: 110,
            height: 34,
            child: _DialogGradientPillButton(
              label: confirmText,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _FigmaTrashConfirmDialog extends StatelessWidget {
  const _FigmaTrashConfirmDialog({
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
  });

  final String title;
  final String message;
  final String cancelText;
  final String confirmText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 218,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: _DialogFigmaCard(
              borderRadius: 20,
              child: Stack(
                children: [
                  Positioned(
                    left: -20,
                    top: -26,
                    child: _DialogBlurCircle(
                      size: 108,
                      color: const Color(0xFFDCCBFF).withValues(alpha: 0.2),
                    ),
                  ),
                  Positioned(
                    right: 24,
                    top: 28,
                    child: _DialogSparkle(
                      size: 14,
                      color: const Color(0xFFEFDFFF).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -27,
            left: 103,
            width: 81,
            height: 80,
            child: IgnorePointer(
              child: Image.asset(
                _kDeleteTrashAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 116,
            child: IgnorePointer(
              child: Container(
                width: 47,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFFD9C9FF).withValues(alpha: 0.65),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD9C9FF).withValues(alpha: 0.55),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 53,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 89,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
                height: 1.3,
              ),
            ),
          ),
          Positioned(
            left: 19,
            top: 159,
            width: 110,
            height: 34,
            child: _DialogOutlinedPillButton(
              label: cancelText,
              onTap: () => Navigator.of(context).pop(false),
            ),
          ),
          Positioned(
            left: 152,
            top: 159,
            width: 110,
            height: 34,
            child: _DialogGradientPillButton(
              label: confirmText,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogFigmaCard extends StatelessWidget {
  const _DialogFigmaCard({
    required this.borderRadius,
    required this.child,
  });

  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF6EDFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFEFF),
          ],
          stops: [0, 0.52, 1],
        ),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}

class _DialogBlurCircle extends StatelessWidget {
  const _DialogBlurCircle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.52,
            spreadRadius: size * 0.06,
          ),
        ],
      ),
    );
  }
}

class _DialogSparkle extends StatelessWidget {
  const _DialogSparkle({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DialogSparklePainter(color),
    );
  }
}

class _DialogSparklePainter extends CustomPainter {
  _DialogSparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.35,
        size.width,
        size.height / 2,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.65,
        size.width / 2,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.65,
        0,
        size.height / 2,
      )
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.35,
        size.width / 2,
        0,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DialogSparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _FigmaSplitConfirmDialog extends StatelessWidget {
  const _FigmaSplitConfirmDialog({
    required this.message,
    required this.cancelText,
    required this.confirmText,
    this.title,
    this.cancelColor = _kDialogPurple,
  });

  final String message;
  final String cancelText;
  final String confirmText;
  final String? title;
  final Color cancelColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0EBFF),
              Colors.white,
            ],
            stops: [0, 0.25],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0.5,
              thickness: 0.5,
              color: Color(0xFFE5E5E5),
            ),
            SizedBox(
              height: 49.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                      onTap: () => Navigator.of(context).pop(false),
                      child: Center(
                        child: Text(
                          cancelText,
                          style: TextStyle(
                            color: cancelColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 0.5,
                    thickness: 0.5,
                    color: Color(0xFFE5E5E5),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                      onTap: () => Navigator.of(context).pop(true),
                      child: Center(
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: _kDialogPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 「设置备注」输入弹窗：标题 + 灰底输入框（带清除钮）+ 取消/确认分栏钮。
class _FigmaInputDialog extends StatefulWidget {
  const _FigmaInputDialog({
    required this.title,
    required this.initialValue,
    required this.hintText,
    required this.maxLength,
    required this.cancelText,
    required this.confirmText,
  });

  final String title;
  final String initialValue;
  final String hintText;
  final int maxLength;
  final String cancelText;
  final String confirmText;

  @override
  State<_FigmaInputDialog> createState() => _FigmaInputDialogState();
}

class _FigmaInputDialogState extends State<_FigmaInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0EBFF),
              Colors.white,
            ],
            stops: [0, 0.25],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 22,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 39,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            maxLength: widget.maxLength,
                            style: const TextStyle(
                                color: Color(0xFF333333), fontSize: 16),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              counterText: '',
                              hintText: widget.hintText,
                              hintStyle: const TextStyle(
                                  color: Color(0xFFBBBBBB), fontSize: 16),
                            ),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          GestureDetector(
                            onTap: _controller.clear,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.cancel,
                                  size: 16, color: Color(0xFFBFBFBF)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0.5,
              thickness: 0.5,
              color: Color(0xFFE5E5E5),
            ),
            SizedBox(
              height: 49.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Text(
                          widget.cancelText,
                          style: const TextStyle(
                            color: _kDialogPurple,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 0.5,
                    thickness: 0.5,
                    color: Color(0xFFE5E5E5),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                      onTap: () => Navigator.of(context).pop(_controller.text),
                      child: Center(
                        child: Text(
                          widget.confirmText,
                          style: const TextStyle(
                            color: _kDialogPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogGradientPillButton extends StatelessWidget {
  const _DialogGradientPillButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(54),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(54),
            gradient: _kDialogConfirmGradient,
          ),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 22 / 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogOutlinedPillButton extends StatelessWidget {
  const _DialogOutlinedPillButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(67),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(67),
            border: Border.all(
              color: _kDialogPurple,
            ),
          ),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: _kDialogPurple,
                  fontSize: 12,
                  height: 22 / 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreviewScreen extends StatelessWidget {
  const _ImagePreviewScreen({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: SmartImage(
              source: imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
