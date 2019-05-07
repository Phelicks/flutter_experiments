import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final VoidCallback onSetState;

  const MyApp({Key key, this.onSetState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        onSetState: onSetState,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.onSetState}) : super(key: key);

  final String title;
  final VoidCallback onSetState;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  double _slider = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Slider(
              onChanged: (v) => setState(() => _slider = v),
              value: _slider,
            ),
            Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            RenderCallback(widget.onSetState),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class RenderCallback extends SingleChildRenderObjectWidget{
  final VoidCallback onPaint;

  RenderCallback(this.onPaint);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCallbackBox(onPaint);
  }
}

class RenderCallbackBox extends RenderBox{
  final VoidCallback onPaint;

  RenderCallbackBox(this.onPaint);

  @override
  bool get sizedByParent => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    onPaint();
  }
}