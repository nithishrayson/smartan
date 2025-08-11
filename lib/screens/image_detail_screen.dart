import 'package:flutter/material.dart';
import 'dart:io';

class ImageDetailScreen extends StatelessWidget {
  final String imagePath;
  final DateTime timestamp;
  final bool isSynced;

  const ImageDetailScreen({
    super.key,
    required this.imagePath,
    required this.timestamp,
    required this.isSynced,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.file(File(imagePath), height: 300, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text('Saved on: ${timestamp.toLocal()}'),
            Text('Sync Status: ${isSynced ? "Synced" : "Pending"}'),
          ],
        ),
      ),
    );
  }
}