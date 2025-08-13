import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smartan/widgets/pose_painter.dart';

class ImageDetailScreen extends StatelessWidget {
  final String imagePath; // Local path or network URL
  final DateTime timestamp;
  final bool isSynced;
  final List<Map<String, dynamic>> keypoints;

  const ImageDetailScreen({
    super.key,
    required this.imagePath,
    required this.timestamp,
    required this.isSynced,
    required this.keypoints,
  });

  bool get isNetwork => imagePath.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final imageWidget = isNetwork
        ? Image.network(imagePath, fit: BoxFit.cover)
        : Image.file(File(imagePath), fit: BoxFit.cover);

    return Scaffold(
      appBar: AppBar(title: const Text('Pose Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: imageWidget),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PosePainter(keypoints),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Captured on: ${timestamp.toLocal()}'),
            Text('Sync Status: ${isSynced ? "Synced" : "Pending"}'),
          ],
        ),
      ),
    );
  }
}