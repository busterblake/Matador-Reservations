/// The Add reservation class allows the restaurant to manually add a Reservation to their Reservation list
import 'package:flutter/material.dart';
import 'ResturantReservations.dart';
import 'ReservationData.dart';

/// Allows restaurant to Manualy add a reservation to their [reservations] list
/// 
/// This Class will:
///  1. Ask for enrty in all feilds
///  2. at the click of a button the reservation is added to the List 
class Addreservation extends StatefulWidget{


  const Addreservation({super.key});

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
  final number = TextEditingController();
  final addDate = TextEditingController();
  final size = TextEditingController();
  /// allows Resturaunt to Add a reservation to their [reservations]
  /// 
  /// Resturanunt must add a name time, table number, phone number, and party size
  /// Once they click "Add Reservation" the reservation gets added to the list and
  /// is displayed in the [Resturantreservations] page
  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Reservation")),
      body: Padding(
        padding: const 
        EdgeInsets.all(16.0),
          child: Form(
            key: key,
            child: ListView(
              children: [
                TextFormField(
                  controller: 
                    name, 
                      decoration: InputDecoration(labelText: 'Name'),
                      validator:  (val) => val!.isEmpty ? "Enter a name: " : null,),
                TextFormField(
                  controller: 
                    time, 
                      decoration: InputDecoration(labelText: 'Time'),
                      validator:  (val) => val!.isEmpty ? "Enter a Time: " : null,),
                TextFormField(
                  controller: 
                    table, 
                      decoration: InputDecoration(labelText: 'Table #'),
                      validator:  (val) => val!.isEmpty ? "Enter a Table #: " : null,),
                TextFormField(
                  controller: 
                    number, 
                      decoration: InputDecoration(labelText: 'Phone #'),
                      validator:  (val) => val!.isEmpty ? "Enter a Phone #: " : null,),
                TextFormField(
                  controller: 
                    addDate, 
                      decoration: InputDecoration(labelText: 'Date'),
                      validator:  (val) => val!.isEmpty ? "Enter a name: " : null,),
                TextFormField(
                  controller: 
                    size, 
                      decoration: InputDecoration(labelText: 'Party size'),
                      validator:  (val) => val!.isEmpty ? "Enter a name: " : null,),
                SizedBox(height: 20),
                ElevatedButton(onPressed: submitReservation, child: Text('Add Reservation'),),
              ],
            ),
          ),
          )
    );
    }
    /// Send the new reservation to the list of [reservations]
    void submitReservation(){
      if (key.currentState!.validate()){
        reservations.add(Reservation(
          date: int.parse(addDate.text),
          time: int.parse(time.text),
          size: int.parse(size.text),
          table: int.parse(table.text),
          name: name.text,
          number:  int.parse(number.text)),
        );
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

