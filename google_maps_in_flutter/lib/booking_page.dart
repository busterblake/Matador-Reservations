import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_in_flutter/time_formatter.dart';


class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late Future<List<Map<String, dynamic>>> _userReservations;

  final Map<String, Map<String, String>> restaurantInfoMap = {
    "matadorBbqPit": {"title": "Matador BBQ Pit", "address": "18111 Nordhoff St"},
    "the818Eatery": {"title": "The 818 Eatery", "address": "18123 Nordhoff St"},
    "northridgeBites": {"title": "Northridge Bites", "address": "18127 Zelzah Ave"},
    "freddyFazbearsPizza": {"title": "Freddy Fazbear's Pizza", "address": "18000 Nordhoff St"},
    "beastBurger": {"title": "Beast Burger", "address": "18103 Nordhoff St"},
    "giordanachos": {"title": "Giordanacho's", "address": "18401 Nordhoff St"},
  };

  @override
  void initState() {
    super.initState();
    _userReservations = _fetchUserReservations();
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
                          {'title': reservation['place'] ?? 'Unknown', 'address': 'Unknown'};

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
                              Text('Reservation: ${formatTimestampToReadable(reservation['date'])}'),
                              Text("Party Size: ${reservation['partySize'] ?? 'Unknown'}"),
                              Text("Table: ${reservation['tableId'] ?? 'Unknown'}"),
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
