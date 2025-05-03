import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'reserve_page.dart';
import 'custom_time_picker.dart'; // Make sure this is imported

class MenuPage extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const MenuPage({super.key, required this.restaurant});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              widget.restaurant['image'],
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
                    widget.restaurant['title'],
                    style: const TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      StarRating(
                        rating: widget.restaurant['rating'],
                        color: Colors.pink,
                        size: 25.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '${widget.restaurant['reviews']} reviews',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    widget.restaurant['address'],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    '${widget.restaurant['genre']} • ${widget.restaurant['price']}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    widget.restaurant['seating'],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 10.0),
                  Divider(color: Colors.grey[500], thickness: 1.0),
                  Text(
                    widget.restaurant['summary'],
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  const SizedBox(height: 20.0),

                  const Text(
                    'Select a Time',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),

                  // Custom Time Picker
                  CustomTimePicker(
                    selectedTime: selectedTime,
                    onTimeSelected: (time) {
                      setState(() {
                        selectedTime = time;
                      });
                    },
                  ),
                  const SizedBox(height: 20.0),

                  const Text(
                    'Menu',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Divider(color: Colors.grey[500], thickness: 1.0),
                  ...menuList(),

                  const SizedBox(height: 100.0),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );

              if (pickedDate == null || selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select both a date and a time.')),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservePage(
                    restaurant: widget.restaurant,
                    selectedDate: pickedDate,
                    selectedTime: selectedTime!,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(color: Colors.pink, width: 2.0),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> menuList() {
    return List.generate(
      widget.restaurant['menu'].length,
      (index) {
        final item = widget.restaurant['menu'][index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '\$${item['price']}',
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              item['description'],
              style: const TextStyle(fontSize: 16.0),
            ),
            Divider(color: Colors.grey[500], thickness: 1.0, height: 12.0),
          ],
        );
      },
    );
  }
}
