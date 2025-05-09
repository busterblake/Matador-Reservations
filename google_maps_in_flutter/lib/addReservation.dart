/// The Add reservation class allows the restaurant to manually add a Reservation to their Reservation list
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Allows restaurant to Manualy add a reservation to their [reservations] list
/// 
/// This Class will:
///  1. Ask for enrty in all feilds
///  2. at the click of a button the reservation is added to the List 
class Addreservation extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  const Addreservation({super.key, required this.restaurant});

  @override
  State<Addreservation> createState() => AddreservationState();

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);

  /// @nodoc
  @override
  int get hashCode => super.hashCode;

  /// @nodoc
  @override
  bool operator ==(Object other) => identical(this, other);
}

class AddreservationState extends State<Addreservation> {
  final key = GlobalKey<FormState>();

  final name = TextEditingController();
  final time = TextEditingController();
  final table = TextEditingController();
  final addDate = TextEditingController();
  final size = TextEditingController();

  /// allows Resturaunt to Add a reservation to their [reservations]
  /// 
  /// Resturanunt must add a name, time, table number, and party size
  /// Once they click "Add Reservation" the reservation gets added to Firestore
  /// and is displayed in the [Resturantreservations] page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Reservation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: key,
          child: ListView(
            children: [
              TextFormField(
                controller: name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (val) => val!.isEmpty ? "Enter a name: " : null,
              ),
              TextFormField(
                controller: time,
                decoration: InputDecoration(labelText: 'Time (24hr)'),
                validator: (val) => val!.isEmpty ? "Enter a Time: " : null,
              ),
              TextFormField(
                controller: table,
                decoration: InputDecoration(labelText: 'Table #'),
                validator: (val) => val!.isEmpty ? "Enter a Table #: " : null,
              ),
              TextFormField(
                controller: addDate,
                decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                validator: (val) => val!.isEmpty ? "Enter a Date: " : null,
              ),
              TextFormField(
                controller: size,
                decoration: InputDecoration(labelText: 'Party size'),
                validator: (val) => val!.isEmpty ? "Enter a Party Size: " : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitReservation,
                child: Text('Add Reservation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Send the new reservation to Firestore under the restaurant's document
  void submitReservation() async {
    if (key.currentState!.validate()) {
      final String restaurantId = widget.restaurant['id'];
      final reservationId = FirebaseFirestore.instance
          .collection('reservations')
          .doc(restaurantId)
          .collection('data')
          .doc()
          .id;

      final reservation = {
        'name': name.text,
        'time': time.text,
        'date': addDate.text,
        'partySize': size.text,
        'tableId': "Table ${table.text}",
        'restaurantId': restaurantId,
        'userId': "manual",
        'email': "manual@entry.com", // dummy email
      };

      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(restaurantId)
          .set({reservationId: reservation}, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation added!')),
      );
      Navigator.pop(context, true);
    }
  }

  /// @nodoc
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);

  /// @nodoc
  @override
  int get hashCode => super.hashCode;

  /// @nodoc
  @override
  bool operator ==(Object other) => identical(this, other);
}
