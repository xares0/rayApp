import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SmartImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final child = _buildImage();
    if (borderRadius == null) return child;
    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }

  Widget _buildImage() {
    if (_isNetworkUrl(source)) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        width: width,
        height: height,
        errorWidget: (_, __, ___) => _buildError(),
      );
    }

    if (_isAssetPath(source)) {
      return Image.asset(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _buildError(),
      );
    }

    final localPath = _normalizeLocalPath(source);
    if (localPath != null) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) => _buildError(),
        );
      }
    }

    return _buildError();
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF2F2F2),
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Color(0xFFAAAAAA)),
    );
  }

  bool _isNetworkUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  bool _isAssetPath(String value) {
    return value.startsWith('assets/') || value.startsWith('docs/');
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
}
