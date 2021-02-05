import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  double endX, endY = 0, middleX, middleY;
  bool right;
  double distance;

  CurvePainter({this.distance, this.right});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    var path = Path();
    endX = distance * 150;
    middleX = endX / 2;
    middleY =
        (right ? -100 : (100 - 100)) - (distance - 1) * 50; // 100 - diff*2
    path.quadraticBezierTo(middleX, middleY, endX, endY);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
