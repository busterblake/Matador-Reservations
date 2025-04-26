import 'package:flutter/material.dart';

class ReservePage extends StatefulWidget {
  const ReservePage({super.key, required this.restaurant});
  final Map<String, dynamic> restaurant;

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  late Map<String, bool> tableSelectionState;

  @override
  void initState() {
    super.initState();
    // Initialize the selection state for each table
    // This creates a map where each table's ID is a key, and the value is a boolean indicating whether the table is selected
    tableSelectionState = {
      for (var table in widget.restaurant['layout'])
        table['id']: false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.restaurant['title']}',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // CustomPaint is used to draw the restaurant layout background
          CustomPaint(
            size: Size(double.infinity, 800),
            painter: RestaurantLayoutPainter(),
          ),
          // Dynamically build table widgets based on the restaurant layout
          ..._buildTables(widget.restaurant['layout']),
        ],
      ),
      bottomNavigationBar: SafeArea(
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () {
              // TODO: If reservation is made, navigate to the booking page.
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.pink),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              minimumSize: WidgetStateProperty.all<Size>(const Size(double.infinity, 50.0)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.pink, width: 2.0),
                ),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          )
        ),
      ),
    ),
    );
  }

  // This function generates a list of Positioned widgets for each table in the layout
  List<Widget> _buildTables(List<dynamic> layout) {
    return layout.map((table) {
      return Positioned(
        left: table['x'].toDouble(), // Position the table horizontally
        top: table['y'].toDouble(), // Position the table vertically
        child: GestureDetector(
          onTap: () {
            if (table['available']) {
              setState(() {
                // Deselect all tables
                tableSelectionState.updateAll((key, value) => false);
                // Select the tapped table
                tableSelectionState[table['id']] = true;
              });
              print('Table ${table['id']} selected');
            } else {
              print('Table ${table['id']} is unavailable');
            }
          },
          child: Container(
            width: table['width'].toDouble(), // Set table width
            height: table['height'].toDouble(), // Set table height
            decoration: BoxDecoration(
              // Change color based on selection and availability
              color: tableSelectionState[table['id']] == true
                  ? Colors.pink
                  : (table['available'] ? Colors.white : Colors.grey[400]),
              border: table['available']
                  ? Border.all(color: Colors.pink, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            child: Center(
              child: Text(
                table['id'], // Display the table ID
                style: const TextStyle(color: Colors.black, fontSize: 12.0),
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

    // Currently just draws a rectangle as the restaurant layout background
    // TODO: Find a way to draw the actual restaurant layout
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}