import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'example.dart';

class DistortPaint extends StatefulWidget {
  @override
  _DistortPaintState createState() => _DistortPaintState();
}

class _DistortPaintState extends State<DistortPaint>
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
        child: PixelPerfectUi(
          painter: MyPainter3(animation),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: MyHomePage(title: 'Flutter Demo Home Page'),
          ),
        ),
      ),
    );
  }
}

class PixelPerfectUi extends StatefulWidget {
  final PixelPerfectPainter painter;
  final Widget child;

  PixelPerfectUi({
    Key key,
    @required this.painter,
    @required this.child,
  }) : super(key: key);

  @override
  _PixelPerfectUiState createState() => _PixelPerfectUiState();
}

class _PixelPerfectUiState extends State<PixelPerfectUi> {
  final globalKey = GlobalKey();
  bool _pending = false;

  void update() {
    if (_pending) {
      return;
    }

    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();

    _pending = true;
    boundary.toImage(pixelRatio: 1).then((image) {
      widget.painter.onImage(image);
      _pending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        CustomPaint(painter: widget.painter),
        Opacity(
          opacity: 0.01,
          child: RepaintBoundary(
            key: globalKey,
            child: RenderCallback(
              onPaint: update,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

abstract class PixelPerfectPainter extends CustomPainter {
  PixelPerfectPainter({Listenable repaint}) : super(repaint: repaint);

  void onImage(ui.Image image);
}

class MyPainter3 extends PixelPerfectPainter {
  static const count = Offset(100, 1);

  final Animation<double> animation;
  final positions = List<Offset>();
  final texture = List<Offset>();
  ui.Image _image;
  Size sectionSize;
  Size _lastSize;
  final matrix = (Matrix4.identity()..scale(1.0)
//              ..translate(
//                size.width / 2 - _image.width / 4,
//                size.height / 2 - _image.height / 4,
//              )
      )
      .storage;

  MyPainter3(this.animation) : super(repaint: animation);

  @override
  void onImage(ui.Image image) => _image = image;

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
    if (_image == null) return;

    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..shader = ImageShader(_image, TileMode.clamp, TileMode.clamp, matrix);

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

class RenderCallback extends SingleChildRenderObjectWidget {
  final VoidCallback onPaint;

  RenderCallback({@required this.onPaint, Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCallbackBox(onPaint);
  }
}

class RenderCallbackBox extends RenderShiftedBox {
  final VoidCallback onPaint;

  RenderCallbackBox(this.onPaint) : super(null);

  @override
  void performLayout() {
    child.layout(
      BoxConstraints(
        minHeight: constraints.maxHeight,
        maxHeight: constraints.maxHeight,
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
      ),
      parentUsesSize: false,
    );

    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    onPaint();
  }
}
