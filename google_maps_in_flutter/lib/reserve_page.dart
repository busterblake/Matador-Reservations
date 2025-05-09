import 'package:flutter/material.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

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
class _ReservePageState extends State<ReservePage> {
  late Map<String, bool> tableSelectionState;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the selection state for each table
    // This creates a map where each table's ID is a key, and the value is a boolean indicating whether the table is selected
    tableSelectionState = {
      for (var table in widget.restaurant['layout']) table['id']: false,
    };
    _updateTableAvailability();
  }

  // Disposes both the name and email text entries when no longer in use
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Function which checks the database to see if there is already
  // a reservation for any tables in the restaurant.
  // It will mark tables with a reservation as unavailable, otherwise
  // the table is available
  //
  // FirebaseFirestore checks the current instance in the database
  // at a certain collection(restaurant list) ==> document(restaurant)
  // ==> Field(Date) ==> Map(Time) and takes a snapshot of all the
  // tables currently have a reservation.
  Future<void> _updateTableAvailability() async {
    final saveReservationData = SaveReservationData();
    final reservationData = await saveReservationData.loadData();

    final restaurantId = widget.restaurant['id'];
    final dateString = reservationData['date'];
    final timeString = reservationData['time'];

    final docRef = FirebaseFirestore.instance
        .collection('restaurant list')
        .doc(restaurantId);
    final docSnapshot = await docRef.get();

    List<dynamic> layout = widget.restaurant['layout'];

    // Mark all tables as available initially
    for (var table in layout) {
      table['available'] = true;
    }

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data.containsKey(dateString)) {
        final timeMap = data[dateString];
        if (timeMap is Map<String, dynamic> &&
            timeMap.containsKey(timeString)) {
          final timeEntry = timeMap[timeString];
          if (timeEntry is Map<String, dynamic>) {
            for (var table in layout) {
              final tableId = table['id'].toString();
              if (timeEntry.containsKey(tableId)) {
                table['available'] = false; // Mark as unavailable if reserved
              }
            }
          }
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
          // Calls Function to build the tables of the restaurant
          // and place them on the screen to reserve.
          ..._buildTables(widget.restaurant['layout']),

          // Column to place name and email text boxes
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 8.0,
                ),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              // If the user is not signed it, the email textbox
              // is placed below the name text box
              if (user == null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child:
            tableSelectionState.containsValue(true)
                ? Container(
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
                                title: const Text(
                                  "Error",
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                content: const Text(
                                  "Please enter your name.",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                actions: [
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                              Colors.pink,
                                            ),
                                        foregroundColor:
                                            WidgetStateProperty.all<Color>(
                                              Colors.white,
                                            ),
                                        minimumSize:
                                            WidgetStateProperty.all<Size>(
                                              const Size(100.0, 50.0),
                                            ),
                                        shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder
                                        >(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.0,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.pink,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Ok",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        } else if (emailController.text.isEmpty &&
                            user?.email == null) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  "Error",
                                  style: TextStyle(fontSize: 20.0),
                                ),
                                content: const Text(
                                  "Please enter your Email.",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                actions: [
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                              Colors.pink,
                                            ),
                                        foregroundColor:
                                            WidgetStateProperty.all<Color>(
                                              Colors.white,
                                            ),
                                        minimumSize:
                                            WidgetStateProperty.all<Size>(
                                              const Size(100.0, 50.0),
                                            ),
                                        shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder
                                        >(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.0,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.pink,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Ok",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        try {
                          final saveReservationData = SaveReservationData();
                          final reservationData =
                              await saveReservationData.loadData();
                          final selectedDateTime = parseDateTime(
                            reservationData['date']!,
                            reservationData['time']!,
                          );
                          final selectedTable =
                              tableSelectionState.entries
                                  .firstWhere((entry) => entry.value)
                                  .key;
                          final restaurantId = widget.restaurant['id'];
                          final partySize = reservationData['partySize'];
                          final user = FirebaseAuth.instance.currentUser;

                          final name = nameController.text.trim();
                          final email = emailController.text.trim();

                          if (name.isEmpty && email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter your name and email address.',
                                ),
                              ),
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
                            },
                          );

                          // Fake loading hehe
                          await Future.delayed(const Duration(seconds: 1));
                          Navigator.pop(context);

                          print('test!!!!!!');

                          var uuid = Uuid();
                          final resID = uuid.v4().toString();

                          createCollection(
                            reservationData['date'],
                            reservationData['time'],
                            restaurantId,
                            resID,
                            selectedTable,
                          );

                          print('test!!!!!! 1.5');

                          final userref = FirebaseAuth.instance.currentUser;
                          final userEmail = userref?.email ?? email;

                          final docRef = FirebaseFirestore.instance
                              .collection('userinfo')
                              .doc(userEmail);
                          final docSnapshot = await docRef.get();

                          if (docSnapshot.exists) {
                            await docRef.update({
                              'reservations': FieldValue.increment(1),
                            });
                          } else {
                            docRef.set({'reservations': 1});
                          }

                          await FirebaseFirestore.instance
                              .collection('reservations')
                              .doc(restaurantId)
                              .update({
                                resID: {
                                  'name': name,
                                  'email': user?.email ?? email,
                                  "userId": user?.uid ?? 'guest',
                                  'date': reservationData['date'],
                                  'time': reservationData['time'],
                                  'partySize': partySize,
                                  'tableId': selectedTable,
                                  'restaurantId': restaurantId,
                                },
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
                                            builder:
                                                (context) => MatadorResApp(),
                                          ),
                                        );
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                              Colors.pink,
                                            ),
                                        foregroundColor:
                                            WidgetStateProperty.all<Color>(
                                              Colors.white,
                                            ),
                                        minimumSize:
                                            WidgetStateProperty.all<Size>(
                                              const Size(100.0, 50.0),
                                            ),
                                        shape: WidgetStateProperty.all<
                                          RoundedRectangleBorder
                                        >(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.0,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.pink,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Ok",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("An error occurred: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.pink,
                        ),
                        foregroundColor: WidgetStateProperty.all<Color>(
                          Colors.white,
                        ),
                        minimumSize: WidgetStateProperty.all<Size>(
                          const Size(double.infinity, 50.0),
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: const BorderSide(
                              color: Colors.pink,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                : const SizedBox.shrink(),
      ),
    );
  }

  // Function dedicated to building and placing tables based on the restaurant's table data
  List<Widget> _buildTables(List<dynamic> layout) {
    return layout.map((table) {
      final id = 'Table ${table['id']?.replaceAll(RegExp(r'[^0-9]'), '')}';
      final isAvailable = table['available'] ?? true;
      final isSelected = tableSelectionState[id] == true;

      // Places table at listed X and Y coordinate
      // Displays whether it's available or not
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

          // Builds table shape
          child: Column(
            children: [
              Container(
                width: table['width'].toDouble(),
                height: table['height'].toDouble(),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Colors.pink
                          : (isAvailable ? Colors.white : Colors.grey[400]),
                  border:
                      isAvailable
                          ? Border.all(color: Colors.pink, width: 1.5)
                          : null,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    id,
                    style: const TextStyle(color: Colors.black, fontSize: 14.0),
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
    final paint =
        Paint()
          ..color = Colors.grey[300]!
          ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
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

void createCollection(date, time, restaurantId, resid, tablenum) async {
  print("Create collection called");

  final db = FirebaseFirestore.instance;
  final collectionRef = db.collection(
    'restaurant list',
  ); // Make sure it the right name of the collection !!!!!!!! --------------

  print("Create collection database refrence created");

  final dateString = date; // EX: "2025-05-06"
  final timeString = time; // EX: "11:00 AM"

  // if date exists check if time exists
  // if it does, add the reservation to the time
  // if it doesn't, create a new time entry
  // if the date doesn't exist, create a new date entry and time then add table x as string

  // check if the date exists
  final docRef = collectionRef.doc(restaurantId);
  final docSnapshot = await docRef.get();
  if (docSnapshot.exists) {
    final data = docSnapshot.data();
    if (data != null && data.containsKey(dateString)) {
      // the date exists so check if time exists
      final timeMap = data[dateString];
      if (timeMap is Map<String, dynamic> && timeMap.containsKey(timeString)) {
        // time does exists so add a reservation
        final timeEntry = timeMap[timeString];
        if (timeEntry is Map<String, dynamic>) {
          int available = 0;
          if (timeEntry.containsKey("available")) {
            final availableValue = timeEntry["available"];
            available = availableValue;
          }
          // check if the reservation is available
          if (available > 0) {
            // add the reservation
            await docRef.update({
              '$dateString.$timeString.available': available - 1,
              '$dateString.$timeString.$tablenum': resid,
            });
          }
        }
      } else {
        // Time doesn't exist, create a new time entry
        await docRef.update({
          '$dateString.$timeString': {'available': 5, '$tablenum': resid},
        });
      }
    } else {
      // Date doesn't exist, create a new date entry and time
      // sets available to 5 and adds the reservation id to the table number
      await docRef.set({
        dateString: {
          timeString: {'available': 5, '$tablenum': resid},
        },
      }, SetOptions(merge: true));
    }
  }
}
