import 'package:flutter/material.dart';

class PresiBox extends StatefulWidget {
  @override
  _PresiBoxState createState() => _PresiBoxState();
}

class _PresiBoxState extends State<PresiBox> {
  final List<Widget> entities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            entities.add(Entity());
          });
        },
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
      body: Container(
        color: Colors.black,
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: entities,
        ),
      ),
    );
  }
}

class Entity extends StatefulWidget {
  Entity({
    Key key,
  }) : super(key: key);

  @override
  EntityState createState() {
    return new EntityState();
  }
}

class EntityState extends State<Entity> {
  static const scaleDamping = 0.5;

  final transform = Matrix4.identity();

  var scaleStart = Offset(0, 0);
  var currentRotation = 0.0;
  var lastRotation = 0.0;
  var currentScale = 1.0;
  var lastScale = 1.0;
  var currentX = 0.0;
  var currentY = 0.0;
  var lastX = 0.0;
  var lastY = 0.0;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: transform,
      child: GestureDetector(
        onHorizontalDragStart: (_) {},
        onScaleStart: (event) {
          scaleStart = Offset(
            event.focalPoint.dx,
            event.focalPoint.dy,
          );
        },
        onScaleUpdate: (event) {
          setState(() {
            currentX = event.focalPoint.dx - scaleStart.dx + lastX;
            currentY = event.focalPoint.dy - scaleStart.dy + lastY;

            currentScale =
                (((event.scale - 1) * scaleDamping) + 1) + (lastScale - 1);

            currentRotation = event.rotation + lastRotation;

            transform.setIdentity();
            transform.translate(currentX, currentY);
            transform.scale(currentScale);
            transform.translate(
              context.size.width / 2,
              context.size.height / 2,
            );
            transform.rotateZ(currentRotation);
            transform.translate(
              -context.size.width / 2,
              -context.size.height / 2,
            );
          });
        },
        onScaleEnd: (event) {
          lastX = currentX;
          lastY = currentY;
          lastScale = currentScale;
          lastRotation = currentRotation;
        },
        child: Container(
          width: 200,
          height: 200,
          color: Colors.white,
        ),
      ),
    );
  }
}
