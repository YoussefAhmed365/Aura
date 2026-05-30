import 'dart:math';

import 'package:flutter/material.dart';

class CircularCustomKnob extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final double size;
  final ValueChanged<double> onChanged;

  const CircularCustomKnob({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.size = 120, // تحديد الحجم لضمان دقة حساب المركز
    required this.onChanged,
  });

  @override
  State<CircularCustomKnob> createState() => _CircularCustomKnobState();
}

class _CircularCustomKnobState extends State<CircularCustomKnob> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  void _handleCircularInteraction(Offset localPosition) {
    // 1. تحديد مركز الزر
    final center = Offset(widget.size / 2, widget.size / 2);

    // 2. حساب المسافة بين لمسة المستخدم والمركز
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    // 3. حساب الزاوية بالراديان وتحويلها لنطاق موجب (من 0 إلى 2π)
    double touchAngle = atan2(dy, dx);
    if (touchAngle < 0) {
      touchAngle += 2 * pi;
    }

    // زاوية البداية ونطاق الدوران (يجب أن تتطابق مع قيم الـ Painter)
    double startAngle = 135 * (pi / 180);
    double sweepAngle = 270 * (pi / 180);

    // 4. جعل الزاوية نسبية مقارنة بنقطة البداية
    double relativeAngle = touchAngle - startAngle;
    if (relativeAngle < 0) {
      relativeAngle += 2 * pi;
    }

    // 5. حساب النسبة المئوية للقيمة مع معالجة المنطقة الميتة
    double percentage;
    if (relativeAngle <= sweepAngle) {
      // داخل نطاق المسار النشط
      percentage = relativeAngle / sweepAngle;
    } else {
      // داخل المنطقة الميتة (الفراغ بالأسفل)
      // التقريب لأقرب حافة (إما 100% أو 0%)
      if (relativeAngle < sweepAngle + (2 * pi - sweepAngle) / 2) {
        percentage = 1.0;
      } else {
        percentage = 0.0;
      }
    }

    // 6. تطبيق القيمة الجديدة
    double newValue = widget.min + (percentage * (widget.max - widget.min));
    setState(() {
      _currentValue = newValue;
    });
    widget.onChanged(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    double range = widget.max - widget.min;
    double normalizedValue = (_currentValue - widget.min) / range;

    double startAngle = 135 * (pi / 180);
    double sweepAngle = 270 * (pi / 180);
    double currentAngle = startAngle + (normalizedValue * sweepAngle);

    return GestureDetector(
      // استخدام onPanStart و onPanUpdate لالتقاط السحب بدقة
      onPanStart: (details) => _handleCircularInteraction(details.localPosition),
      onPanUpdate: (details) => _handleCircularInteraction(details.localPosition),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: KnobPainter(angle: currentAngle, normalizedValue: normalizedValue, startAngle: startAngle, sweepAngle: sweepAngle, trackColor: Theme.of(context).colorScheme.surfaceContainer, activeColor: Theme.of(context).colorScheme.primary, knobColor: Theme.of(context).colorScheme.surfaceContainerLow),
      ),
    );
  }
}

class KnobPainter extends CustomPainter {
  final double angle;
  final double normalizedValue;
  final double startAngle;
  final double sweepAngle;
  final Color trackColor;
  final Color activeColor;
  final Color knobColor;

  KnobPainter({required this.angle, required this.normalizedValue, required this.startAngle, required this.sweepAngle, required this.trackColor, required this.activeColor, required this.knobColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, trackPaint);

    final activeTrackPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle * normalizedValue, false, activeTrackPaint);

    final basePaint = Paint()
      ..color = knobColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.75, basePaint);

    final indicatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final indicatorLength = radius * 0.45;
    final endX = center.dx + indicatorLength * cos(angle);
    final endY = center.dy + indicatorLength * sin(angle);

    canvas.drawLine(center, Offset(endX, endY), indicatorPaint);
  }

  bool sheetRepaint(covariant KnobPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }

  @override
  bool shouldRepaint(covariant KnobPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
