import 'dart:io';
import 'package:flutter/material.dart';

class DenMasonryGrid extends StatelessWidget {
  final List<String> photos;
  final Function(int index)? onPhotoTap;

  const DenMasonryGrid({
    super.key,
    required this.photos,
    this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: const Text('No photos yet', style: TextStyle(color: Colors.black38, fontSize: 13)),
      );
    }

    final leftColumn = <int>[];
    final rightColumn = <int>[];

    for (int i = 0; i < photos.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(i);
      } else {
        rightColumn.add(i);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          child: Column(
            children: leftColumn.map((i) => _buildItem(context, i, photos[i])).toList(),
          ),
        ),
        const SizedBox(width: 8),

        // Right Column
        Expanded(
          child: Column(
            children: rightColumn.map((i) => _buildItem(context, i, photos[i])).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, int index, String photoUrl) {
    // Dynamic staggered heights for natural masonry feel
    final heightRatio = (index % 3 == 0)
        ? 1.35
        : (index % 2 == 0)
            ? 1.15
            : 0.95;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () => onPhotoTap?.call(index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1.0 / heightRatio,
            child: _buildImage(photoUrl),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image, color: Colors.black26)),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image, color: Colors.black26)),
      );
    }
  }
}
