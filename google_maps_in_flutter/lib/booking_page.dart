import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:calendar_day_slot_navigator/calendar_day_slot_navigator.dart';
import 'custom_time_picker.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
  final reservations = [
      {
        "restaurant": "Matador BBQ Pit",
        "date": "April 30, 2025",
        "time": "7:00 PM",
        "partySize": 4,
        "table": 1
      },
      {
        "restaurant": "The 818 Eatery",
        "date": "May 1, 2025",
        "time": "9:00 AM",
        "partySize": 2,
        "table": 3
      },
      {
        "restaurant": "Northridge Bites",
        "date": "May 2, 2025",
        "time": "12:00 PM",
        "partySize": 3,
        "table": 1
      },
      {
        "restaurant": "Freddy Fazbear's Pizza",
        "date": "May 3, 2025",
        "time": "6:00 PM",
        "partySize": 5,
        "table": 3
      },
      {
        "restaurant": "Beast Burger",
        "date": "May 4, 2025",
        "time": "8:00 PM",
        "partySize": 1,
        "table": 2
      },
      {
        "restaurant": "Giordanacho's",
        "date": "May 5, 2025",
        "time": "7:30 PM",
        "partySize": 2,
        "table": 1
      },
      {
        "restaurant": "Burger",
        "date": "May 6, 2025",
        "time": "5:00 PM",
        "partySize": 3,
        "table": 2
      },
    ];

    TimeOfDay? time;
    String partySize = '';
    DateTime? dateSelected;

    TimeOfDay? temptime;
    String temppartySize = '';
    DateTime? tempdateSelected;

    TimeOfDay? selectedTime;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Reservations"),
      ),
      body: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${reservation["restaurant"]}',
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text("Date: ${reservation["date"]}", style: TextStyle(fontSize: 16)),
                      Text("Time: ${reservation["time"]}", style: TextStyle(fontSize: 16)),
                      Text("Party Size: ${reservation["partySize"]}", style: TextStyle(fontSize: 16)),
                      Text("Table: ${reservation["table"]}", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Cancel reservation
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.custom,
                            barrierDismissible: true,
                            confirmBtnText: "Save",
                            widget: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                const SizedBox(height: 30),
                                CustomTimePicker(
                                  selectedTime: selectedTime,
                                  onTimeSelected: (thistime) {
                                    selectedTime = thistime;
                                    temptime = thistime;
                                  },
                                ),
                                const SizedBox(height: 30),
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
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed:() {
                                    
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                                    foregroundColor: WidgetStateProperty.all<Color>(Colors.purple),
                                    minimumSize: WidgetStateProperty.all<Size>(const Size(200, 50)),
                                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                        side: const BorderSide(color: Colors.purple, width: 2.0),
                                      ),
                                    ),
                                  ),
                                  child: Text('Change Table')
                                )
                              ]
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
                                Navigator.pop(context);
                                await Future.delayed(const Duration(milliseconds: 500));
                                await QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  text:
                                      "Booking saved!\nTime: ${time?.format(context)}\nParty Size: $partySize\nDate: ${dateSelected!.toLocal().toString().split(' ')[0]}",
                                );
                                temptime = null;
                                temppartySize = '';
                                tempdateSelected = null;
                                return;
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      
    );
  }
}