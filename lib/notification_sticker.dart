import 'dart:math' as math;
import 'package:flutter/material.dart';

enum NoticeKind {
  reminder(
    'Nhắc thanh toán',
    'Ví ơi, dậy thôiii',
    Color(0xffffd875),
    Color(0xfffff3d6),
  ),
  received(
    'Đã nhận tiền',
    'Ting ting, vui liền',
    Color(0xffbce8cf),
    Color(0xffe7f5ec),
  ),
  fund('Nộp quỹ', 'Heo được ăn ngon', Color(0xffffb9cc), Color(0xffffeaf0)),
  period(
    'Chốt kỳ',
    'Chốt sổ, thở cái đã',
    Color(0xffc9befa),
    Color(0xffeeeafd),
  ),
  pending('Chờ xác nhận', 'Đợi xíu nha…', Color(0xffb4ddf4), Color(0xffe9f4fd)),
  feedback(
    'Kiểm tra bill',
    'Ủa, bill hơi sus?',
    Color(0xffffc6a4),
    Color(0xffffeee3),
  ),
  message(
    'Thông báo',
    'Chung nhắn bạn nè',
    Color(0xffc9befa),
    Color(0xffeeeafd),
  );

  final String label, title;
  final Color color, background;
  const NoticeKind(this.label, this.title, this.color, this.background);

  static NoticeKind fromKey(String key) => switch (key.split(':').first) {
    'reminder' => reminder,
    'period' => period,
    _ => message,
  };
}

/// Code-drawn vectors stay crisp on mobile; no font emoji or remote assets.
class NotificationSticker extends StatelessWidget {
  final NoticeKind kind;
  final double size;
  final bool decorative;
  const NotificationSticker({
    super.key,
    required this.kind,
    this.size = 72,
    this.decorative = false,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    label: decorative ? null : kind.label,
    excludeSemantics: decorative,
    image: !decorative,
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _StickerPainter(kind)),
    ),
  );
}

class _StickerPainter extends CustomPainter {
  final NoticeKind kind;
  const _StickerPainter(this.kind);
  static const ink = Color(0xff332c51);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    final pen = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void line(double x, double y, double a, double b) =>
        canvas.drawLine(Offset(x, y), Offset(a, b), pen);
    void shape(Path p, Color color, {bool sticker = false}) {
      if (sticker) {
        canvas.save();
        canvas.translate(0, 3);
        canvas.drawPath(
          p,
          Paint()
            ..color = ink.withValues(alpha: .10)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 11,
        );
        canvas.restore();
        canvas.drawPath(
          p,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeJoin = StrokeJoin.round,
        );
      }
      canvas.drawPath(p, Paint()..color = color);
      canvas.drawPath(p, pen);
    }

    void oval(Rect rect, Color color, {bool sticker = false}) =>
        shape(Path()..addOval(rect), color, sticker: sticker);
    void box(Rect rect, double radius, Color color, {bool sticker = false}) =>
        shape(
          Path()
            ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius))),
          color,
          sticker: sticker,
        );
    void smile(double x, double y, {bool wink = false}) {
      canvas.drawCircle(Offset(x - 8, y), 2, Paint()..color = ink);
      if (wink) {
        line(x + 6, y, x + 10, y - 2);
      } else {
        canvas.drawCircle(Offset(x + 8, y), 2, Paint()..color = ink);
      }
      canvas.drawPath(
        Path()
          ..moveTo(x - 5, y + 7)
          ..quadraticBezierTo(x, y + 13, x + 5, y + 7),
        pen,
      );
      for (final dx in [-15.0, 15.0]) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x + dx, y + 5), width: 8, height: 4),
          Paint()..color = const Color(0xffef879e).withValues(alpha: .65),
        );
      }
    }

    void sparkle(double x, double y, double r) {
      final p = Path()
        ..moveTo(x, y - r)
        ..quadraticBezierTo(x + 1, y - 1, x + r, y)
        ..quadraticBezierTo(x + 1, y + 1, x, y + r)
        ..quadraticBezierTo(x - 1, y + 1, x - r, y)
        ..quadraticBezierTo(x - 1, y - 1, x, y - r);
      canvas.drawPath(p, Paint()..color = ink);
    }

    canvas.drawCircle(
      const Offset(50, 51),
      42,
      Paint()..color = kind.background,
    );
    canvas.save();
    canvas.translate(50, 50);
    canvas.rotate(switch (kind) {
      NoticeKind.received => .10,
      NoticeKind.period => -.08,
      NoticeKind.feedback => .07,
      _ => -.05,
    });
    canvas.translate(-50, -50);
    switch (kind) {
      case NoticeKind.reminder:
      case NoticeKind.message:
        oval(const Rect.fromLTWH(42, 18, 16, 16), kind.color, sticker: true);
        oval(const Rect.fromLTWH(42, 68, 16, 13), kind.color);
        final bell = Path()
          ..moveTo(25, 67)
          ..quadraticBezierTo(32, 60, 32, 45)
          ..cubicTo(32, 23, 68, 23, 68, 45)
          ..quadraticBezierTo(68, 60, 75, 67)
          ..quadraticBezierTo(76, 73, 68, 73)
          ..lineTo(32, 73)
          ..quadraticBezierTo(24, 73, 25, 67)
          ..close();
        shape(bell, kind.color, sticker: true);
        smile(50, 49, wink: true);
        line(20, 34, 15, 29);
        line(77, 31, 83, 26);
        line(18, 45, 12, 45);
        sparkle(83, 53, 5);
      case NoticeKind.received:
        line(31, 70, 27, 80);
        line(64, 70, 72, 79);
        oval(const Rect.fromLTWH(22, 22, 56, 56), kind.color, sticker: true);
        canvas.drawCircle(
          const Offset(50, 50),
          22,
          Paint()
            ..color = ink.withValues(alpha: .16)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        box(const Rect.fromLTWH(30, 39, 18, 11), 4, ink);
        box(const Rect.fromLTWH(52, 39, 18, 11), 4, ink);
        line(48, 42, 52, 42);
        final gleam = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(34, 42), const Offset(37, 45), gleam);
        canvas.drawLine(const Offset(56, 42), const Offset(59, 45), gleam);
        canvas.drawPath(
          Path()
            ..moveTo(43, 57)
            ..quadraticBezierTo(50, 66, 57, 57),
          pen,
        );
        line(19, 53, 13, 46);
        line(79, 53, 86, 44);
        sparkle(78, 20, 7);
        sparkle(16, 24, 4);
      case NoticeKind.fund:
        canvas.drawPath(
          Path()
            ..moveTo(76, 51)
            ..cubicTo(91, 39, 94, 62, 82, 57),
          pen,
        );
        box(const Rect.fromLTWH(30, 68, 12, 14), 4, kind.color);
        box(const Rect.fromLTWH(60, 68, 12, 14), 4, kind.color);
        final pig = Path()
          ..moveTo(25, 39)
          ..lineTo(27, 22)
          ..quadraticBezierTo(38, 21, 43, 31)
          ..cubicTo(79, 23, 87, 67, 64, 73)
          ..cubicTo(28, 85, 12, 60, 25, 39)
          ..close();
        shape(pig, kind.color, sticker: true);
        line(46, 34, 58, 34);
        canvas.drawCircle(const Offset(38, 46), 2, Paint()..color = ink);
        canvas.drawCircle(const Offset(62, 46), 2, Paint()..color = ink);
        oval(const Rect.fromLTWH(39, 51, 25, 16), const Color(0xfff494b4));
        line(47, 57, 47, 60);
        line(56, 57, 56, 60);
        oval(
          const Rect.fromLTWH(48, 8, 13, 17),
          const Color(0xffffda85),
          sticker: true,
        );
        line(54, 13, 54, 19);
        sparkle(83, 28, 5);
      case NoticeKind.period:
      case NoticeKind.feedback:
        line(29, 55, 18, 43);
        line(69, 55, 82, 42);
        final paper = Path()
          ..moveTo(29, 22)
          ..lineTo(70, 22)
          ..lineTo(70, 79)
          ..lineTo(62, 74)
          ..lineTo(54, 79)
          ..lineTo(46, 74)
          ..lineTo(38, 79)
          ..lineTo(29, 74)
          ..close();
        shape(paper, Colors.white, sticker: true);
        box(const Rect.fromLTWH(35, 28, 29, 9), 3, kind.color);
        if (kind == NoticeKind.period) {
          smile(50, 49, wink: true);
          line(17, 41, 14, 35);
          line(82, 41, 86, 35);
          sparkle(79, 21, 6);
          sparkle(17, 65, 4);
          line(40, 66, 58, 66);
        } else {
          line(37, 46, 43, 44);
          line(55, 44, 62, 46);
          canvas.drawCircle(const Offset(41, 51), 2, Paint()..color = ink);
          canvas.drawCircle(const Offset(59, 51), 2, Paint()..color = ink);
          line(47, 61, 54, 61);
          oval(const Rect.fromLTWH(62, 56, 22, 22), kind.color, sticker: true);
          line(80, 76, 88, 85);
          canvas.drawArc(
            const Rect.fromLTWH(68, 61, 9, 9),
            math.pi,
            math.pi / 2,
            false,
            pen,
          );
          sparkle(19, 25, 5);
        }
      case NoticeKind.pending:
        box(const Rect.fromLTWH(31, 20, 39, 62), 10, kind.color, sticker: true);
        line(44, 26, 57, 26);
        box(const Rect.fromLTWH(36, 33, 29, 37), 5, Colors.white);
        line(42, 47, 46, 49);
        line(55, 49, 59, 47);
        canvas.drawCircle(const Offset(51, 58), 3, pen);
        line(47, 76, 54, 76);
        oval(
          const Rect.fromLTWH(61, 60, 25, 25),
          const Color(0xffffdb86),
          sticker: true,
        );
        line(73, 65, 73, 73);
        line(73, 73, 78, 76);
        line(17, 35, 24, 35);
        line(24, 35, 17, 43);
        line(17, 43, 24, 43);
        sparkle(79, 24, 4);
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StickerPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
