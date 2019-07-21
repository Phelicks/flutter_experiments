import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeartAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FractionalTranslation(
        translation: Offset(0, -0.03),
        child: Center(
          child: Hearts(),
        ),
      ),
    );
  }
}

class Hearts extends StatefulWidget {
  const Hearts({
    Key key,
  }) : super(key: key);

  @override
  _HeartsState createState() => _HeartsState();
}

class _HeartsState extends State<Hearts> with SingleTickerProviderStateMixin {
  static final base = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ].reversed.toList();
  final colors = base + base + base;

  AnimationController animation;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    animation = AnimationController(vsync: this);
    animation.duration = Duration(seconds: 10);
    animation.addListener(() => setState(() {}));
    animation.forward();
    animation.repeat();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );
  }

  @override
  Widget build(BuildContext context) {
    var count = 0;
    final children = (colors.map((color) {
      final offset = 1 - (count++ / colors.length);
      final fraction = (animation.value + offset) % 1;

      return Helper(
        Transform.scale(
          scale: 3.4 * Curves.decelerate.transform(fraction),
          child: Image.asset("assets/heart.png", color: color),
        ),
        fraction,
      );
    }).toList()
          ..sort((a, b) => -a.scale.compareTo(b.scale)))
        .map((helper) => helper.child)
        .toList();

    return Stack(
      fit: StackFit.expand,
      children: children,
    );
  }
}

class Letters extends StatefulWidget {
  const Letters(
    this.text, {
    Key key,
  }) : super(key: key);

  final String text;

  @override
  _LettersState createState() => _LettersState();
}

class _LettersState extends State<Letters> with SingleTickerProviderStateMixin {
  static final base = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ].reversed.toList();
  final colors = base + base + base;

  AnimationController animation;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    animation = AnimationController(vsync: this);
    animation.duration = Duration(seconds: 10);
    animation.addListener(() => setState(() {}));
    animation.forward();
    animation.repeat();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );
  }

  @override
  Widget build(BuildContext context) {
    var count = 0;
    final children = (colors.map((color) {
      final offset = 1 - (count++ / colors.length);
      final fraction = (animation.value + offset) % 1;

      return Helper(
        Transform.scale(
          scale: 3.4 * Curves.decelerate.transform(fraction) + 1.0,
          child: Container(
              alignment: Alignment.center,
              child: Text(widget.text,
                  style: TextStyle(color: color, fontSize: 50))),
        ),
        fraction,
      );
    }).toList()
          ..sort((a, b) => -a.scale.compareTo(b.scale)))
        .map((helper) => helper.child)
        .toList();

    return Stack(children: children);
  }
}

class Helper {
  final Widget child;
  final double scale;

  Helper(this.child, this.scale);
}

class MyPainter extends CustomPainter {
  final Color color;

  MyPainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const circleWidth = 1.8 / 3;
    final path = Path();
    path.addOval(Rect.fromLTWH(
        0, 0, size.width * circleWidth, size.width * circleWidth));
    path.addOval(Rect.fromLTWH(size.width * (1 - circleWidth), 0,
        size.width * circleWidth, size.width * circleWidth));
    path.addPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width * circleWidth * 1.0,
            size.width * circleWidth * 1.0)),
      Offset(size.width / 2, size.width * 0.923),
      matrix4: Matrix4.rotationZ(pi * 1.25).storage,
    );
    path.close();
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
