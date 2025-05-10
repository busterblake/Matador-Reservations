/// Allows the user to pick the time for their reservation
/// 
/// Class that allows for the user to pick from a select list of times

import 'package:flutter/material.dart';

/// The Time picker
/// 
/// This class will: 
/// - Display times from 11am to 9pm
/// - Allow the user to choose a time 
/// - once picked it will be added to the reservation
class CustomTimePicker extends StatefulWidget {
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;


  const CustomTimePicker({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });


  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}


class _CustomTimePickerState extends State<CustomTimePicker> {
  TimeOfDay? _localSelectedTime;


  @override
  void initState() {
    super.initState();
    _localSelectedTime = widget.selectedTime;
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 11, // 11 AM to 9 PM
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final hour = 11 + index;
          final time = TimeOfDay(hour: hour, minute: 0);
          final isSelected =
              _localSelectedTime?.hour == time.hour &&
              _localSelectedTime?.minute == time.minute;


          return Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 2),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.black,
                side: BorderSide(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _localSelectedTime = time;
                });
                widget.onTimeSelected(time);
              },
              child: Text(time.format(context)),
            ),
          );
        },
      ),
    );
  }
}





