import 'package:flutter/material.dart';

class CircleAnimation extends StatefulWidget {
  @override
  _CircleAnimationState createState() => _CircleAnimationState();
}

class _CircleAnimationState extends State<CircleAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    controller.forward();
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) controller.forward(from: 0);
      if (status == AnimationStatus.dismissed) controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: MyPainter(controller),
              //painter: MyPainter2(controller),
            );
          }),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  static const length = 0.8;
  static const offset = 0.05;

  final Animation<double> animation;
  final Animation<double> animation1;
  final Animation<double> animation2;
  final Animation<double> animation3;

  MyPainter(this.animation)
      : animation1 = _animationPart(animation, offset * 0, length + offset * 0),
        animation2 = _animationPart(animation, offset * 1, length + offset * 1),
        animation3 = _animationPart(animation, offset * 2, length + offset * 2),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    _drawCircle(canvas, size, animation1);
    _drawCircle(canvas, size, animation2);
    _drawCircle(canvas, size, animation3);
  }

  static Animation<double> _animationPart(
    Animation<double> animation,
    double start,
    double end,
  ) {
    return CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.slowMiddle),
    );
  }

  _drawCircle(Canvas canvas, Size size, Animation<double> animation) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 * Tween(begin: 0, end: 0.8).transform(animation.value),
      Paint()
        ..color = Colors.white.withOpacity(
          CurvedAnimation(parent: animation, curve: Interval(0, 0.05)).value *
              (1 -
                  CurvedAnimation(parent: animation, curve: Interval(0.6, 1))
                      .value),
        )
        ..strokeWidth = Tween(begin: 2.0, end: 8.0).transform(animation.value)
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
