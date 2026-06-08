import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SmartAvatar extends StatelessWidget {
  const SmartAvatar({
    super.key,
    required this.radius,
    this.source,
    this.fallbackName,
    this.textStyle,
  });

  final double radius;
  final String? source;
  final String? fallbackName;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _colorFromSeed(fallbackName ?? source ?? '');
    final imageProvider = _resolveImageProvider(source);
    final initial = _buildInitial(fallbackName);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      foregroundImage: imageProvider,
      onForegroundImageError: (_, __) {},
      child: Text(
        initial,
        style: textStyle ??
            TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: radius * 0.9,
            ),
      ),
    );
  }

  ImageProvider? _resolveImageProvider(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (_isNetworkUrl(value)) {
      return CachedNetworkImageProvider(value);
    }

    if (_isAssetPath(value)) {
      return AssetImage(value);
    }

    final localPath = _normalizeLocalPath(value);
    if (localPath == null) {
      return null;
    }

    final file = File(localPath);
    if (!file.existsSync()) {
      return null;
    }
    return FileImage(file);
  }

  bool _isNetworkUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  bool _isAssetPath(String value) {
    return value.startsWith('assets/');
  }

  String? _normalizeLocalPath(String value) {
    if (value.isEmpty) return null;
    if (value.startsWith('file://')) {
      return Uri.parse(value).toFilePath();
    }
    if (value.startsWith('/')) {
      return value;
    }
    return null;
  }

  String _buildInitial(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '?';
    }
    final text = value.trim();
    final firstRune = text.runes.first;
    return String.fromCharCode(firstRune).toUpperCase();
  }

  Color _colorFromSeed(String seed) {
    const palette = <Color>[
      Color(0xFF5E81F4),
      Color(0xFF35B39A),
      Color(0xFFF19152),
      Color(0xFFB171FF),
      Color(0xFF52A6FF),
      Color(0xFFE0657A),
      Color(0xFF4A85E6),
      Color(0xFF7B8BA1),
    ];
    final index = seed.hashCode.abs() % palette.length;
    return palette[index];
  }
}
