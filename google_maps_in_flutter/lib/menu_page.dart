import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';

class MenuPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const MenuPage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    style: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      StarRating(
                        rating: restaurant['rating'],
                        color: Colors.pink,
                        size: 25.0,
                      ),
                      SizedBox(width: 8.0),
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
                  Text(
                    'Menu',
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Divider(
                    color: Colors.grey[500],
                    thickness: 1.0,
                    height: 10.0,
                  ),
                  const SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: restaurant['menu'].length,
                    itemBuilder: (context, index) {
                      final menuItem = restaurant['menu'][index];
                      return ListTile(
                        title: Text(menuItem['name']),
                        subtitle: Text(menuItem['description']),
                        trailing: Text('\$${menuItem['price']}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
