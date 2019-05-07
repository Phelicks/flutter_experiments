import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BlurPaint extends StatefulWidget {
  @override
  _BlurPaintState createState() => _BlurPaintState();
}

var globalKey = new GlobalKey();

class _BlurPaintState extends State<BlurPaint>
    with SingleTickerProviderStateMixin {
  AnimationController animation;

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    animation.repeat();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        constraints: BoxConstraints.expand(),
        child: SafeArea(child: CustomPaint(painter: MyPainter3(animation))),
      ),
    );
  }
}

class MyPainter3 extends CustomPainter {
  static const wallWidth = 200.0;
  static const wallHeight = 60.0;
  static const wallCorner = 13.0;
  static const lineWidth = 4.0;
  static const entityScale = 2.0;
  static const entityPadding = 30.0;

  static const red = Color(0xFFFF3200);
  static const orange = Color(0xFFFFAC00);
  static const yellow = Color(0xFFFFF100);
  static const green = Color(0xFF0BFF00);
  static const blue = Color(0xFF00F6FF);
  static const colors = [red, orange, yellow, green, blue];
  static const colorSections = [0.0, 0.25, 0.5, 0.75, 1.0];

  //
  static final wall = wallPath(wallWidth, wallHeight, wallCorner);
  static final ghost1 = Ghost(blue, entityScale, lineWidth, -0.08);
  static final ghost2 = Ghost(red, entityScale, lineWidth, -0.13);
  static final ghost3 = Ghost(green, entityScale, lineWidth, -0.18);

  final Animation<double> animation;

  MyPainter3(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final midX = size.width / 2;
    final midY = size.height / 2;

    //Color
    final offset = size.width * 2 * animation.value;
    final rainbow = rainbowPaint(size, offset, lineWidth, 0);
    final rainbowBright = rainbowPaint(size, offset, lineWidth * 0.4, 0.4);
    final rainbowFill = rainbowFillPaint(size, offset, lineWidth, 0);

    //frame
    final framePadding = 10.0;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            framePadding,
            framePadding,
            size.width - framePadding * 2,
            size.height - framePadding * 2,
          ),
          Radius.circular(5),
        ),
        rainbow);

    //Wall
    final wallPosition = (Matrix4.identity()..translate(midX, midY)).storage;
    canvas.drawPath(wall.transform(wallPosition), rainbowFill);
    canvas.drawPath(wall.transform(wallPosition), rainbow);
    canvas.drawPath(wall.transform(wallPosition), rainbowBright);

    //Player
    final path = entityPath(size);
    final mouth = (1 - (animation.value * 15 % 1) * 2).abs();
    final playerPosition = getPlayerPosition(path, size);
    final playerPath = player(entityScale, mouth).transform(playerPosition);

    canvas.drawPath(playerPath, solidFillPaint(yellow.withOpacity(0.1), 0.1));
    canvas.drawPath(playerPath, solidPaint(yellow, lineWidth * 0.6, 0));
    canvas.drawPath(playerPath, solidPaint(yellow, lineWidth * 0.4, 0.2));

    //Ghost
    ghost1.draw(canvas, size, path, animation.value);
    ghost2.draw(canvas, size, path, animation.value);
    ghost3.draw(canvas, size, path, animation.value);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  Float64List getPlayerPosition(Path path, Size size) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * animation.value);
    final position = tangent.position;

    return (Matrix4.identity()
          ..translate(position.dx, position.dy)
          ..rotateZ(
            (pi - tangent.angle.abs()) % pi < 0.1
                ? tangent.angle - pi
                : tangent.angle,
          ))
        .storage;
  }

  Path entityPath(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(
        (size.width - wallWidth) / 2 - entityPadding,
        size.height / 2 - wallHeight / 2 - entityPadding,
        wallWidth + entityPadding * 2,
        wallHeight + entityPadding * 2,
      ));
  }

  Paint rainbowPaint(
    Size size,
    double offset,
    double lineWidth,
    double brightness,
  ) {
    return Paint()
      ..shader = ui.Gradient.linear(
        Offset(offset, size.height / 2),
        Offset(size.width + offset, size.height / 2),
        colors,
        colorSections,
        ui.TileMode.mirror,
      )
      ..colorFilter = ColorFilter.mode(
        Colors.white.withOpacity(brightness),
        BlendMode.lighten,
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
  }

  Paint rainbowFillPaint(
    Size size,
    double offset,
    double lineWidth,
    double brightness,
  ) {
    return Paint()
      ..shader = ui.Gradient.linear(
        Offset(offset, size.height / 2),
        Offset(size.width + offset, size.height / 2),
        colors.map((c) => c.withOpacity(0.1)).toList(),
        colorSections,
        ui.TileMode.mirror,
      )
      ..colorFilter = ColorFilter.mode(
        Colors.white.withOpacity(brightness),
        BlendMode.lighten,
      )
      ..style = PaintingStyle.fill
      ..strokeWidth = lineWidth;
  }

  Path player(double scale, double mouth) {
    return Path()
      ..moveTo(0, 0)
      //mouth top
      ..lineTo(-7 * scale, -3 * scale * mouth)
      //top left
      ..lineTo(-7 * scale, -5 * scale)
      ..lineTo(-6 * scale, -5 * scale)
      ..lineTo(-6 * scale, -6 * scale)
      ..lineTo(-4 * scale, -6 * scale)
      ..lineTo(-4 * scale, -7 * scale)
      //top right
      ..lineTo(3 * scale, -7 * scale)
      ..lineTo(3 * scale, -6 * scale)
      ..lineTo(5 * scale, -6 * scale)
      ..lineTo(5 * scale, -5 * scale)
      ..lineTo(6 * scale, -5 * scale)
      ..lineTo(6 * scale, -3 * scale)
      ..lineTo(7 * scale, -3 * scale)
      //bottom right
      ..lineTo(7 * scale, 3 * scale)
      ..lineTo(6 * scale, 3 * scale)
      ..lineTo(6 * scale, 5 * scale)
      ..lineTo(5 * scale, 5 * scale)
      ..lineTo(5 * scale, 6 * scale)
      ..lineTo(3 * scale, 6 * scale)
      ..lineTo(3 * scale, 7 * scale)
      //bottom left
      ..lineTo(-4 * scale, 7 * scale)
      ..lineTo(-4 * scale, 6 * scale)
      ..lineTo(-6 * scale, 6 * scale)
      ..lineTo(-6 * scale, 5 * scale)
      ..lineTo(-7 * scale, 5 * scale)
      //mouth bottom
      ..lineTo(-7 * scale, 3 * scale * mouth)
      ..close();
  }

  static Path wallPath(double width, double height, double scale) {
    return Path()
      ..moveTo(-width / 2 + wallCorner, -height / 2)
      ..lineTo(width / 2 - wallCorner, -height / 2)
      ..lineTo(width / 2 - wallCorner, -height / 2 + wallCorner)
      ..lineTo(width / 2, -height / 2 + wallCorner)
      ..lineTo(width / 2, height / 2 - wallCorner)
      ..lineTo(width / 2 - wallCorner, height / 2 - wallCorner)
      ..lineTo(width / 2 - wallCorner, height / 2)
      ..lineTo(-width / 2 + wallCorner, height / 2)
      ..lineTo(-width / 2 + wallCorner, height / 2 - wallCorner)
      ..lineTo(-width / 2, height / 2 - wallCorner)
      ..lineTo(-width / 2, -height / 2 + wallCorner)
      ..lineTo(-width / 2 + wallCorner, -height / 2 + wallCorner)
      ..close();
  }
}

class Ghost {
  static final eyeSolidPaint =
      solidFillPaint(Colors.white.withOpacity(0.6), 0.1);
  static final pupilPaint = solidFillPaint(Colors.black, 0);
  final Paint eyePaint;
  final Paint ghostSolidPaint;
  final Paint ghostPaint;
  final Paint ghostHighlightPaint;
  final Path ghostPath;
  final Path eyesPath;

  final double entityScale;
  final double offset;
  final Color color;

  Ghost(this.color, this.entityScale, double lineWidth, this.offset)
      : this.eyePaint = solidPaint(Colors.white, lineWidth * 0.2, 0.2),
        this.ghostSolidPaint = solidFillPaint(color.withOpacity(0.1), 0.1),
        this.ghostPaint = solidPaint(color, lineWidth * 0.6, 0),
        this.ghostHighlightPaint = solidPaint(color, lineWidth * 0.4, 0.2),
        this.ghostPath = ghost(entityScale),
        this.eyesPath = ghostEyes(entityScale);

  void draw(Canvas canvas, Size size, Path path, double animation) {
    final ghostPosition = getGhostPosition(path, size, animation, offset);
    final ghostEntity = ghostPath.transform(ghostPosition);
    final eyes = eyesPath.transform(ghostPosition);
    final metric = path.computeMetrics().first;
    final pathOffset =
        (metric.length * animation + metric.length * offset) % metric.length;
    final tangent = metric.getTangentForOffset(pathOffset);

    final pupils = ghostPupils(
      entityScale,
      tangent.vector.dx,
      tangent.vector.dy,
    ).transform(ghostPosition);

    canvas.drawPath(ghostEntity, ghostSolidPaint);
    canvas.drawPath(ghostEntity, ghostPaint);
    canvas.drawPath(ghostEntity, ghostHighlightPaint);

    canvas.drawPath(eyes, eyeSolidPaint);
    canvas.drawPath(eyes, eyePaint);
    canvas.drawPath(pupils, pupilPaint);
  }

  Float64List getGhostPosition(
    Path path,
    Size size,
    double animation,
    double offset,
  ) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(
        (metric.length * animation + metric.length * offset) % metric.length);
    final position = tangent.position;

    return (Matrix4.identity()..translate(position.dx, position.dy)).storage;
  }

  static Path ghost(double scale) {
    return Path()
      //top left
      ..moveTo(-7 * scale, -3 * scale)
      ..lineTo(-6 * scale, -3 * scale)
      ..lineTo(-6 * scale, -5 * scale)
      ..lineTo(-5 * scale, -5 * scale)
      ..lineTo(-5 * scale, -6 * scale)
      ..lineTo(-3 * scale, -6 * scale)
      ..lineTo(-3 * scale, -7 * scale)
      //top right
      ..lineTo(3 * scale, -7 * scale)
      ..lineTo(3 * scale, -6 * scale)
      ..lineTo(5 * scale, -6 * scale)
      ..lineTo(5 * scale, -5 * scale)
      ..lineTo(6 * scale, -5 * scale)
      ..lineTo(6 * scale, -3 * scale)
      ..lineTo(7 * scale, -3 * scale)
      //bottom right
      ..lineTo(7 * scale, 6 * scale)
      ..lineTo(6 * scale, 6 * scale)
      ..lineTo(6 * scale, 5 * scale)
      ..lineTo(5 * scale, 5 * scale)
      ..lineTo(5 * scale, 4 * scale)
      ..lineTo(4 * scale, 4 * scale)
      ..lineTo(4 * scale, 5 * scale)
      ..lineTo(3 * scale, 5 * scale)
      ..lineTo(3 * scale, 7 * scale)
      ..lineTo(1 * scale, 7 * scale)
      ..lineTo(1 * scale, 5 * scale)
      //bottom left
      ..lineTo(-1 * scale, 5 * scale)
      ..lineTo(-1 * scale, 7 * scale)
      ..lineTo(-3 * scale, 7 * scale)
      ..lineTo(-3 * scale, 5 * scale)
      ..lineTo(-4 * scale, 5 * scale)
      ..lineTo(-4 * scale, 4 * scale)
      ..lineTo(-5 * scale, 4 * scale)
      ..lineTo(-5 * scale, 5 * scale)
      ..lineTo(-6 * scale, 5 * scale)
      ..lineTo(-6 * scale, 6 * scale)
      ..lineTo(-7 * scale, 6 * scale)
      ..close();
  }

  static Path ghostEyes(double scale) {
    return Path()
      //eye left
      ..moveTo(-5 * scale, -2 * scale)
      ..lineTo(-4 * scale, -2 * scale)
      ..lineTo(-4 * scale, -3 * scale)
      ..lineTo(-2 * scale, -3 * scale)
      ..lineTo(-2 * scale, -2 * scale)
      ..lineTo(-1 * scale, -2 * scale)
      ..lineTo(-1 * scale, 0 * scale)
      ..lineTo(-2 * scale, 0 * scale)
      ..lineTo(-2 * scale, 1 * scale)
      ..lineTo(-4 * scale, 1 * scale)
      ..lineTo(-4 * scale, 0 * scale)
      ..lineTo(-4 * scale, 0 * scale)
      ..lineTo(-5 * scale, 0 * scale)
      ..close()
      //eye right
      ..moveTo(5 * scale, -2 * scale)
      ..lineTo(4 * scale, -2 * scale)
      ..lineTo(4 * scale, -3 * scale)
      ..lineTo(2 * scale, -3 * scale)
      ..lineTo(2 * scale, -2 * scale)
      ..lineTo(1 * scale, -2 * scale)
      ..lineTo(1 * scale, 0 * scale)
      ..lineTo(2 * scale, 0 * scale)
      ..lineTo(2 * scale, 1 * scale)
      ..lineTo(4 * scale, 1 * scale)
      ..lineTo(4 * scale, 0 * scale)
      ..lineTo(4 * scale, 0 * scale)
      ..lineTo(5 * scale, 0 * scale)
      ..close();
  }

  Path ghostPupils(double scale, double offsetX, double offsetY) {
    final x = offsetX * scale;
    final y = offsetY * scale;
    return Path()
      //eye left
      ..moveTo(x - 4 * scale, y - 2 * scale)
      ..lineTo(x - 2 * scale, y - 2 * scale)
      ..lineTo(x - 2 * scale, y)
      ..lineTo(x - 4 * scale, y)
      ..close()
      //eye right
      ..moveTo(x + 4 * scale, y - 2 * scale)
      ..lineTo(x + 2 * scale, y - 2 * scale)
      ..lineTo(x + 2 * scale, y)
      ..lineTo(x + 4 * scale, y)
      ..close();
  }
}

Paint solidPaint(
  Color color,
  double lineWidth,
  double brightness,
) {
  return Paint()
    ..color = color
    ..colorFilter = ColorFilter.mode(
      Colors.white.withOpacity(brightness),
      BlendMode.lighten,
    )
    ..maskFilter = MaskFilter.blur(BlurStyle.solid, 8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = lineWidth;
}

Paint solidFillPaint(
  Color color,
  double brightness,
) {
  return Paint()
    ..color = color
    ..colorFilter = ColorFilter.mode(
      Colors.white.withOpacity(brightness),
      BlendMode.lighten,
    )
    ..style = PaintingStyle.fill;
}
