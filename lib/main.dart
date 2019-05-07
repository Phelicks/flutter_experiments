import 'package:flutter/material.dart';
import 'package:motion/screens/3d_box.dart';
import 'package:motion/screens/blur_paint.dart';
import 'package:motion/screens/circle_animation.dart';
import 'package:motion/screens/distort_paint.dart';
import 'package:motion/screens/distort_paint_2.dart';
import 'package:motion/screens/elastic_box.dart';
import 'package:motion/screens/elastic_box_2.dart';
import 'package:motion/screens/paint_game.dart';
import 'package:motion/screens/presi_box.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PageView(
        children: <Widget>[
          //DistortPaint2(),
          Cube3D(),
          BlurPaint(),
          DistortPaint(),
          //ElasticBox2(),
          Cube3D(simple: false),
          CircleAnimation(),
          ElasticBox(),
          PresiBox(),
          PaintGame(),
        ],
      ),
    );
  }
}
