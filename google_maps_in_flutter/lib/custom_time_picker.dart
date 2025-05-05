import 'package:flutter/material.dart';

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
        itemCount: 6, // 12 PM to 5 PM
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final hour = 12 + index;
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
