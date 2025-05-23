import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rating/flutter_rating.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile_page.dart';
import 'booking_page.dart';
import 'menu_page.dart';
import 'search_page.dart';
import 'package:quickalert/quickalert.dart'; // import for QuickAlerts
import 'package:calendar_day_slot_navigator/calendar_day_slot_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'custom_time_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // name was causing me errors loading firebase
    // name: "res",
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  int currentIndex = 0; // Start with Home/maps
  TimeOfDay? time;
  String partySize = '';
  DateTime? dateSelected;

  TimeOfDay? temptime;
  String temppartySize = '';
  DateTime? tempdateSelected;

  TimeOfDay? selectedTime;

  final LatLng _center = const LatLng(34.240547308790596, -118.52942529186363);
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
          return Marker(
            markerId: MarkerId(markerData['id']),
            position: LatLng(markerData['lat'], markerData['lng']),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet,
            ),
            onTap: () {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.custom,
                customAsset: markerData['image'],
                title: markerData['title'],
                titleAlignment: TextAlign.start,
                widget: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        StarRating(
                          rating: markerData['rating'],
                          size: 16.0,
                          color: Colors.pink,
                          borderColor: Colors.pink,
                          starCount: 5,
                          allowHalfRating: true,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          '${markerData['reviews']} reviews',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Text(markerData['address'], style: TextStyle(fontSize: 16)),
                    Text(
                      '${markerData['genre']} • ${markerData['price']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(markerData['seating'], style: TextStyle(fontSize: 16)),
                    Divider(),
                    Text(markerData['summary'], style: TextStyle(fontSize: 18)),
                  ],
                ),
                confirmBtnColor: Colors.pink,
                confirmBtnText: '             Book Table             ',
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

  //call this function to enable the marker if available
  void enablemarker(String markerId) {
    final updatedMarkers =
        _markers.map((marker) {
          if (marker.markerId.value == markerId) {
            return marker.copyWith(
              iconParam: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              ),
            );
          }
          return marker;
        }).toSet();

    setState(() {
      _markers = updatedMarkers;
    });
  }

  void checkMarkers() async {
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection(
      'restaurant list',
    ); // Make sure it the right name of the collection

    final querySnapshot = await collectionRef.get();

    final dateString =
        dateSelected!.toLocal().toString().split(' ')[0]; // e.g., "2025-05-06"
    final timeString = time!.format(context); // e.g., "11:00 AM"

    for (var doc in querySnapshot.docs) {
      //gets the restaurant id from the marker
      final restaurantId = doc.id;
      //gets the data from the firebase document
      final data = doc.data();

      if (data.containsKey(dateString)) {
        final timeMap = data[dateString];

        if (timeMap is Map<String, dynamic> &&
            timeMap.containsKey(timeString)) {
          final timeEntry = timeMap[timeString];
          int available = 0;

          if (timeEntry is Map<String, dynamic> &&
              timeEntry.containsKey("available")) {
            final availableValue = timeEntry["available"];
            available = availableValue;
          }
          // if the available value is 0, disable the marker
          // else enable the marker
          if (available <= 0) {
            disablemarker(restaurantId);
          } else {
            enablemarker(restaurantId);
          }
          continue;
        }
      }
      enablemarker(restaurantId);
    }
  }

  // void testreservationcreation() async {
  //   final db = FirebaseFirestore.instance;
  //   final collectionRef = db.collection(
  //     'restaurant list',
  //   ); // Make sure it the right name of the collection !!!!!!!! --------------

  //   final dateString =
  //       dateSelected!.toLocal().toString().split(' ')[0]; // EX: "2025-05-06"
  //   final timeString = time!.format(context); // EX: "11:00 AM"

  //   final restaurantId = 'matador2'; // Replace with the actual marker id ------

  //   final resid = "123abc"; // Replace with the actual resevation id ------
  //   final tablenum = 1; // Replace with the actual table number  -------

  //   // if date exists check if time exists
  //   // if it does, add the reservation to the time
  //   // if it doesn't, create a new time entry
  //   // if the date doesn't exist, create a new date entry and time then add table x as string

  //   // check if the date exists
  //   final docRef = collectionRef.doc(restaurantId);
  //   final docSnapshot = await docRef.get();
  //   if (docSnapshot.exists) {
  //     final data = docSnapshot.data();
  //     if (data != null && data.containsKey(dateString)) {
  //       // the date exists so check if time exists
  //       final timeMap = data[dateString];
  //       if (timeMap is Map<String, dynamic> &&
  //           timeMap.containsKey(timeString)) {
  //         // time does exists so add a reservation
  //         final timeEntry = timeMap[timeString];
  //         if (timeEntry is Map<String, dynamic>) {
  //           int available = 0;
  //           if (timeEntry.containsKey("available")) {
  //             final availableValue = timeEntry["available"];
  //             available = availableValue;
  //           }
  //           // check if the reservation is available
  //           if (available > 0) {
  //             // add the reservation
  //             await docRef.update({
  //               '$dateString.$timeString.available': available - 1,
  //               '$dateString.$timeString.$tablenum': resid,
  //             });
  //           }
  //         }
  //       } else {
  //         // Time doesn't exist, create a new time entry
  //         await docRef.update({
  //           '$dateString.$timeString': {'available': 5, '$tablenum': resid},
  //         });
  //       }
  //     } else {
  //       // Date doesn't exist, create a new date entry and time
  //       // sets available to 5 and adds the reservation id to the table number
  //       await docRef.set({
  //         dateString: {
  //           timeString: {'available': 5, '$tablenum': resid},
  //         },
  //       }, SetOptions(merge: true));
  //     }
  //   }
  // }

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
                  dayDisplayMode: DayDisplayMode.inDateBox,
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
                  dayBorderWidth: 1.5,
                  dateSelectionType: DateSelectionType.activeFutureDates,
                  onDateSelect: (selectedDate) {
                    dateSelected = selectedDate;
                    tempdateSelected = selectedDate;
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
              if (temptime == null ||
                  temppartySize.isEmpty ||
                  tempdateSelected == null) {
                await QuickAlert.show(
                  context: context,
                  type: QuickAlertType.error,
                  text: 'Please fill all fields.',
                );
                return;
              } else {
                checkMarkers();
                final saveReservationData = SaveReservationData();
                await saveReservationData.saveData(
                  time!.format(context), // Format the time as a string
                  dateSelected!.toLocal().toString().split(
                    ' ',
                  )[0], // Format the date
                  partySize, // Party size
                );
                Navigator.pop(context);
                await QuickAlert.show(
                  context: context,
                  type: QuickAlertType.success,
                  text:
                      "Booking saved!\nTime: ${time?.format(context)}\nParty Size: $partySize\nDate: ${dateSelected!.toLocal().toString().split(' ')[0]}",
                );
              }
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
        currentIndex: currentIndex,
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
            currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              //pages go in order 0-3 for the bottom bar
              //right now only the maps page works
              GoogleMap(
                myLocationEnabled: true,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 16.0,
                ),
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
          if (currentIndex == 0)
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.2,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: ShowReserveData(),
              ),
            ),
        ],
      ),
    );
  }
}

class SaveReservationData {
  static final ValueNotifier<bool> reservationChanged = ValueNotifier(false);

  Future<void> saveData(String time, String date, String partySize) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('time', time);
    prefs.setString('date', date);
    prefs.setString('partysize', partySize);

    // Notify listeners that the reservation data has changed
    reservationChanged.value = !reservationChanged.value;
  }

  Future<void> printData() async {
    final prefs = await SharedPreferences.getInstance();
    String? time = prefs.getString('time');
    String? date = prefs.getString('date');
    String? partySize = prefs.getString('partysize');
    print('Time: $time');
    print('Date: $date');
    print('Party Size: $partySize');
  }

  Future<Map<String, String>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'time': prefs.getString('time') ?? '12:00 PM',
      'date': prefs.getString('date') ?? '2025-5-15',
      'partySize': prefs.getString('partysize') ?? '2',
    };
  }
}


// comments for github push