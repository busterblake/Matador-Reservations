import 'package:flutter/material.dart';

class Addreservation extends StatefulWidget {
  const Addreservation({super.key});

  @override
  State<Addreservation> createState() => AddreservationState();
}

class AddreservationState extends State<Addreservation> {
  final key = GlobalKey<FormState>();

  final name = TextEditingController();
  final time = TextEditingController();
  final table = TextEditingController();
  final number = TextEditingController();
  final date = TextEditingController();
  final size = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(key: key, child: ListView()),
      ),
    );
  }
}
