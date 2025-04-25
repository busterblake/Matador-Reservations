import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'reserve_page.dart';

class MenuPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const MenuPage({super.key, required this.restaurant});

@override
Widget build(BuildContext context) {
  return Scaffold(
    extendBody: true,
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            restaurant['image'],
            fit: BoxFit.cover,
            width: double.infinity,
            height: 350.0,
            alignment: Alignment.topCenter,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant['title'],
                  style: const TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    StarRating(
                      rating: restaurant['rating'],
                      color: Colors.pink,
                      size: 25.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      '${restaurant['reviews']} reviews',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  restaurant['address'],
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${restaurant['genre']} • ${restaurant['price']}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 2.0),
                Text(
                  restaurant['seating'],
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 5.0),
                Divider(
                  color: Colors.grey[500],
                  thickness: 1.0,
                  height: 10.0,
                ),
                Text(
                  restaurant['summary'],
                  style: const TextStyle(fontSize: 24.0),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  'Menu',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Divider(
                  color: Colors.grey[500],
                  thickness: 1.0,
                  height: 10.0,
                ),
                const SizedBox(height: 8.0),
                ...menuList(),
                const SizedBox(height: 70.0),
              ],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () {
              // TODO: If reservation is made, navigate to the reservation page.
              // Otherwise, pop up reservation pop-up

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservePage(restaurant: restaurant),
                  ),
                );
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.pink),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
              minimumSize: WidgetStateProperty.all<Size>(const Size(double.infinity, 50.0)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: const BorderSide(color: Colors.pink, width: 2.0),
                ),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          )
        ),
      ),
    ),
  );
}

  // Method generates the menu items for each reastaurant.
  List<Widget> menuList() {
    return List.generate(
      restaurant['menu'].length,
      (index) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
        // Name and price in the same row
        Row(
          children: [
          Text(
            restaurant['menu'][index]['name'],
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '\$${restaurant['menu'][index]['price']}',
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          ],
        ),

        // Description + Divider
        Text(
          restaurant['menu'][index]['description'],
          style: const TextStyle(fontSize: 16.0),
        ),
        Divider(
          color: Colors.grey[500],
          thickness: 1.0,
          height: 12.0,
        ),
        ],
      );
      },
    );
  }
}