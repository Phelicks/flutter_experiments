import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'example.dart';

class DistortPaint2 extends StatefulWidget {
  @override
  _DistortPaint2State createState() => _DistortPaint2State();
}

var globalKey = new GlobalKey();

class _DistortPaint2State extends State<DistortPaint2>
    with SingleTickerProviderStateMixin {
  AnimationController animation;
  MyPainter3 _painter;
  ScrollController scrollController;
  bool _pending = false;
  String text = String.fromCharCodes(
    List.generate(5000, (_) => (65 + Random().nextInt(26))),
  );

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    animation.repeat();

    _painter = MyPainter3(animation);

    scrollController = ScrollController();
    scrollController.addListener((){
      print(scrollController.initialScrollOffset);
      print(scrollController.offset);
    });

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
      _painter.update(image);
      setState(() {});
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
        child: GestureDetector(
          onPanUpdate: (event) {
            print(event.delta);
            _painter.move(event.globalPosition, event.delta);
          },
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomPaint(painter: _painter),
              Opacity(
                opacity: 0.01,
                child: RepaintBoundary(
                  key: globalKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.white,
                      constraints: BoxConstraints.expand(),
                      child: SingleChildScrollView(
                        child: Stack(
                          children: <Widget>[
                            Text(text),
                            //RenderCallback(update),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPainter3 extends CustomPainter {
  static const count = Offset(50, 50);

  ui.Image image;
  final Animation<double> animation;
  final positions = List<Offset>();
  final texture = List<Offset>();
  Size sectionSize;
  Size _lastSize;
  Offset delta = Offset(0, 0);

  MyPainter3(this.animation) : super(repaint: animation);

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

  void update(ui.Image image) {
    this.image = image;
  }

  void move(Offset position, Offset delta) {
    this.delta = delta;
    print(delta.dy);
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
      textureCoordinates: texture
          .map((uv) => uv.translate(0, sin(uv.dx * 0.008) * 50 * delta.dy))
          .toList(),
    );
    canvas.drawVertices(vertices, BlendMode.srcOver, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
