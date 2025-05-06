import 'package:google_maps_in_flutter/auth.dart';
import 'package:google_maps_in_flutter/pages/home_page.dart';
import 'package:google_maps_in_flutter/pages/login_register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class WidgetTree extends StatefulWidget {
 const WidgetTree({super.key});


 @override
 State<WidgetTree> createState() => _WidgetTreeState();
}


class _WidgetTreeState extends State<WidgetTree> {
 @override
 Widget build(BuildContext context) {
   return StreamBuilder<User?>(
     stream: Auth().authStateChanges,
     builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
         return const Center(child: CircularProgressIndicator());
       } else if (snapshot.hasData) {
         return HomePage();
       } else {
         return const LoginPage();
       }
     },
   );
 }
}

