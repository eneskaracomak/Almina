import 'dart:math';
import 'package:flutter/material.dart';
class KazimaKartPage extends StatefulWidget {
  @override
  _KazimaKartPageState createState() => _KazimaKartPageState();
}

class _KazimaKartPageState extends State<KazimaKartPage> {
  List<Offset?> points = [];
  bool isScratched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kazıma Kartı ve Çöp Adam'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://us.123rf.com/450wm/djvstock/djvstock1903/djvstock190322730/124178882-cloud-sky-isolated-icon-vector-illustration-design.jpg?ver=6'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: [
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject() as RenderBox;
                        points.add(renderBox.globalToLocal(details.localPosition));
                      });
                    },
                    onPanEnd: (_) {
                      if (points.length > 500) {
                        setState(() {
                          isScratched = true;
                        });
                      }
                    },
                    child: CustomPaint(
                      size: Size(300, 300),
                      painter: KazimaKartPainter(points),
                    ),
                  ),
                  if (isScratched)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 100, color: Colors.black), // Çöp adam simgesi
                            SizedBox(height: 20),
                            Text("Kazandığınız Ürün: Çöp Adam", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    points.clear();
                    isScratched = false;
                  });
                },
                child: Text("Tekrar Kazı", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Buton rengi
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KazimaKartPainter extends CustomPainter {
  final List<Offset?> points;
  KazimaKartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Arka planı gri renkte çizebiliriz.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Kullanıcının kazıdığı yerleri çiziyoruz
    paint.color = Colors.transparent;
    paint.strokeWidth = 30;
    paint.strokeCap = StrokeCap.round;
    paint.blendMode = BlendMode.clear;

    for (var point in points) {
      if (point != null) {
        canvas.drawCircle(point, 20, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}