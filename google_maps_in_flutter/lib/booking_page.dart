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

// This needed for displaying the reservation data
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
    final String jsonString = await rootBundle.loadString('lib/Assets/markers.json');
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

    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  String _formatTimestampToReadable(dynamic value) {
    try {
      if (value is Timestamp) {
        final dateTime = value.toDate();
        return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${_formatTime(dateTime)}';
      } else if (value is DateTime) {
        return '${value.month}/${value.day}/${value.year} at ${_formatTime(value)}';
      } else {
        return 'Invalid time';
      }
    } catch (e) {
      return 'Error parsing time';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $ampm';
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
                      final dateTime = reservation['date'];

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
                              Text('Reservation: ${_formatTimestampToReadable(dateTime)}'),
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
