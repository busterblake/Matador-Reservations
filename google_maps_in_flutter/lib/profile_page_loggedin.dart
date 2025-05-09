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
  late Future<int> _reservationsCount;

  @override
  void initState() {
    super.initState();
    // Fetch the total number of reservations made by the user
    _reservationsCount = _fetchReservationsCount();
  }

  // Fetches the total number of reservations made by the user from Firestore
  Future<int> _fetchReservationsCount() async {
    final docRef = FirebaseFirestore.instance
      .collection('userinfo')
      .doc(user?.email);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({'reservations': 0});
      return 0;
    }

    return docSnapshot.data()?['reservations'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
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
              'You are logged in as:',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              '${user?.email}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Divider(),
            const Spacer(),
            // Display the total number of reservations made
            FutureBuilder<int>(
              future: _reservationsCount,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text(
                    'Error fetching reservation count.',
                    style: TextStyle(fontSize: 16),
                  );
                }
                final count = snapshot.data ?? 0;
                return Text(
                  'You have made $count reservations using Matador Reservations',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                );
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MatadorResApp()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Logout'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.pink),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}