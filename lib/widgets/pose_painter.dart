import 'package:flutter/material.dart';

class PosePainter extends CustomPainter {
  final List<Map<String, dynamic>> keypoints;

  PosePainter(this.keypoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paintCircle = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    for (var point in keypoints) {
      final x = point['x']?.toDouble() ?? 0;
      final y = point['y']?.toDouble() ?? 0;
      canvas.drawCircle(Offset(x, y), 5, paintCircle);
    }

    drawLine(canvas, paintLine, 'left_shoulder', 'left_elbow');
    drawLine(canvas, paintLine, 'left_elbow', 'left_wrist');
    drawLine(canvas, paintLine, 'right_shoulder', 'right_elbow');
    drawLine(canvas, paintLine, 'right_elbow', 'right_wrist');
    drawLine(canvas, paintLine, 'left_hip', 'right_hip');
    // Add more connections as needed
  }

  void drawLine(Canvas canvas, Paint paint, String from, String to) {
    final p1 = keypoints.firstWhere((p) => p['name'] == from, orElse: () => {});
    final p2 = keypoints.firstWhere((p) => p['name'] == to, orElse: () => {});
    if (p1.isNotEmpty && p2.isNotEmpty) {
      canvas.drawLine(
        Offset(p1['x'].toDouble(), p1['y'].toDouble()),
        Offset(p2['x'].toDouble(), p2['y'].toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}