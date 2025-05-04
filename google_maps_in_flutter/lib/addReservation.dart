import 'package:flutter/material.dart';
import 'ResturantReservations.dart';

class Addreservation extends StatelessWidget {
  const Addreservation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Restruant Add Reservations',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
