/// The Add reservation class allows the restaurant to manually add a Reservation to their Reservation list
import 'package:flutter/material.dart';
import 'ResturantReservations.dart';
import 'ReservationData.dart';
//firebase 
import 'package:cloud_firestore/cloud_firestore.dart';

/// Allows restaurant to Manualy add a reservation to their [reservations] list
/// 
/// This Class will:
///  1. Ask for enrty in all feilds
///  2. at the click of a button the reservation is added to the List 
class Addreservation extends StatefulWidget{
  final String restaurantId; // needed to pass reservation

  const Addreservation({super.key, required this.restaurantId});

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

class AddreservationState extends State<Addreservation>{
  final key = GlobalKey<FormState>();

  final name = TextEditingController();
  final time = TextEditingController();
  final table = TextEditingController();
  final addDate = TextEditingController();
  final size = TextEditingController();

  /// allows Resturaunt to Add a reservation to their [reservations]
  /// 
  /// Resturanunt must add a name time, table number, and party size
  /// Once they click "Add Reservation" the reservation gets added to the Firestore
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
                decoration: InputDecoration(labelText: 'Time (HH:mm) 24hr format'),
                validator: (val) => val!.isEmpty ? "Enter a Time: " : null,
              ),
              TextFormField(
                controller: table, 
                decoration: InputDecoration(labelText: 'Table #'),
                validator: (val) => val!.isEmpty ? "Enter a Table #: " : null,
              ),
              TextFormField(
                controller: addDate, 
                decoration: InputDecoration(labelText: 'Date (yyyy-MM-dd)'),
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

  /// Send the new reservation to Firestore under 'reservations'
  void submitReservation() async {
    if (key.currentState!.validate()) {
      try {
        // Combine date and time into one DateTime object
        final DateTime dateTime = DateTime.parse("${addDate.text} ${time.text}");

        // Add to Firestore
        await FirebaseFirestore.instance.collection('reservations').add({
          'restaurantId': widget.restaurantId,
          'tableId': int.parse(table.text),
          'userId': 'manual', // You could use admin ID if desired
          'name': name.text,
          'partySize': int.parse(size.text),
          'date': Timestamp.fromDate(dateTime),
          'duration': 30, // default duration
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation added!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
