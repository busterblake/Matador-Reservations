import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile_page.dart';
import 'booking_page.dart';
import 'search_page.dart';
import 'package:quickalert/quickalert.dart'; // import for QuickAlerts
import 'package:calendar_day_slot_navigator/calendar_day_slot_navigator.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'custom_time_picker.dart';
import 'menu_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matador Reservation App',
      debugShowCheckedModeBanner: false,
      home: MatadorResApp(),
    );
  }
}


class MatadorResApp extends StatefulWidget {
  const MatadorResApp({super.key});

  @override
  _MatadorResApp createState() => _MatadorResApp();
}


class _MatadorResApp extends State<MatadorResApp> {
  int _currentIndex = 0; // Start with Home/maps
  TimeOfDay? time;
  String partySize = '';
  DateTime? dateSelected;


  TimeOfDay? temptime;
  String temppartySize = '';
  DateTime? tempdateSelected;


  TimeOfDay? selectedTime;


  final LatLng _center = const LatLng(34.240547308790596, -118.52942529186363);
  final Map<String, Marker> _markerMap = {};
  Set<Marker> _markers = {};


  final List<Map<String, dynamic>> _restaurants = [];
  final List<Map<String, dynamic>> _filteredRestaurants = [];


  @override
  void initState() {
    super.initState();
    _loadMarkersFromJson();
  }


  Future<void> _loadMarkersFromJson() async {
    final String data = await rootBundle.loadString('lib/Assets/markers.json');
    final List<dynamic> jsonResult = json.decode(data);

Set<Marker> loadedMarkers =
    jsonResult.map((markerData) {
      final restaurantId = markerData['restaurantId'];
      final markerId = markerData['id'];

      return Marker(
        markerId: MarkerId(markerId),
        position: LatLng(markerData['lat'], markerData['lng']),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
        onTap: () {
          // This is optional but can be used to pass restaurantId to reservation form
          QuickAlert.show(
            context: context,
            type: QuickAlertType.info,
            title: markerData['title'],
            text: markerData['description'],
            customAsset: markerData['image'],
            confirmBtnText: "View Menu",
            confirmBtnColor: Colors.pink,
            onConfirmBtnTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuPage(restaurant: markerData),
                ),
              );
            },
          );
        },
      );
    }).toSet();



    setState(() {
      _markers = loadedMarkers;
    });
  }


  //call this funtions to disable the marker if unavailable
  void disablemarker(String markerId) {
    final updatedMarkers =
        _markers.map((marker) {
          if (marker.markerId.value == markerId) {
            return marker.copyWith(
              iconParam: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
            );
          }
          return marker;
        }).toSet();


    setState(() {
      _markers = updatedMarkers;
    });
  }

 void checkmarkers() async {
  if (temptime == null || tempdateSelected == null) return;

  final DateTime selectedDateTime = DateTime(
    tempdateSelected!.year,
    tempdateSelected!.month,
    tempdateSelected!.day,
    temptime!.hour,
    temptime!.minute,
  );

  final snapshot = await FirebaseFirestore.instance
      .collection('reservations')
      .where('restaurantId', isEqualTo: 'matadorBbqPit') // filter by current restaurant
      .get();

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final DateTime reservationStart = (data['date'] as Timestamp).toDate();
    final int duration = data['duration'] ?? 30;
    final DateTime reservationEnd = reservationStart.add(Duration(minutes: duration));
    final int tableId = data['tableId'];

    // Only block if requested time overlaps
    if (selectedDateTime.isAfter(reservationStart) &&
        selectedDateTime.isBefore(reservationEnd)) {
      final markerId = 'table$tableId'; // You must match this to how your markers are named
      disablemarker(markerId);
    }
  }
}



  final PageController _pageController = PageController(initialPage: 0);
  late GoogleMapController mapController;


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
                    setState(() {
                      dateSelected = selectedDate;
                      tempdateSelected = dateSelected;
                    });
                  },
                ),
            
                const SizedBox(height: 30),
                // Time Picker
                CustomTimePicker(
                  selectedTime: selectedTime,
                  onTimeSelected: (thistime) {
                    setState(() {
                      selectedTime = thistime;
                      temptime = selectedTime;
                      time = thistime;
                    });
                    //Navigator.pop(context);
                  },
                ),


                const SizedBox(height: 30),


                // Party Size Input
                TextFormField(
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    hintText: 'Enter Ppparty Size',
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
            if (temptime == null || temppartySize.isEmpty || tempdateSelected == null) {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.error,
                title: 'Error',
                text: 'Please fill in all fields.',
              );
              return;
            } else {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance.collection('reservations').add({
            

                  'userID': user.uid,
                  'email' : user?.email,
                  'restaurantId': 'matadorBbqPit',  // needs to be changed to a var
                  'partySize': partySize,
                  'time': selectedTime!.format(context),
                  'date': dateSelected!.toIso8601String(),
                  'table' : 'Test Table 1',
                  'duration': 30 // default duration
                });
              
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  title: 'Success',
                  text: 'Reservation made for $partySize people at ${selectedTime!.format(context)} on ${dateSelected!.toLocal()}',
                );
              } else {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  title: 'Error',
                  text: 'User not logged in.',
                );
              }
            }
            },
          );
        },
      ),
      // + button
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
            myLocationEnabled: true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 16.0),
            markers: _markers,
            myLocationButtonEnabled: true,
            //zoomControlsEnabled: true,
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


class SaveReservationData {
  //used to save data to user prefts
}


class LoadReservationData {
  //used to load data from user prefs
}





