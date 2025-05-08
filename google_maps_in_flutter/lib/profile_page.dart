import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_in_flutter/ReservationSearch.dart';
import 'profile_page_loggedin.dart';

// added for json/restaurant email check
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<bool> isRestaurantEmail(String email) async {
    final String jsonString = await rootBundle.loadString('lib/Assets/markers.json');
    final List<dynamic> markers = json.decode(jsonString);
    return markers.any((marker) => marker['email'] == email);
  }

  Future<Map<String, dynamic>?> getRestaurantEmail(String email) async {
    final String jsonString = await rootBundle.loadString('lib/Assets/markers.json');
    final List<dynamic> markers = json.decode(jsonString);
    return markers.cast<Map<String, dynamic>>().firstWhere(
      (marker) => marker['email'] == email,
      orElse: () => {},
    );
  }

  Future<void> _checkLoginStatus() async {
    await Firebase.initializeApp();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User already logged in -> directly go to logged-in page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePageLoggedIn()),
      );
    }
  }

  Future<void> handleLogin(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final isRestaurant = await isRestaurantEmail(email.trim());

      if (isRestaurant) {
        final restaurant = await getRestaurantEmail(email.trim());

        if (restaurant != null) {
          // Proceed to ReservationSearch if restaurant data is valid
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationSearch(restaurant: restaurant),
            ),
          );
        } else {
          // Handle missing restaurant data
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('No restaurant data found for this email.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePageLoggedIn()),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  Future<void> handleSignUp(String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePageLoggedIn()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Up Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    handleSignUp(
                      emailController.text,
                      passwordController.text,
                      context,
                    );
                  },
                  child: const Text('Sign Up'),
                ),
                ElevatedButton(
                  onPressed: () {
                    handleLogin(
                      emailController.text,
                      passwordController.text,
                      context,
                    );
                  },
                  child: const Text('Login'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
