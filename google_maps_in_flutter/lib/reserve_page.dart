import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservePage extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const ReservePage({
    super.key,
    required this.restaurant,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  Map<String, bool> tableSelectionState = {};
  final nameController = TextEditingController();
  final partySizeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final layout = widget.restaurant['layout'] as List<dynamic>;
    tableSelectionState = {
      for (var table in layout) table['id'].toString(): false,
    };

    _updateTableAvailability();
  }

  Future<void> _updateTableAvailability() async {
    final restaurantId = widget.restaurant['restaurantId'];
    final selectedDate = widget.selectedDate;
    final selectedTime = widget.selectedTime;

    final DateTime selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('restaurantId', isEqualTo: restaurantId)
        .get(const GetOptions(source: Source.server)); // force fresh data

    List<dynamic> layout = widget.restaurant['layout'];

    // Reset all tables to available
    for (var table in layout) {
      table['available'] = true;
    }

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final DateTime reservationStart = data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.tryParse(data['date']) ?? DateTime.now();

      final int duration = data['duration'] ?? 30;
      final DateTime reservationEnd =
          reservationStart.add(Duration(minutes: duration));
      final reservedTableId = data['tableId'].toString();

      final bool overlaps =
          selectedDateTime.isAtSameMomentAs(reservationStart) ||
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
        title: Text('${widget.restaurant['title']}'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 800),
            painter: RestaurantLayoutPainter(),
          ),
          ..._buildTables(widget.restaurant['layout']),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: partySizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Party Size',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final selectedTableId = tableSelectionState.entries
                        .firstWhere(
                          (entry) => entry.value == true,
                          orElse: () => const MapEntry('', false),
                        )
                        .key;

                    if (selectedTableId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a table to reserve.'),
                        ),
                      );
                      return;
                    }

                    if (nameController.text.trim().isEmpty ||
                        partySizeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please fill in your name and party size.'),
                        ),
                      );
                      return;
                    }

                    try {
                      final DateTime selectedDateTime = DateTime(
                        widget.selectedDate.year,
                        widget.selectedDate.month,
                        widget.selectedDate.day,
                        widget.selectedTime.hour,
                        widget.selectedTime.minute,
                      );

                      final user = FirebaseAuth.instance.currentUser;

                      await FirebaseFirestore.instance
                          .collection('reservations')
                          .add({
                        'restaurantId': widget.restaurant['restaurantId'],
                        'tableId': selectedTableId,
                        'userId': user?.uid ?? 'guest',
                        'email': user?.email ?? '',
                        'name': nameController.text.trim(),
                        'partySize':
                            int.tryParse(partySizeController.text.trim()) ?? 1,
                        'date': selectedDateTime,
                        'duration': 30,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reservation successful!')),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving reservation: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: const BorderSide(color: Colors.pink, width: 2.0),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
                Text(
                  'Reserved',
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 10.0),
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
    final Paint paint = Paint()
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
