import 'dart:ui';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:flutter/material.dart';

class Lines extends StatefulWidget {
  @override
  _LinesState createState() => _LinesState();
}

class _LinesState extends State<Lines> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Offset?> _points = <Offset>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );
    _controller.value = 0.5;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setProgress(double progress) {
    setState(() {
      _controller.value = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Lines'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset point = box.globalToLocal(details.globalPosition);

                  if (point.dx >= 0 && point.dx <= box.size.width && point.dy >= 0 && point.dy <= box.size.height) {
                    _points = List.from(_points)..add(point);
                  } else {
                    if (_points.last != null) {
                      _points = List.from(_points)..add(null);
                    }
                  }
                });
              },
              onPanEnd: (DragEndDetails details) {
                setState(() {
                  _points.clear();
                });
              },
              child: Stack(children: <Widget>[
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: UserPaint(_points),
                  ),
                ),
                Container(
                  child: CustomPaint(
                    painter: UserPaint(
                      _points,
                    ),
                  ),
                ),
              ]),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 522.0, right: 32.0),
                        child: CustomPaint(
                          painter: LinePainter(progress: _controller.value),
                          size: Size(double.maxFinite, 100),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 150.0),
                child: ElevatedButton(
                  child: Text('Animated'),
                  onPressed: () {
                    _controller.reset();
                    _controller.forward();
                  },
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 150.0),
                child: ElevatedButton(
                  child: _controller.value == 1.0 ? Text('Hide') : Text('Show'),
                  onPressed: () {
                    if (_controller.value == 1.0)
                      setProgress(0.0);
                    else
                      setProgress(1.0);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 200.0),
              child: Text('Progress'),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 108.0),
              child: Slider(
                value: _controller.value,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  setState(() {
                    _controller.value = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final double progress;

  LinePainter({required this.progress}); // _controller.value

  Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;
  // ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    var path = parseSvgPath(
        'M 136 216.5 Q 153 193.5 171 165.5 Q 185 141 197.5 128.5 Q 202.5 123.5 200 115.5 Q 198 109 182.5 96 Q 168.5 86.5 158 86 Q 148.5 86.5 152.5 99 Q 159 115.5 153 129.5 Q 133.5 176.5 103.5 220 Q 75 262 36 307.5 Q 30 312.5 29 316.5 Q 27 322.5 35 321 Q 41 320.5 54.5 308 Q 77.5 289.5 106.5 253.5 Q 113 245.5 120.5 236.5 L 136 216.5 Z');
    PathMetric pathMetric = path.computeMetrics().first;
    Path extractPath = pathMetric.extractPath(0.0, pathMetric.length * progress);

    canvas.drawPath(extractPath, _paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class UserPaint extends CustomPainter {
  // actually painting the shit. idk if this is for user input or if its for hint/animation
  final List<Offset?> points;
  final Color brushColor;
  final double brushWidth;

  UserPaint(
    this.points, {
    this.brushColor = Colors.black,
    this.brushWidth = 8.0,
  });

  @override
  bool shouldRepaint(UserPaint oldDelegate) {
    return oldDelegate.points != points;
  }

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = brushColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = brushWidth;

    // draws lines for user input
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }
}
