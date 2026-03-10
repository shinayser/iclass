import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LessonImage extends StatelessWidget {
  final String? imageUrl;
  final String? localImagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const LessonImage({
    super.key,
    this.imageUrl,
    this.localImagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final hasRemote = imageUrl != null && imageUrl!.isNotEmpty;
    final hasLocal = localImagePath != null && localImagePath!.isNotEmpty;

    if (!hasRemote && !hasLocal) {
      return _placeholder(context);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: hasRemote ? _networkImage() : _fileImage(),
    );
  }

  Widget _networkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => _loadingIndicator(),
      errorWidget: (_, __, ___) => _errorIcon(),
    );
  }

  Widget _fileImage() {
    return Image.file(
      File(localImagePath!),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _errorIcon(),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }

  Widget _loadingIndicator() {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      ),
    );
  }

  Widget _errorIcon() {
    return SizedBox(
      width: width,
      height: height,
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }
}
