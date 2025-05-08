import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationSearch extends StatefulWidget {
  const ReservationSearch({super.key});

  @override
  State<ReservationSearch> createState() => ReservationSearchPageState();
}

class ReservationSearchPageState extends State<ReservationSearch> {
  String _searchField = 'Name';
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  final List<String> _searchOptions = ['Name', 'Time', 'Table', 'Date'];

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) return;

    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('reservations').get();

    final results = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).where((res) {
      switch (_searchField) {
        case 'Name':
          return res['name'] != null &&
              res['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        case 'Time':
          return res['time']?.toString() == _searchQuery;
        case 'Table':
          return res['tableId']?.toString() == _searchQuery;
        case 'Date':
          return _formatDate(res['date']) == _searchQuery;
        default:
          return false;
      }
    }).toList();

    setState(() {
      _searchResults = results;
    });
  }

  String _formatDate(dynamic value) {
    try {
      if (value is Timestamp) {
        final dt = value.toDate();
        return '${dt.month}/${dt.day}/${dt.year}';
      } else if (value is DateTime) {
        return '${value.month}/${value.day}/${value.year}';
      }
    } catch (_) {}
    return '';
  }

  String _formatTime(dynamic value) {
    try {
      if (value is Timestamp) {
        final dt = value.toDate();
        final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        final minute = dt.minute.toString().padLeft(2, '0');
        return '$hour:$minute $ampm';
      }
    } catch (_) {}
    return 'Invalid';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Reservations")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _searchField,
              items: _searchOptions.map((String field) {
                return DropdownMenuItem(
                  value: field,
                  child: Text("Search by $field"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _searchField = value!;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Enter search value'),
              onChanged: (value) => _searchQuery = value,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(child: Text('No results.'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final r = _searchResults[index];
                        return ListTile(
                          title: Text('${r['name'] ?? 'Unknown'} - Table ${r['tableId'] ?? 'N/A'}'),
                          subtitle: Text(
                              'Date: ${_formatDate(r['date'])}, Time: ${_formatTime(r['date'])}'),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
