import 'package:cloud_firestore/cloud_firestore.dart';

String formatTimestampToReadable(dynamic value) {
  try {
    if (value is Timestamp) {
      final dateTime = value.toDate();
      return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
    } else if (value is DateTime) {
      return '${_formatDate(value)} at ${_formatTime(value)}';
    } else {
      return 'Invalid time';
    }
  } catch (e) {
    return 'Error parsing time';
  }
}

String _formatDate(DateTime dt) {
  return '${dt.month}/${dt.day}/${dt.year}';
}

String _formatTime(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute $ampm';
}
