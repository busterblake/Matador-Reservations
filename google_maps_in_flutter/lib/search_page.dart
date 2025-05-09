import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rating/flutter_rating.dart';
import 'package:google_maps_in_flutter/main.dart';
import 'menu_page.dart';

// This is the search page
// This page shows the restaurant cards and the search bar
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// This is the state of the search page
// Gives search functionality and the restaurant data
class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _filteredRestaurants = [];

  // This is called when search page is first switched to
  // Loads the restaurant data and sets up the search functionality
  // Also sets up a listener for the search controller to filter the restaurant list
  // and update the restaurant list accordingly
  @override
  void initState() {
    super.initState();
    loadRestaurants();
    _searchController.addListener(() {
      setState(() {
        _filteredRestaurants = _restaurants.map((restaurant) {
          final isVisible = restaurant['title'] != null &&
              restaurant['title']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
          return {...restaurant, 'isVisible': isVisible};
        }).toList();

        _filteredRestaurants.sort((a, b) {
          if (a['isVisible'] == b['isVisible']) return 0;
          return a['isVisible'] ? -1 : 1;
        });
      });
    });
  }

  // Loads the restaurant data from the json file
  Future<void> loadRestaurants() async {
    final String data = await rootBundle.loadString('lib/Assets/markers.json');
    final List<dynamic> jsonResult = json.decode(data);
    setState(() {
      _restaurants = jsonResult
          .cast<Map<String, dynamic>>()
          .where((restaurant) => restaurant['title'] != null)
          .map((restaurant) => {...restaurant, 'isVisible': true})
          .toList();
      _filteredRestaurants = _restaurants;
    });
  }

  // Dispose of the search controller when the widget is disposed
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // For some reason stacks work bottom to top,
        // so the search bar, although at the bottom
        // of the stack, is on top of the restaurant cards
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: ListView.builder(
              itemCount: _filteredRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];
                return RestaurantCards(restaurant: restaurant);
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.2,
                vertical: MediaQuery.of(context).size.height * 0.07,
              ),
              child: const ShowReserveData(),
            ),
          ),
          Column(children: [SearchBar(searchController: _searchController)]),
        ],
      ),
    );
  }
}

// This is the reservation data card
class ShowReserveData extends StatefulWidget {
  const ShowReserveData({super.key});

  @override
  State<ShowReserveData> createState() => _ShowReserveDataState();
}

// This is the state of the reservation data card
// Loads the reservation data (from main) and updates
// the card when the data changes
class _ShowReserveDataState extends State<ShowReserveData> {
  late Future<Map<String, String>> _reservationData;
  late VoidCallback _reservationListener;

  @override
  void initState() {
    super.initState();
    _loadReservationData();

    // Listen to changes in reservation data
    _reservationListener = () {
      if (!mounted) return;
      _loadReservationData();
    };

    SaveReservationData.reservationChanged.addListener(_reservationListener);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    SaveReservationData.reservationChanged.removeListener(_reservationListener);
    super.dispose();
  }

  // Load the reservation data from the main file
  void _loadReservationData() {
    setState(() {
      _reservationData = SaveReservationData().loadData();
    });
  }

  // Build the reservation data card
  // This card shows the reservation data (time, date, party size)
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[600]!, width: 1.5),
      ),
      child: Center(
        child: FutureBuilder<Map<String, String>>(
          future: _reservationData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No reservation found');
            }
            final data = snapshot.data!;
            final time = data['time'];
            final date = data['date'];
            final partySize = data['partySize'];

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_outline_rounded, size: 18.0),
                const SizedBox(width: 3.0),
                Text(
                  '$partySize • $time • $date',
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Class that produces the restaurant cards
// So many children...
class RestaurantCards extends StatelessWidget {
  const RestaurantCards({super.key, required this.restaurant});

  final Map<String, dynamic> restaurant;

  @override
  Widget build(BuildContext context) {
    // The cards fade in and out when they are filtered
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: restaurant['isVisible'] ? 1.0 : 0.0,
      child: IgnorePointer(
        // IgnorePointer makes card unresponsive when not visible
        ignoring: restaurant['isVisible'] != true,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 2.0,
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  '${restaurant['title']}',
                  style: const TextStyle(fontSize: 18.0),
                ),
                subtitle: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StarRating(
                              rating: restaurant['rating'],
                              size: 18.0,
                              color: Colors.pink,
                              borderColor: Colors.pink,
                              starCount: 5,
                              allowHalfRating: true,
                            ),
                            const SizedBox(width: 5.0),
                            Text('${restaurant['reviews']} reviews'),
                          ],
                        ),
                        Text(restaurant['address']),
                        Text('${restaurant['genre']} • ${restaurant['price']}'),
                        Text(restaurant['seating']),
                      ],
                    ),

                    // Restaurant image
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        // rounded corners
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(
                            restaurant['image'],
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 3.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuPage(restaurant: restaurant),
                      ),
                    );
                  },

                  // Bunch of properties to make the button look nice
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      Colors.white,
                    ),
                    foregroundColor: WidgetStateProperty.all<Color>(
                      Colors.pink,
                    ),
                    minimumSize: WidgetStateProperty.all<Size>(
                      const Size(double.infinity, 45.0),
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 200, 200, 200),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Book Table',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// It's just a search bar
class SearchBar extends StatelessWidget {
  const SearchBar({super.key, required TextEditingController searchController})
      : _searchController = searchController;

  final TextEditingController _searchController;

  // Search bar stuff
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 30.0,
        left: 8.0,
        right: 8.0,
        bottom: 0.0,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Find Restaurants',
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
          ),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    );
  }
}
