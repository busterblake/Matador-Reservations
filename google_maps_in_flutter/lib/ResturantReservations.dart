import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'ReservationData.dart';
import 'addReservation.dart';
import 'search_page.dart';
import 'profile_page.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Resturantreservations extends StatefulWidget {
  const Resturantreservations({super.key});

  @override
  State<Resturantreservations> createState() => ResturantReservationState();
}

class ResturantReservationState extends State<Resturantreservations> {
  int myIndex = 0;
  List<Reservation> data = List.from(reservations);
  final PageController _pageController = PageController(initialPage: 0);

  final String restaurantId = "matador1"; // Replace with login logic if needed

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getRestaurantById(String id) async {
    final String jsonString = await rootBundle.loadString(
      'lib/Assets/markers.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);

    return jsonData.cast<Map<String, dynamic>>().firstWhere(
      (restaurant) => restaurant['id'] == id,
      orElse: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restaurant Reservations")),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: () async {
          final restaurant = await getRestaurantById(restaurantId);

          if (restaurant == null || restaurant.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Restaurant not found.')),
            );
            return;
          }

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Addreservation(restaurant: restaurant),
            ),
          );

          if (result == true) {
            // Refresh local data (replace with Firebase in future)
            setState(() {
              data = List.from(reservations);
            });
          }
        },
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(iconStyle: IconStyle.Default),
        hasNotch: true,
        items: [
          BottomBarItem(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            title: const Text('Bookings'),
            selectedColor: Colors.pink,
            unSelectedColor: Colors.grey,
          ),
          BottomBarItem(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            title: const Text('Search'),
            selectedColor: Colors.pink,
            unSelectedColor: Colors.grey,
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            title: const Text('Profile'),
            selectedColor: Colors.pink,
            unSelectedColor: Colors.grey,
          ),
        ],
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Center(child: tableUI()), // Index 0: Bookings
          const SearchPage(), // Index 1: Search
          const ProfilePage(), // Index 2: Profile
        ],
      ),
    );
  }

  Widget tableUI() {
    return SafeArea(
      child: SizedBox.expand(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columnSpacing: 10,
              columns: createColumns(),
              rows: createRows(),
              dataRowMinHeight: 40,
              dataRowMaxHeight: 50,
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> createColumns() {
    return [
      DataColumn(label: Text("Date", textAlign: TextAlign.center)),
      DataColumn(label: Text("Time", textAlign: TextAlign.center)),
      DataColumn(label: Text("Size", textAlign: TextAlign.center)),
      DataColumn(label: Text("Table", textAlign: TextAlign.center)),
      DataColumn(label: Text("Name", textAlign: TextAlign.center)),
    ];
  }

  List<DataRow> createRows() {
    return data.map((e) {
      return DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 55,
              child: FittedBox(child: Text(e.date.toString())),
            ),
          ),
          DataCell(
            SizedBox(
              width: 40,
              child: FittedBox(child: Text(e.time.toString())),
            ),
          ),
          DataCell(
            SizedBox(
              width: 30,
              child: FittedBox(child: Text(e.size.toString())),
            ),
          ),
          DataCell(
            SizedBox(
              width: 30,
              child: FittedBox(child: Text(e.table.toString())),
            ),
          ),
          DataCell(SizedBox(width: 60, child: FittedBox(child: Text(e.name)))),
        ],
      );
    }).toList();
  }
}
