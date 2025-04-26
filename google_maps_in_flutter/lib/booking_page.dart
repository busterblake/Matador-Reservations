import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
  final reservations = [
      {
        "restaurant": "Matador BBQ Pit",
        "date": "April 30, 2025",
        "time": "7:00 PM",
        "partySize": 4,
        "table": 1
      },
      {
        "restaurant": "The 818 Eatery",
        "date": "May 1, 2025",
        "time": "9:00 AM",
        "partySize": 2,
        "table": 3
      },
      {
        "restaurant": "Northridge Bites",
        "date": "May 2, 2025",
        "time": "12:00 PM",
        "partySize": 3,
        "table": 1
      },
      {
        "restaurant": "Freddy Fazbear's Pizza",
        "date": "May 3, 2025",
        "time": "6:00 PM",
        "partySize": 5,
        "table": 3
      },
      {
        "restaurant": "Beast Burger",
        "date": "May 4, 2025",
        "time": "8:00 PM",
        "partySize": 1,
        "table": 2
      },
      {
        "restaurant": "Giordanacho's",
        "date": "May 5, 2025",
        "time": "7:30 PM",
        "partySize": 2,
        "table": 1
      },
      {
        "restaurant": "Burger",
        "date": "May 6, 2025",
        "time": "5:00 PM",
        "partySize": 3,
        "table": 2
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Reservations"),
      ),
      body: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reservation["restaurant"]}',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text("Date: ${reservation["date"]}"),
                  Text("Time: ${reservation["time"]}"),
                  Text("Party Size: ${reservation["partySize"]}"),
                  Text("Table: ${reservation["table"]}"),
                ],
              ),
            ),
          );
        },
      ),
      
    );
  }
}