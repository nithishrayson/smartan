class StoredImage {
  final int? id;
  final String localPath;
  final String? firebaseUrl;
  final DateTime timestamp;

  StoredImage({
    this.id,
    required this.localPath,
    this.firebaseUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'localPath': localPath,
    'firebaseUrl': firebaseUrl,
    'timestamp': timestamp.toIso8601String(),
  };

  factory StoredImage.fromMap(Map<String, dynamic> map) => StoredImage(
    id: map['id'],
    localPath: map['localPath'],
    firebaseUrl: map['firebaseUrl'],
    timestamp: DateTime.parse(map['timestamp']),
  );
}