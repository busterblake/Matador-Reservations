import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'profile_page.dart';
import 'booking_page.dart';
import 'search_page.dart';
import 'package:quickalert/quickalert.dart';
import 'package:calendar_day_slot_navigator/calendar_day_slot_navigator.dart';
//needed for firebase and login
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
  String time = '';
  String partySize = '';
  DateTime? dateSelected;

  String temptime = '';
  String temppartySize = '';
  DateTime? tempdateSelected;

  final LatLng _center = const LatLng(34.240547308790596, -118.52942529186363);
  final Map<String, Marker> _markerMap = {};
  Set<Marker> _markers = {};

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
              //custom pop up the marker
              //should show the restraunt info with a button to make a reservation
              //temp will nbe the info popup
              QuickAlert.show(
                context: context,
                type: QuickAlertType.info,
                text: markerData['description'],
                customAsset: markerData['image'],
                onConfirmBtnTap: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    text: 'Temp Screen',
                  );
                  disablemarker(markerData['id']);
                  //this is where we will add logic to go to the restaraunt page
                },
              );
            },
          );
        }).toSet();

    setState(() {
      _markers = loadedMarkers;
    });
  }

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
            markers: _markers,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
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

