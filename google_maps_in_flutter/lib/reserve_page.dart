import 'package:flutter/material.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This page allows users to reserve a specific table at a restaurant
// based on the restaurant's layout and the selected date and time.
// This page allows users to reserve a specific table at a restaurant
// based on the restaurant's layout and the selected date and time.
class ReservePage extends StatefulWidget {
  const ReservePage({super.key, required this.restaurant});
  final Map<String, dynamic> restaurant;
  @override
  State<ReservePage> createState() => _ReservePageState();
}

// This class manages the state of the ReservePage.
// It handles the table selection, availability checking, and reservation process.
// This class manages the state of the ReservePage.
// It handles the table selection, availability checking, and reservation process.
class _ReservePageState extends State<ReservePage> {
  late Map<String, bool> tableSelectionState;
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the selection state for each table
    // This creates a map where each table's ID is a key, and the value is a boolean indicating whether the table is selected
    tableSelectionState = {
      for (var table in widget.restaurant['layout'])
        table['id']: false,
    };
    _updateTableAvailability();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _updateTableAvailability() async {

    final saveReservationData = SaveReservationData();
    final reservationData = await saveReservationData.loadData();

    final restaurantId = widget.restaurant['restaurantId'];
    final selectedDateTime = parseDateTime(
      reservationData['date']!,
      reservationData['time']!,
    );
    
    
    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('restaurantId', isEqualTo: restaurantId)
        .get(const GetOptions(source: Source.server));

    List<dynamic> layout = widget.restaurant['layout'];
    for (var table in layout) {
      table['available'] = true;
    }

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final reservationStart = data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.tryParse(data['date'].toString()) ?? DateTime.now();
      final duration = data['duration'] ?? 60;
      final reservationEnd = reservationStart.add(Duration(minutes: duration));
      final reservedTableId = data['tableId'].toString();

      final overlaps = selectedDateTime.isAtSameMomentAs(reservationStart) ||
          (selectedDateTime.isAfter(reservationStart) &&
              selectedDateTime.isBefore(reservationEnd));

      if (overlaps) {
        for (var table in layout) {
          if (table['id'].toString() == reservedTableId) {
            table['available'] = false;
          }
        }
      }
    }
    setState(() {});
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
          CustomPaint(
            size: Size(double.infinity, 800),
            painter: RestaurantLayoutPainter(),
          ),
          ..._buildTables(widget.restaurant['layout']),

          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: tableSelectionState.containsValue(true) ? Container(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () async {

                if (nameController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Error", style: TextStyle(fontSize: 20.0),),
                        content: const Text("Please enter your name.", style: TextStyle(fontSize: 18.0)),
                        actions: [
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(Colors.pink),
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                minimumSize: WidgetStateProperty.all<Size>(const Size(100.0, 50.0)),
                                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: const BorderSide(color: Colors.pink, width: 2.0),
                                  ),
                                ),
                              ),
                              child: const Text("Ok", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                            ),
                          )
                        ],
                      );
                    },
                  );
                  return;
                }

                try {
                  final saveReservationData = SaveReservationData();
                  final reservationData = await saveReservationData.loadData();
                  final selectedDateTime = parseDateTime(
                    reservationData['date']!,
                    reservationData['time']!,
                  );
                  final selectedTable = tableSelectionState.entries
                      .firstWhere((entry) => entry.value)
                      .key;
                  final restaurantId = widget.restaurant['id'];
                  final partySize = reservationData['partySize'];
                  final user = FirebaseAuth.instance.currentUser;
                  
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your name.')),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.pink,
                        ), 
                      );
                    }
                  );

                  // Fake loading hehe
                  await Future.delayed(const Duration(seconds: 1));
                  Navigator.pop(context);

                  print('test!!!!!!');

                  await FirebaseFirestore.instance.collection('reservations').add({
                    'restaurantId': restaurantId,
                    'userId': user?.uid ?? 'guest',
                    'email': user?.email ?? '',
                    'name': name,
                    'tableId': selectedTable,
                    'date': selectedDateTime,
                    'duration': 60,
                    'partySize': partySize,
                  });

                  print('test2!!!!!!');

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Reservation Confirmed!"),
                        content: Text("Your table has been reserved"),
                        backgroundColor: Colors.white,
                        actions: [
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MatadorResApp(),
                                  )
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(Colors.pink),
                                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                minimumSize: WidgetStateProperty.all<Size>(const Size(100.0, 50.0)),
                                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: const BorderSide(color: Colors.pink, width: 2.0),
                                  ),
                                ),
                              ),
                              child: const Text("Ok", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } 
                catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("An error occurred: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
          )
        ): const SizedBox.shrink()
      )
    );
  }

  List<Widget> _buildTables(List<dynamic> layout) {
    return layout.map((table) {
      final id = table['id'].toString();
      final isAvailable = table['available'] ?? true;
      final isSelected = tableSelectionState[id] == true;

      return Positioned(
        left: table['x'].toDouble(),
        top: table['y'].toDouble(),
        child: GestureDetector(
          onTap: () {
            if (isAvailable) {
              setState(() {
                tableSelectionState.updateAll((key, value) => false);
                tableSelectionState[id] = true;
              });
            }
          },
          child: Column(
            children: [
              Container(
                width: table['width'].toDouble(),
                height: table['height'].toDouble(),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.pink
                      : (isAvailable ? Colors.white : Colors.grey[400]),
                  border: isAvailable
                      ? Border.all(color: Colors.pink, width: 1.5)
                      : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    id,
                    style: const TextStyle(color: Colors.black, fontSize: 12.0),
                  ),
                ),
              ),
              if (!isAvailable)
                const Text(
                  'Reserved',
                  style: TextStyle(color: Colors.black54, fontSize: 10.0),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class RestaurantLayoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

DateTime parseDateTime(String date, String time) {
  final dateParts = date.split('-').map(int.parse).toList();
  final timeParts = time.split(RegExp(r'[: ]')).toList();
  final hour = int.parse(timeParts[0]) % 12 + (timeParts[2] == 'PM' ? 12 : 0);
  final minute = int.parse(timeParts[1]);

  return DateTime(dateParts[0], dateParts[1], dateParts[2], hour, minute);
}