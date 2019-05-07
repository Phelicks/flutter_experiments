import 'package:flutter/material.dart';

class ElasticBox2 extends StatefulWidget {
  @override
  _ElasticBoxState createState() => _ElasticBoxState();
}

class MyShape extends ShapeBorder {
  @override
  // TODO: implement dimensions
  EdgeInsetsGeometry get dimensions => null;

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    // TODO: implement getInnerPath
    return null;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    // TODO: implement getOuterPath
    return null;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    // TODO: implement paint
  }

  @override
  ShapeBorder scale(double t) {
    // TODO: implement scale
    return null;
  }

}

class _ElasticBoxState extends State<ElasticBox2>
    with SingleTickerProviderStateMixin {
  AnimationController touchAnimation;

  @override
  void initState() {
    super.initState();

    touchAnimation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    touchAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(0),
        color: Colors.black,
        child: Center(
          child: DecoratedBox(
            child: const SizedBox(width: 100, height: 100),
            decoration: ShapeDecoration(
              color: Colors.blue,
              shape:Border(),
            ),
          ),
//          child: LayoutBuilder(builder: (context, constraints) {
//            return GestureDetector(
//              onTap: () {
//                if (touchAnimation.status == AnimationStatus.completed)
//                  setState(() {
//                    touchAnimation.reverse();
//                  });
//                if (touchAnimation.status == AnimationStatus.dismissed)
//                  setState(() {
//                    touchAnimation.forward();
//                  });
//              },
//              child: CustomPaint(
//                size: Size(constraints.maxWidth, constraints.maxHeight),
//                painter: MyPainter2(
//                  touchAnimation,
//                  isReverse: touchAnimation.status == AnimationStatus.reverse,
//                ),
//              ),
//            );
//          }),
        ),
      ),
    );
  }
}

class MyPainter2 extends CustomPainter {
  final Animation<double> animation;
  final elasticAnimation = TweenSequence<double>([
    TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.15),
    TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: -0.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.1),
    TweenSequenceItem(
        tween: Tween<double>(begin: -0.5, end: 0.3)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.1),
    TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: -0.16)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.1),
    TweenSequenceItem(
        tween: Tween<double>(begin: -0.16, end: 0.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.08),
    TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: 0.04)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.07),
    TweenSequenceItem(
        tween: Tween<double>(begin: 0.04, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.05),
  ]);
  static const double strokeWidth = 4;
  final bool isReverse;
  final Animation<double> sizeAnimation;

  MyPainter2(
    this.animation, {
    this.isReverse = false,
  })  : sizeAnimation = CurvedAnimation(
          parent: animation,
          curve: isReverse
              ? Interval(0.7, 1, curve: Curves.easeIn)
              : Interval(0, 0.3, curve: Curves.easeIn),
        ),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final smallHalfW =
        50 * (1 - sizeAnimation.value) + size.width / 2 * sizeAnimation.value;
    final double smallHalfH =
        50 * (1 - sizeAnimation.value) + size.height / 2 * sizeAnimation.value;
    final double elastic = (isReverse ? -10 : 50) *
        elasticAnimation
            .transform(isReverse ? 1 - animation.value : animation.value);
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - smallHalfW, center.dy - smallHalfH)
        ..quadraticBezierTo(
          center.dx,
          center.dy - smallHalfH + elastic,
          center.dx + smallHalfW,
          center.dy - smallHalfH,
        )
        ..quadraticBezierTo(
          center.dx + smallHalfW - elastic,
          center.dy,
          center.dx + smallHalfW,
          center.dy + smallHalfH,
        )
        ..quadraticBezierTo(
          center.dx,
          center.dy + smallHalfH - elastic,
          center.dx - smallHalfW,
          center.dy + smallHalfH,
        )
        ..quadraticBezierTo(
          center.dx - smallHalfW + elastic,
          center.dy,
          center.dx - smallHalfW,
          center.dy - smallHalfH,
        )
        ..close(),
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = strokeWidth
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          colors: [Colors.red, Colors.redAccent],
          stops: [0, 1.0],
        ).createShader(
          Rect.fromLTRB(0, 0, size.width, size.height),
        ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
