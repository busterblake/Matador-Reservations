import 'package:flutter/material.dart';
import 'ResturantReservations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: 
          ElevatedButton(
            child: Text(
              'temp Log In',
              style: TextStyle(fontSize: 24.0),
            ),
            onPressed: () {
              goToNewScreen(context);
            },
            ),
          ), 
      
      
    );

   
  }
   void goToNewScreen(BuildContext context){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Resturantreservations()));
    }
}
