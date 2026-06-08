import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/feed_provider.dart';
import '../../../widgets/smart_image.dart';

class GalleryTab extends ConsumerWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can just reuse posts for gallery
    final posts = ref.watch(homeFeedProvider);
    final allImages = posts.expand((p) => p.images).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        return SmartImage(
          source: allImages[index],
          fit: BoxFit.cover,
        );
      },
    );
  }
}
