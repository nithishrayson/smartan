class ImageMetadata {
  final String id;
  final String localPath;
  final String remoteUrl;
  final DateTime timestamp;

  ImageMetadata({
    required this.id,
    required this.localPath,
    required this.remoteUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'localPath': localPath,
    'remoteUrl': remoteUrl,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ImageMetadata.fromMap(Map<String, dynamic> map) => ImageMetadata(
    id: map['id'],
    localPath: map['localPath'],
    remoteUrl: map['remoteUrl'],
    timestamp: DateTime.parse(map['timestamp']),
  );
}