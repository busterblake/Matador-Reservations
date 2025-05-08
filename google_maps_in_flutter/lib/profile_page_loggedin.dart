import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_in_flutter/main.dart';

class ProfilePageLoggedIn extends StatefulWidget {
  const ProfilePageLoggedIn({super.key});

  @override
  State<ProfilePageLoggedIn> createState() => _ProfilePageLoggedInState();
}

class _ProfilePageLoggedInState extends State<ProfilePageLoggedIn> {
  final user = FirebaseAuth.instance.currentUser;
  late Future<List<Map<String, dynamic>>> _userReservations;

  // Simulate loading from markers.json — replace with real file read if needed
  final Map<String, Map<String, String>> restaurantInfoMap = {
    "matadorBbqPit": {
      "title": "Matador BBQ Pit",
      "address": "18111 Nordhoff St, Northridge"
    },
    "the818Eatery": {
      "title": "The 818 Eatery",
      "address": "18123 Nordhoff St, Northridge"
    },
    "northridgeBites": {
      "title": "Northridge Bites",
      "address": "18127 Zelzah Ave, Northridge"
    },
    "freddyFazbearsPizza": {
      "title": "Freddy Fazbear's Pizza",
      "address": "18000 Nordhoff St, Northridge"
    },
    "beastBurger": {
      "title": "Beast Burger",
      "address": "18103 Nordhoff St, Northridge"
    },
    "giordanachos": {
      "title": "Giordanacho's",
      "address": "18401 Nordhoff St, Northridge"
    }
  };

  @override
  void initState() {
    super.initState();
    _userReservations = _fetchUserReservations();
  }

  Future<List<Map<String, dynamic>>> _fetchUserReservations() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: user?.uid)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
  // For firebase to read the time from the databse in "MM/DD/YYYY at HH:MM AM/PM" format
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
// include this too for firebase to read the time
String _formatTime(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute $ampm';
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
                            style: TextStyle(fontSize: 16)));
                  }

                  final reservations = snapshot.data!;
                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      final restaurantId = reservation['restaurantId'];
                      final tableId = reservation['tableId'] ?? 'N/A';
                      final time = reservation['date'] ?? 'Time not set';

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
                              Text('Time: ${_formatTimestampToReadable(time)}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('reservations')
                                  .doc(reservation['id'])
                                  .delete();
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
