import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_in_flutter/main.dart';
import 'dart:convert';

class ProfilePageLoggedIn extends StatefulWidget {
  const ProfilePageLoggedIn({super.key});

  @override
  State<ProfilePageLoggedIn> createState() => _ProfilePageLoggedInState();
}

class _ProfilePageLoggedInState extends State<ProfilePageLoggedIn> {
  final user = FirebaseAuth.instance.currentUser;
  Future<List<Map<String, dynamic>>> _userReservations = Future.value([]);

  // For restaurant info to load properly in reservations
  Map<String, Map<String, String>> restaurantInfoMap = {};

  Future<Map<String, Map<String, String>>> loadRestaurantInfo() async {
    final String jsonString = await rootBundle.loadString('lib/Assets/markers.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    return {
      for (var restaurant in jsonData)
        restaurant['id']: {
          'title': restaurant['title'],
          'address': restaurant['address'],
        }
    };
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    restaurantInfoMap = await loadRestaurantInfo();
    _userReservations = _fetchUserReservations();
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _fetchUserReservations() async {
    final uid = user?.uid ?? '';
    final firestore = FirebaseFirestore.instance;
    final reservationsCollection = firestore.collection('reservations');
    final List<Map<String, dynamic>> userReservations = [];

    final restaurants = await reservationsCollection.get();

    for (final doc in restaurants.docs) {
      final restaurantId = doc.id;
      final data = doc.data();

      data.forEach((resID, value) {
        if (value is Map<String, dynamic> && value['userId'] == uid) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MatadorResApp()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Logged in as:\n${user?.email ?? 'Unknown'}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Current Reservations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _userReservations,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No reservations yet.',
                          style: TextStyle(fontSize: 16)),
                    );
                  }

                  final reservations = snapshot.data!;
                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      final restaurantId = reservation['restaurantId'];
                      final tableId = reservation['tableId'] ?? 'N/A';
                      final date = reservation['date'] ?? '';
                      final time = reservation['time'] ?? '';

                      final info = restaurantInfoMap[restaurantId] ??
                          {'title': 'Unknown', 'address': 'Unknown'};

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            info['title']!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(info['address'] ?? ''),
                              Text('Table: $tableId'),
                              Text('Date: $date at $time'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('reservations')
                                  .doc(reservation['restaurantId'])
                                  .update({
                                reservation['id']: FieldValue.delete(),
                              });
                              setState(() {
                                _userReservations =
                                    _fetchUserReservations(); // Refresh
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MatadorResApp()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
