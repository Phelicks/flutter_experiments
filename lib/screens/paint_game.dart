import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PaintGame extends StatefulWidget {
  @override
  _PaintGameState createState() => _PaintGameState();
}

class _PaintGameState extends State<PaintGame> {
  final _game = Game();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Slider(
                    value: _game.replay,
                    onChanged: (value) {
                      setState(() => _game.replay = value);
                    }),
              ),
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  margin: EdgeInsets.all(5),
                  color: Colors.white,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onHorizontalDragStart: (_) {
                        _game.addNewDraw();
                      },
                      onHorizontalDragUpdate: (event){
                        RenderBox box = context.findRenderObject();
                        Offset position = box.localToGlobal(Offset.zero);

                        final drawTo = event.globalPosition.translate(
                          -position.dx,
                          -position.dy,
                        );
                        _game.addOffset(drawTo);
                      },
                      onScaleStart: (_) => _game.addNewDraw(),
                      onScaleUpdate: (event) {
                        RenderBox box = context.findRenderObject();
                        Offset position = box.localToGlobal(Offset.zero);

                        final drawTo = event.focalPoint.translate(
                          -position.dx,
                          -position.dy,
                        );
                        _game.addOffset(drawTo);
                      },
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: MyPainter3(_game),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () =>
                          setState(() => _game.selectedColor = GameColor.red),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(
                            width:
                                _game.selectedColor == GameColor.red ? 4.0 : 0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () =>
                          setState(() => _game.selectedColor = GameColor.green),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          border: Border.all(
                            width: _game.selectedColor == GameColor.green
                                ? 4.0
                                : 0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () =>
                          setState(() => _game.selectedColor = GameColor.blue),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            width:
                                _game.selectedColor == GameColor.blue ? 4.0 : 0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    FlatButton(
                      onPressed: () => setState(
                          () => _game.selectedColor = GameColor.yellow),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          border: Border.all(
                            width: _game.selectedColor == GameColor.yellow
                                ? 4.0
                                : 0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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
  final Game game;

  MyPainter3(this.game) : super(repaint: game);

  @override
  void paint(Canvas canvas, Size size) {
    game.drawActions.forEach((drawAction) {
      if (drawAction.offsets.isEmpty) return;

      final offsets = drawAction.offsets.sublist(
        0,
        ((drawAction.offsets.length - 1) * game.replay).floor(),
      );

      if (offsets.isEmpty) return;

      final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
      offsets.forEach((offset) => path.lineTo(offset.dx, offset.dy));

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = drawAction.color
        ..strokeWidth = 4;

      canvas.drawPath(path, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Game implements Listenable {
  final _listeners = List<VoidCallback>();
  int _currentList = -1;

  GameColor _selectedColor = GameColor.red;

  GameColor get selectedColor => _selectedColor;

  Color get currentColor {
    switch (selectedColor) {
      case GameColor.red:
        return Colors.red;
      case GameColor.green:
        return Colors.green;
      case GameColor.blue:
        return Colors.blue;
      case GameColor.yellow:
        return Colors.yellow;
    }
    throw "No color found!";
  }

  set selectedColor(GameColor value) {
    _selectedColor = value;
    _listeners.forEach((listener) => listener());
  }

  double _replay = 1.0;

  double get replay => _replay;

  set replay(double value) {
    _replay = value;
    _listeners.forEach((listener) => listener());
  }

  List<DrawAction> drawActions = List<DrawAction>();

  addNewDraw() {
    _currentList++;
    drawActions.add(DrawAction(currentColor, List<Offset>()));
  }

  addOffset(Offset offset) {
    drawActions[_currentList].offsets.add(offset);
    _listeners.forEach((listener) => listener());
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
}

enum GameColor { red, green, blue, yellow }

class DrawAction {
  Color color;
  List<Offset> offsets;

  DrawAction(this.color, this.offsets);
}
