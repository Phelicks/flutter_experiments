import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'example.dart';

class DistortPaint extends StatefulWidget {
  @override
  _DistortPaintState createState() => _DistortPaintState();
}

var globalKey = new GlobalKey();

class _DistortPaintState extends State<DistortPaint>
    with SingleTickerProviderStateMixin {
  AnimationController animation;
  ui.Image image;
  bool _pending = false;

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    animation.repeat();
    update();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  void update() {
    if (_pending) {
      print("pending!");
      return;
    }
    _pending = true;

    Future(() async {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();

      final image = await boundary.toImage(pixelRatio: 2);
      _pending = false;
      setState(() => this.image = image);
    }).catchError((error) {
      print(error);
      _pending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        constraints: BoxConstraints.expand(),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: MyPainter3(image, animation),
            ),
            Opacity(
              opacity: 0.01,
              child: Center(
                child: RepaintBoundary(
                  key: globalKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyHomePage(
                      title: 'Flutter Demo Home Page',
                      onSetState: update,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyPainter3 extends CustomPainter {
  static const count = Offset(50, 50);

  final ui.Image image;
  final Animation<double> animation;
  final positions = List<Offset>();
  final texture = List<Offset>();
  Size sectionSize;
  Size _lastSize;

  MyPainter3(this.image, this.animation) : super(repaint: animation);

  void calcVertices(Size size) {
    if (_lastSize == size) return;
    _lastSize = size;

    sectionSize = Size(size.width / count.dx, size.height / count.dy);

    for (var x = 0; x < count.dx; x++) {
      for (var y = 0; y < count.dy; y++) {
        positions.addAll([
          Offset(sectionSize.width * x, sectionSize.height * y),
          Offset(sectionSize.width * x + sectionSize.width,
              sectionSize.height * y),
          Offset(sectionSize.width * x,
              sectionSize.height * y + sectionSize.height),
          Offset(sectionSize.width + sectionSize.width * x,
              sectionSize.height * y + sectionSize.height),
        ]);

        texture.addAll([
          Offset(sectionSize.width * x, sectionSize.height * y),
          Offset(sectionSize.width * x + sectionSize.width,
              sectionSize.height * y),
          Offset(sectionSize.width * x,
              sectionSize.height * y + sectionSize.height),
          Offset(sectionSize.width + sectionSize.width * x,
              sectionSize.height * y + sectionSize.height),
        ]);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..shader = ImageShader(
        image,
        TileMode.clamp,
        TileMode.clamp,
        (Matrix4.identity()
              ..scale(0.5)
              ..translate(
                size.width / 2 - image.width / 4,
                size.height / 2 - image.height / 4,
              ))
            .storage,
      );

    calcVertices(size);

    final vertices = ui.Vertices(
      VertexMode.triangleStrip,
      positions,
      textureCoordinates: texture.map((v) {
        return v.translate(
          0,
          sin((v.dx / 15) + (animation.value * pi * 2 * 5)) * 10,
        );
      }).toList(),
    );
    canvas.drawVertices(vertices, BlendMode.srcOver, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}