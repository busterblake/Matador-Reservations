/// defines the data that will be in the [reservations] list. 
class Reservation{
  /// stores the date for the reservation
  final int date;
  /// stores the time for the reservation
  final int time;
  /// stores the party size for the reservation
  final int size;
  /// stores the table number for the reservation
  final int table;
  /// stores the name for the reservation
  final String name;
  /// stores the phone number for the reservation
  final int number;

  Reservation({
    required this.date,
    required this.time,
    required this.size,
    required this.table,
    required this.name,
    required this.number,
  });
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

List<Reservation> reservations = [
  Reservation(date: 4202025, time: 0100, size: 4, table: 1, name: "Mark", number: 1234567890),
  Reservation(date: 4202025, time: 0200, size: 2, table: 3, name: "Nolan", number: 0987654321),
  Reservation(date: 4212025, time: 0130, size: 4, table: 1, name: "Eve", number: 6574893201)
];