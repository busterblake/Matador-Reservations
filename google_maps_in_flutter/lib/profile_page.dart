import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page_loggedin.dart';


class ProfilePage extends StatelessWidget {
 const ProfilePage({super.key});


 Future<void> initializeFirebaseIfNeeded() async {
   if (Firebase.apps.isEmpty) {
     await Firebase.initializeApp();
   }
 }


 Future<void> handleLogin(String email, String password, BuildContext context) async {
   try {
     await initializeFirebaseIfNeeded();
     await FirebaseAuth.instance.signInWithEmailAndPassword(
       email: email.trim(),
       password: password,
     );


     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => const ProfilePageLoggedIn()),
     );
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
     await initializeFirebaseIfNeeded();
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
   final emailController = TextEditingController();
   final passwordController = TextEditingController();


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



