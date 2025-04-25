import 'package:flutter/material.dart';

class ReservePage extends StatelessWidget {
  const ReservePage({super.key, required this.restaurant});
  final Map<String, dynamic> restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${restaurant['title']}',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, 800),
            painter: RestaurantLayoutPainter(),
          ),
          ..._buildTables(restaurant['layout']),
        ],
      ),
    );
  }

  List<Widget> _buildTables(List<dynamic> layout) {
    return layout.map((table) {
      return Positioned(
        left: table['x'].toDouble(),
        top: table['y'].toDouble(),
        child: GestureDetector(
          onTap: () {
            if (table['available']) {
              print('Table ${table['id']} selected');
            } else {
              print('Table ${table['id']} is unavailable');
            }
          },
          child: Container(
            width: table['width'].toDouble(),
            height: table['height'].toDouble(),
            decoration: BoxDecoration(
              color: table['available'] ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                table['id'],
                style: const TextStyle(color: Colors.white, fontSize: 12.0),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class RestaurantLayoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    // Draw the restaurant boundary (rectangular room)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}