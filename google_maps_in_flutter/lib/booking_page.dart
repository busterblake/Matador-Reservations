/// // The page that accesses the Firebase Database and displays any reservations
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';

/// 
/// that are tied to the email that was used for the reservation
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

// Manages the state of the booking page
// Loads restaurant data and grabs reservation data from database
class _BookingPageState extends State<BookingPage> {
  late Future<List<Map<String, dynamic>>> _userReservations;
  List<Map<String, dynamic>> restaurants = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _userReservations = _fetchUserReservations();
  }

  // Load restaurant info from JSON
  Future<void> _loadRestaurants() async {
    final String data = await rootBundle.loadString('lib/Assets/markers.json');
    final List<dynamic> jsonResult = json.decode(data);
    setState(() {
      restaurants = jsonResult.cast<Map<String, dynamic>>();
    });
  }

  // Grabs reservations based on email
  Future<List<Map<String, dynamic>>> _fetchUserReservations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final List<String> restaurantIds = [
      "matador1",
      "matador2",
      "matador3",
      "matador4",
      "matador5",
      "matador6",
    ];

    List<Map<String, dynamic>> reservations = [];

    // Iterates through database collections and documents to grab reservations
    for (String restaurantId in restaurantIds) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(restaurantId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          data.forEach((key, value) {
            if (value is Map<String, dynamic> && value['email'] == user.email) {
              reservations.add({
                'id': key, // Use the field key as the reservation ID
                ...value,  // Include the reservation details
                'restaurantId': restaurantId, // Add the restaurant ID for context
              });
            }
          });
        }
      }
    }

    return reservations;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Reservations'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: user == null
            ? const Center(
                child: Text(
                  // Displays this message if user is not logged in
                  'You are currently not logged in.\nPlease create an account or sign in under the Profile tab.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
            : FutureBuilder<List<Map<String, dynamic>>>(
                future: _userReservations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No reservations found.'));
                  }

                  final reservations = snapshot.data!;
                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      final restaurantId = reservation['restaurantId'];
                      final restaurant = restaurants.firstWhere(
                        (r) => r['id'] == restaurantId,
                        orElse: () => {
                          'title': 'Unknown',
                          'address': 'Unknown',
                        },
                      );

                      // Displays every reservation as a card with 
                      // important info and deletion functionality
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    restaurant['title'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(restaurant['address'] ?? 'Unknown', style: TextStyle(fontSize: 16)),
                                  Text('Reservation: ${reservation['date']}', style: TextStyle(fontSize: 16)),
                                  Text('Time: ${reservation['time']}', style: TextStyle(fontSize: 16)),
                                  Text("Party Size: ${reservation['partySize'] ?? 'Unknown'}", style: TextStyle(fontSize: 16)),
                                  Text("Table ${reservation['tableId']?.replaceAll(RegExp(r'[^0-9]'), '') ?? 'Unknown'}", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                children: [
                                  Center(
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      iconSize: MediaQuery.of(context).size.width * 0.08,
                                      color: Colors.pink,
                                      onPressed: () async {
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: 'Delete reservation?',
                                          confirmBtnText: 'Keep',
                                          confirmBtnColor: Colors.pink,
                                          confirmBtnTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          showCancelBtn: true,
                                          cancelBtnText: 'Delete',
                                          cancelBtnTextStyle: TextStyle(color: Colors.pink, fontSize: 18, fontWeight: FontWeight.bold),
                                          onCancelBtnTap: () async {

                                            final docRef = FirebaseFirestore.instance
                                            .collection('reservations')
                                            .doc(restaurantId);

                                            // Delete saved reservation
                                            await docRef.update({
                                              reservation['id']: FieldValue.delete(),
                                            });

                                            final docRef2 = FirebaseFirestore.instance
                                              .collection('restaurant list')
                                              .doc(restaurantId);

                                            final date = reservation['date'];
                                            final time = reservation['time'];
                                            final tableId = reservation['tableId'];
                                            final available = reservation['available'];
                                        
                                            // Update table availability in restaurant
                                            await docRef2.update({
                                              '$date.$time.$tableId': FieldValue.delete(),
                                              '$date.$time.$available': FieldValue.increment(1),
                                            });

                                            setState(() {
                                              _userReservations = _fetchUserReservations();
                                            });
                                          },
                                        );
                                      },
                                      tooltip: 'Delete Reservation',
                                    )
                                  )
                                ]
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}