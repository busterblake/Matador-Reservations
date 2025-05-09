import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationSearch extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const ReservationSearch({super.key, required this.restaurant});

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

    final restaurantId = widget.restaurant['id'];

    final doc = await FirebaseFirestore.instance
        .collection('reservations')
        .doc(restaurantId)
        .get();

    final data = doc.data();
    if (data == null) return;

    final results = data.entries
        .map((e) {
          final res = e.value;
          if (res is Map<String, dynamic>) {
            res['id'] = e.key;
            return res;
          }
          return null;
        })
        .where((res) {
          if (res == null) return false;
          switch (_searchField) {
            case 'Name':
              return res['name'] != null &&
                  res['name']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
            case 'Time':
              return res['time']?.toString() == _searchQuery;
            case 'Table':
              return res['tableId']?.toString() == _searchQuery;
            case 'Date':
              return res['date']?.toString() == _searchQuery;
            default:
              return false;
          }
        })
        .cast<Map<String, dynamic>>()
        .toList();

    setState(() {
      _searchResults = results;
    });
  }

  String _formatDate(dynamic value) {
    return value?.toString() ?? '';
  }

  String _formatTime(dynamic value) {
    return value?.toString() ?? '';
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
                              'Date: ${_formatDate(r['date'])}, Time: ${_formatTime(r['time'])}'),
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
