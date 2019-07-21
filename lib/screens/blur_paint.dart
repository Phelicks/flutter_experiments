import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BlurPaint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              GamePainter(),
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.transparent),
              ),
              GamePainter(),
            ],
          ),
        ),
      ),
    );
  }
}

class GamePainter extends StatefulWidget {
  const GamePainter({Key key}) : super(key: key);

  @override
  _GamePainterState createState() => _GamePainterState();
}

class _GamePainterState extends State<GamePainter>
    with SingleTickerProviderStateMixin {
  AnimationController animation;

  @override
  void initState() {
    super.initState();

    final duration = Duration(seconds: 5);
    animation = AnimationController(vsync: this, duration: duration);
    animation.repeat();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MyPainter3(animation),
      isComplex: true,
      willChange: true,
    );
  }
}

class MyPainter3 extends CustomPainter {
  static const wallWidth = 50.0;
  static const wallHeight = 500.0;
  static const wallCorner = 13.0;
  static const entityPadding = 30.0;

  final Frame frame;
  final Wall wall;
  final Player player;
  static final ghost1 = Ghost(GamePaint.blue);
  static final ghost2 = Ghost(GamePaint.green);
  static final ghost3 = Ghost(GamePaint.red);

  final Animation<double> animation;

  MyPainter3(this.animation)
      : frame = Frame(animation),
        player = Player(animation),
        wall = Wall(wallWidth, wallHeight, wallCorner, animation),
        super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    //Color
    final path = Path()
      ..addRect(Rect.fromLTWH(
        (size.width - wallWidth) / 2 - entityPadding,
        size.height / 2 - wallHeight / 2 - entityPadding,
        wallWidth + entityPadding * 2,
        wallHeight + entityPadding * 2,
      ));

    final rainbow = RainbowPaint(size, Entity.lineWidth, 0);
    rainbow.update(size, animation.value);

    //Frame
    frame.size = size;
    frame.draw(canvas);

    //Wall
    wall.size = size;
    wall.transform.setTranslationRaw(size.width / 2, size.height / 2, 0);
    wall.draw(canvas);

    //Player
    player.size = size;
    Offset pos = getPlayerPosition(path, animation.value).position;
    player.transform.setTranslationRaw(pos.dx, pos.dy, 0);
    player.transform.setRotationZ(getPlayerRotation(path, animation.value));
    player.draw(canvas);

    //Ghost

    final ghosts = [
      ghost1,
      ghost2,
      ghost3,
      ghost1,
      ghost2,
      ghost3,
      ghost1,
      ghost2,
      ghost3,
    ];
    double offset = 0.0;
    ghosts.forEach((ghost) {
      final t = getPlayerPosition(path, (animation.value - 0.08 - offset) % 1);
      ghost.pupils = t.vector;
      ghost.transform.setTranslationRaw(t.position.dx, t.position.dy, 0);
      ghost.size = size;
      ghost.draw(canvas);
      offset += 0.05;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  ui.Tangent getPlayerPosition(Path path, double animation) {
    final metric = path.computeMetrics().first;
    return metric.getTangentForOffset(metric.length * animation);
  }

  double getPlayerRotation(Path path, double animation) {
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length * animation);

    return (pi - tangent.angle.abs()) % pi < 0.1
        ? tangent.angle - pi
        : tangent.angle;
  }
}

abstract class GamePaint {
  static const red = Color(0xFFFF3200);
  static const orange = Color(0xFFFFAC00);
  static const yellow = Color(0xFFFFF100);
  static const green = Color(0xFF0BFF00);
  static const blue = Color(0xFF00F6FF);

  Paint get stroke;

  Paint get highlight;

  Paint get solid;
}

class SolidPaint implements GamePaint {
  final Paint _stroke;
  final Paint _highlight;
  final Paint _solid;

  SolidPaint(
    Color color,
    double lineWidth, {
    double brightness = 0,
  })  : _stroke = _strokePaint(color, lineWidth, brightness),
        _highlight = _strokePaint(color, lineWidth * 0.4, brightness + 0.4),
        _solid = _solidPaint(color, brightness);

  Paint get stroke => _stroke;

  Paint get highlight => _highlight;

  Paint get solid => _solid;

  static Paint _strokePaint(
    Color color,
    double lineWidth,
    double brightness,
  ) =>
      Paint()
        ..color = color
        ..colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(brightness),
          BlendMode.lighten,
        )
        //..maskFilter = MaskFilter.blur(BlurStyle.solid, 8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..isAntiAlias = false;

  static Paint _solidPaint(
    Color color,
    double brightness,
  ) =>
      Paint()
        ..color = color.withOpacity(0.2)
        ..colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(brightness),
          BlendMode.lighten,
        )
        ..style = PaintingStyle.fill
        ..isAntiAlias = false;
}

class RainbowPaint implements GamePaint {
  static const colors = [
    GamePaint.red,
    GamePaint.orange,
    GamePaint.yellow,
    GamePaint.green,
    GamePaint.blue,
  ];
  static const colorSections = [0.0, 0.25, 0.5, 0.75, 1.0];

  final Paint _stroke;
  final Paint _highlight;
  final Paint _solid;

  RainbowPaint(
    Size size,
    double lineWidth,
    double brightness,
  )   : _stroke = _strokePaint(size, 0, lineWidth, brightness),
        _highlight = _strokePaint(size, 0, lineWidth * 0.4, brightness + 0.4),
        _solid = _solidPaint(size, 0, lineWidth, brightness);

  Paint get stroke => _stroke;

  Paint get highlight => _highlight;

  Paint get solid => _solid;

  void update(Size size, double offset) {
    offset = offset * size.width * 2;
    final gradient = ui.Gradient.linear(
      Offset(offset, size.height / 2),
      Offset(size.width + offset, size.height / 2),
      colors,
      colorSections,
      ui.TileMode.mirror,
    );
    _stroke.shader = gradient;
    _highlight.shader = gradient;
    _solid.shader = ui.Gradient.linear(
      Offset(offset, size.height / 2),
      Offset(size.width + offset, size.height / 2),
      colors.map((c) => c.withOpacity(0.1)).toList(),
      colorSections,
      ui.TileMode.mirror,
    );
  }

  static Paint _strokePaint(
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
      //..maskFilter = MaskFilter.blur(BlurStyle.solid, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..isAntiAlias = false;
  }

  static Paint _solidPaint(
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
      ..strokeWidth = lineWidth
      ..isAntiAlias = false;
  }
}

abstract class Entity {
  static const lineWidth = 4.0;
  static const scale = 2.0;

  final transform = Matrix4.identity();

  Size _size;

  Size get size => _size;

  Offset get position => Offset(transform.storage[12], transform.storage[13]);

  set size(size) {
    final oldValue = _size;
    _size = size;
    if (oldValue != size) onSize();
  }

  void onSize();

  void draw(Canvas canvas);
}

class Frame extends Entity {
  static const framePadding = 10.0;

  RainbowPaint _paint;

  Frame(Animation<double> animation) {
    animation.addListener(() => _paint?.update(size, animation.value));
  }

  @override
  void onSize() {
    _paint = RainbowPaint(size, Entity.lineWidth, 0);
  }

  void draw(Canvas canvas) {
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
        _paint.stroke);
  }
}

class Wall extends Entity {
  final Path path;

  RainbowPaint _paint;

  Wall(
    double wallWidth,
    double wallHeight,
    double wallCorner,
    Animation<double> animation,
  ) : path = getPath(wallWidth, wallHeight, wallCorner, Entity.scale) {
    animation.addListener(() => _paint?.update(size, animation.value));
  }

  @override
  void onSize() {
    _paint = RainbowPaint(size, Entity.lineWidth, 0);
  }

  void draw(Canvas canvas) {
    canvas.drawPath(path.transform(transform.storage), _paint.solid);
    canvas.drawPath(path.transform(transform.storage), _paint.stroke);
    canvas.drawPath(path.transform(transform.storage), _paint.highlight);
  }

  static Path getPath(
    double width,
    double height,
    double corner,
    double scale,
  ) {
    return Path()
      ..moveTo(-width / 2 + corner, -height / 2)
      ..lineTo(width / 2 - corner, -height / 2)
      ..lineTo(width / 2 - corner, -height / 2 + corner)
      ..lineTo(width / 2, -height / 2 + corner)
      ..lineTo(width / 2, height / 2 - corner)
      ..lineTo(width / 2 - corner, height / 2 - corner)
      ..lineTo(width / 2 - corner, height / 2)
      ..lineTo(-width / 2 + corner, height / 2)
      ..lineTo(-width / 2 + corner, height / 2 - corner)
      ..lineTo(-width / 2, height / 2 - corner)
      ..lineTo(-width / 2, -height / 2 + corner)
      ..lineTo(-width / 2 + corner, -height / 2 + corner)
      ..close();
  }
}

class Player extends Entity {
  static const double lineWidth = 1.5;
  final Animation<double> animation;
  ui.Path _playerPath;
  GamePaint _paint;

  Player(this.animation) {
    _playerPath = getPath(Entity.scale, 0).transform(transform.storage);
    animation.addListener(() {
      final mouth = (1 - (animation.value * 15 % 1) * 2).abs();
      _playerPath = getPath(Entity.scale, mouth).transform(transform.storage);
    });
  }

  @override
  void onSize() {
    _paint = SolidPaint(GamePaint.yellow, lineWidth);
  }

  void draw(Canvas canvas) {
    canvas.drawPath(_playerPath, _paint.solid);
    canvas.drawPath(_playerPath, _paint.stroke);
    canvas.drawPath(_playerPath, _paint.highlight);
  }

  Path getPath(double scale, double mouth) {
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
}

class Ghost extends Entity {
  static const double lineWidth = 1.5;
  Offset pupils = Offset.zero;
  final Path ghostPath;
  final Path eyesPath;

  final Color color;
  final Paint eyePaint = Paint()..color = Colors.white;
  final Paint pupilPaint = Paint()..color = Colors.black;

  GamePaint _paint;

  Ghost(this.color)
      : this.ghostPath = ghost(Entity.scale),
        this.eyesPath = ghostEyes(Entity.scale);

  @override
  void onSize() {
    _paint = SolidPaint(color, lineWidth);
  }

  void draw(Canvas canvas) {
    final ghostEntity = ghostPath.transform(transform.storage);
    final eyes = eyesPath.transform(transform.storage);
    final pupils = ghostPupils(
      Entity.scale,
      this.pupils.dx,
      this.pupils.dy,
    ).transform(transform.storage);

    canvas.drawPath(ghostEntity, _paint.solid);
    canvas.drawPath(ghostEntity, _paint.stroke);
    canvas.drawPath(ghostEntity, _paint.stroke);
    canvas.drawPath(ghostEntity, _paint.highlight);

    canvas.drawPath(eyes, eyePaint);
    canvas.drawPath(pupils, pupilPaint);
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
