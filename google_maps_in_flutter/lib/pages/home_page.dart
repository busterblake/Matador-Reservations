import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_in_flutter/auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  HomePage({super.key});


  final User? user = Auth().currentUser;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Widget _title(){
    return const Text('Firebase Auth');
  }

  Widget _userId(){
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton(){
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _userId(),
              _signOutButton(),
            ],
          ), 
        ),
    );
  }
}