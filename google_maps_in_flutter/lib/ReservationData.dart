class Reservation{
  final int date;
  final int time;
  final int size;
  final int table;
  final String name;
  final int number;

  Reservation({
    required this.date,
    required this.time,
    required this.size,
    required this.table,
    required this.name,
    required this.number,
  });
}

List<Reservation> reservations = [
  Reservation(date: 4202025, time: 0100, size: 4, table: 1, name: "Mark", number: 1234567890),
  Reservation(date: 4202025, time: 0200, size: 2, table: 3, name: "Nolan", number: 0987654321),
  Reservation(date: 4212025, time: 0130, size: 4, table: 1, name: "Eve", number: 6574893201)
];