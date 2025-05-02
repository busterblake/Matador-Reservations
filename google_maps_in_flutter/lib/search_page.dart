import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rating/flutter_rating.dart';
import 'menu_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _restaurants = [];
  List<Map<String, dynamic>> _filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _searchController.addListener(() {
      setState(() {
        _filteredRestaurants = _restaurants.map((restaurant) {
          final isVisible = restaurant['title'] != null &&
              restaurant['title']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
          return {
            ...restaurant,
            'isVisible': isVisible, // Add visibility property
          };
        }).toList();
      });
    });
  }

  Future<void> _loadRestaurants() async {
    final String data = await rootBundle.loadString('lib/Assets/markers.json');
    final List<dynamic> jsonResult = json.decode(data);
    setState(() {
      _restaurants = jsonResult
          .cast<Map<String, dynamic>>()
          .where((restaurant) => restaurant['title'] != null)
          .map((restaurant) => {
            ...restaurant,
            'isVisible': true,
          })
          .toList();
      _filteredRestaurants = _restaurants;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:
        Column(
          children: [
            SearchBar(searchController: _searchController),

            Expanded(
              child: ListView.builder(
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  return RestaurantCards(restaurant: restaurant);
                },
              ),
            )
          ],
        ),
    );
  }
}

class RestaurantCards extends StatelessWidget {
  const RestaurantCards({
    super.key,
    required this.restaurant,
  });

  final Map<String, dynamic> restaurant;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: restaurant['isVisible'] ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: restaurant['isVisible'] != true,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 2.0,
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                title: Text('${restaurant['title']}', style: const TextStyle(fontSize: 18.0)),
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
                    )
                  ],
                )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle button press
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuPage(restaurant: restaurant),
                      ),
                    );                  
                  },
                  
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.pink),
                    minimumSize: WidgetStateProperty.all<Size>(const Size(double.infinity, 45.0)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Color.fromARGB(255, 200, 200, 200), width: 1.5),
                      ),
                    ),
                  ),
                  child: const Text('Book Now', style: TextStyle(fontSize: 16.0)),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required TextEditingController searchController,
  }) : _searchController = searchController;

  final TextEditingController _searchController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 8.0, right: 8.0, bottom: 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Find Restaurants',
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _searchController.clear(),
          ),
          
          prefixIcon: Icon(Icons.search),
        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          )
        )
      )
    );
  }
}