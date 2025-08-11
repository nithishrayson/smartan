import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PoseEntry {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final Map<String, dynamic> keypoints;
  final bool synced;

  PoseEntry({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.keypoints,
    required this.synced,
  });

  factory PoseEntry.fromSql(Map<String, dynamic> row) => PoseEntry(
    id: row['id'],
    imagePath: row['image_path'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp']),
    keypoints: jsonDecode(row['keypoints']),
    synced: row['synced'] == 1,
  );

  factory PoseEntry.fromFirestore(DocumentSnapshot doc) => PoseEntry(
    id: doc.id,
    imagePath: doc['imageUrl'],
    timestamp: (doc['timestamp'] as Timestamp).toDate(),
    keypoints: doc['keypoints'],
    synced: true,
  );
}