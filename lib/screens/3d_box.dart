import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Vector4;

import 'blur_paint.dart';
import 'circle_animation.dart';
import 'distort_paint.dart';
import 'elastic_box.dart';

class Cube3D extends StatefulWidget {
  final bool simple;

  const Cube3D({Key key, this.simple = true}) : super(key: key);

  @override
  _Cube3DState createState() => _Cube3DState();
}

class _Cube3DState extends State<Cube3D> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        constraints: BoxConstraints.expand(),
        child: Center(child: Entity(simple: widget.simple)),
      ),
    );
  }
}

class Entity extends StatefulWidget {
  final bool simple;

  Entity({Key key, this.simple}) : super(key: key);

  @override
  EntityState createState() {
    return new EntityState(simple);
  }
}

class EntityState extends State<Entity> {
  static const scaleDamping = 0.5;

  final transform = Matrix4.identity();
  final bool simple;

  var scaleStart = Offset(0, 0);
  var alpha = 0.0;
  var beta = 0.0;
  var lastAlpha = 0.0;
  var lastBeta = 0.0;

  EntityState(this.simple);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (event) {
        scaleStart = Offset(
          event.focalPoint.dx,
          event.focalPoint.dy,
        );
      },
      onScaleUpdate: (event) {
        setState(() {
          alpha = event.focalPoint.dx - scaleStart.dx + lastAlpha;
          beta = event.focalPoint.dy - scaleStart.dy + lastBeta;

          transform.setIdentity();

          transform.translate(
            context.size.width / 2,
            context.size.height / 2,
            context.size.height / 2,
          );
          transform.rotateX(beta / 100.0);
          transform.rotateY(-alpha / 100.0);

          transform.translate(
            -context.size.width / 2,
            -context.size.height / 2,
            -context.size.height / 2,
          );
        });
      },
      onScaleEnd: (event) {
        lastAlpha = alpha;
        lastBeta = beta;
      },
      child: Stack(
        children: <Widget>[
          CubeSide(
            transform: transform.clone(),
            normal: Vector3(0, 0, 1),
            color: Colors.white,
            rotateX: 0,
            rotateY: 0,
          ),
          CubeSide(
            transform: transform,
            normal: Vector3(0, 1, 0),
            color: Colors.green,
            rotateX: -pi / 2,
            rotateY: 0,
            child: simple ? null : CircleAnimation(),
          ),
          CubeSide(
            transform: transform,
            normal: Vector3(0, -1, 0),
            color: Colors.red,
            rotateX: pi / 2,
            rotateY: 0,
          ),
          CubeSide(
            transform: transform,
            normal: Vector3(0, 0, -1),
            color: Colors.blue,
            rotateX: pi,
            rotateY: 0,
            child: simple ? null : ElasticBox(),
          ),
          CubeSide(
            transform: transform,
            normal: Vector3(1, 0, 0),
            color: Colors.yellow,
            rotateX: 0,
            rotateY: pi / 2,
            child: simple ? null : BlurPaint(),
          ),
          CubeSide(
            transform: transform,
            normal: Vector3(-1, 0, 0),
            color: Colors.purple,
            rotateX: 0,
            rotateY: -pi / 2,
            child: simple ? null : DistortPaint(),
          ),
        ],
      ),
    );
  }
}

class CubeSide extends StatelessWidget {
  final perspective = Matrix4.identity()..setEntry(3, 2, 0.001);
  final Matrix4 transform;
  final Vector3 normal;
  final Color color;
  final double rotateX;
  final double rotateY;
  final Widget child;

  CubeSide({
    Key key,
    @required this.transform,
    @required this.normal,
    @required this.color,
    @required this.rotateX,
    @required this.rotateY,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mv = transform.clone()
      ..translate(100.0, 100.0, 100.0)
      ..rotateX(rotateX)
      ..rotateY(rotateY)
      ..translate(-100.0, -100.0, -100.0);

    final Matrix4 matrix = perspective.clone() * mv.clone();
    final result = (matrix.clone()..invert())
        .transposed()
        .clone()
        .transform(Vector4(0, 0, 1, 1))
        .normalized()
        .dot(Vector4(0, 0, 1, 1));

    final visible = result < 0 || result > 1;

    return Transform(
      transform: perspective.clone() * mv.clone(),
      child: visible
          ? Container(width: 200, height: 200, color: color, child: child)
          : const SizedBox(width: 200, height: 200),
    );
  }
}
