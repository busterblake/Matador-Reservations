import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Future<List<Map<String, dynamic>>> _userReservations = Future.value([]);
  Map<String, Map<String, String>> restaurantInfoMap = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    restaurantInfoMap = await _loadRestaurantInfoFromJson();
    setState(() {
      _userReservations = _fetchUserReservations();
    });
  }

  Future<Map<String, Map<String, String>>> _loadRestaurantInfoFromJson() async {
    final String jsonString =
        await rootBundle.loadString('lib/Assets/markers.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    return {
      for (var marker in jsonData)
        marker['id']: {
          'title': marker['title'],
          'address': marker['address'],
        }
    };
  }

  Future<List<Map<String, dynamic>>> _fetchUserReservations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final firestore = FirebaseFirestore.instance;
    final reservationsCollection = firestore.collection('reservations');
    final List<Map<String, dynamic>> userReservations = [];

    final restaurants = await reservationsCollection.get();

    for (final doc in restaurants.docs) {
      final restaurantId = doc.id;
      final data = doc.data();

      data.forEach((resID, value) {
        if (value is Map<String, dynamic> && value['userId'] == user.uid) {
          userReservations.add({
            ...value,
            'id': resID,
            'restaurantId': restaurantId,
          });
        }
      });
    }

    return userReservations;
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
        padding: const EdgeInsets.all(24.0),
        child: user == null
            ? const Center(
                child: Text(
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
                      final info = restaurantInfoMap[restaurantId] ??
                          {'title': 'Unknown', 'address': 'Unknown'};
                      final partyName = reservation['name'] ?? 'Unknown';
                      final partySize = reservation['partySize'] ?? 'Unknown';
                      final tableId = reservation['tableId'] ?? 'Unknown';
                      final date = reservation['date'] ?? '';
                      final time = reservation['time'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info['title']!,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(info['address'] ?? ''),
                              Text('Party Name: $partyName'),
                              Text('Date: $date'),
                              Text('Time: $time'),
                              Text('Party Size: $partySize'),
                              Text('Table: $tableId'),
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
