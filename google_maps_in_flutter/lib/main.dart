import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile_page.dart';
import 'booking_page.dart';
import 'search_page.dart';
import 'package:quickalert/quickalert.dart';
import 'package:calendar_day_slot_navigator/calendar_day_slot_navigator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matador Reservation App',
      debugShowCheckedModeBanner: false,
      home: BottomBarExample(),
    );
  }
}

class BottomBarExample extends StatefulWidget {
  @override
  _BottomBarExampleState createState() => _BottomBarExampleState();
}

class _BottomBarExampleState extends State<BottomBarExample> {
  int _currentIndex = 0; // Start with Home/maps
  String time = '';
  String partySize = '';
  DateTime? dateSelected;

  String temptime = '';
  String temppartySize = '';
  DateTime? tempdateSelected;

  final PageController _pageController = PageController(initialPage: 0);
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(34.240547308790596, -118.52942529186363);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.pink),
        onPressed: () {
          // this is where you add the screen to make reservations
          // when you press the + button
          QuickAlert.show(
            context: context,
            type: QuickAlertType.custom,
            barrierDismissible: true,
            confirmBtnText: 'Save',
            widget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Picker
                CalendarDaySlotNavigator(
                  slotLength: 4,
                  dayBoxHeightAspectRatio: 5,
                  dayDisplayMode: DayDisplayMode.outsideDateBox,
                  isGradientColor: true,
                  activeGradientColor: LinearGradient(
                    colors: [Color(0xffb644ae), Color(0xff873999)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  monthYearTabBorderRadius: 15,
                  dayBoxBorderRadius: 10,
                  headerText: "Select a Date",
                  fontFamilyName: "Roboto",
                  isGoogleFont: true,
                  dayBorderWidth: 0.5,
                  onDateSelect: (selectedDate) {
                    dateSelected = selectedDate;
                    tempdateSelected = selectedDate;
                  },
                ),
                const SizedBox(height: 10),
                // time Feild
                TextFormField(
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Select Time',
                    prefixIcon: Icon(Icons.schedule_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => ((temptime = value), (time = value)),
                ),
                const SizedBox(height: 10),

                // Party Size Input
                TextFormField(
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Enter Party Size',
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  onChanged:
                      (value) => ((temppartySize = value), (partySize = value)),
                ),
              ],
            ),
            onConfirmBtnTap: () async {
              if (temptime.isEmpty ||
                  temppartySize.isEmpty ||
                  tempdateSelected == null) {
                await QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  text: 'Please fill all fields.',
                );
                return;
              } else {
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 500));
                await QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text:
                      "Booking saved!\nTime: $time\nParty Size: $partySize\nDate: ${dateSelected!.toLocal().toString().split(' ')[0]}",
                );
                temptime = '';
                temppartySize = '';
                tempdateSelected = null;
                return;
              }
              ;
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(iconStyle: IconStyle.Default),
        hasNotch: true,
        fabLocation: StylishBarFabLocation.center,
        notchStyle: NotchStyle.circle,
        currentIndex: _currentIndex,
        items: [
          BottomBarItem(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            title: const Text('Home'),
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
            icon: const Icon(Icons.book_online_outlined),
            selectedIcon: const Icon(Icons.book_online),
            title: const Text('Bookings'),
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
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          //pages go in order 0-3 for the bottom bar
          //right now only the maps page works
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 16.0),
            markers: {
              Marker(
                markerId: const MarkerId('Matador 1'),
                position: const LatLng(34.23796594969169, -118.53662856651358),
                onTap: () {
                  // custom pop up ontainer for the marker
                  //should show the restraunt info with a button to make a reservation
                  //temp will nbe the info popup
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.info,
                    text: 'Temp info for Matador 1',
                    confirmBtnText: "Book Now",
                    onConfirmBtnTap: () {
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.success,
                        text: 'Reservation made!',
                      );
                    },
                  );
                },
              ),
              Marker(
                markerId: const MarkerId('Matador 2'),
                position: const LatLng(34.23982826085725, -118.52539003612064),
                infoWindow: const InfoWindow(
                  title: 'Matador 2 info',
                  snippet: 'This is a snippet',
                ),
              ),
              Marker(
                markerId: const MarkerId('Matador 3'),
                position: const LatLng(34.24131729261727, -118.5296862650247),
                infoWindow: const InfoWindow(
                  title: 'Matador 3 info',
                  snippet: 'This is a snippet',
                ),
              ),
            },
          ),

          // this is where you would add the other pages for the bottom bar
          //right now it just makes the page say what you clicked on only the maps page works
          const SearchPage(), // Index 1
          const BookingPage(), // Index 2
          const ProfilePage(), // Index 3
        ],
      ),
    );
  }
}

class saveReservationData {
  //used to save data to user prefts
}

class loadReservationData {
  //used to load data from user prefs
}
