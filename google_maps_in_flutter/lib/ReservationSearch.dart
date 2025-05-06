import 'package:flutter/material.dart';
import 'ReservationData.dart'; // import your global list

class ReservationSearch extends StatefulWidget {
  const ReservationSearch({super.key});

  @override
  State<ReservationSearch> createState() => ReservationSearchPageState();
}

class ReservationSearchPageState extends State<ReservationSearch> {
  String _searchField = 'Name';
  String _searchQuery = '';
  List<Reservation> _searchResults = [];

  final List<String> _searchOptions = ['Name', 'Time', 'Table', 'Date'];

  void _performSearch() {
    setState(() {
      _searchResults = reservations.where((res) {
        switch (_searchField) {
          case 'Name':
            return res.name.toLowerCase().contains(_searchQuery.toLowerCase());
          case 'Time':
            return res.time.toString() == _searchQuery;
          case 'Table':
            return res.table.toString() == _searchQuery;
          case 'Date':
            return res.date.toString() == _searchQuery;
          default:
            return false;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Reservations")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown for selecting search type
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
            // Input for search query
            TextField(
              decoration: const InputDecoration(labelText: 'Enter search value'),
              onChanged: (value) {
                _searchQuery = value;
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final r = _searchResults[index];
                  return ListTile(
                    title: Text('${r.name} - Table ${r.table}'),
                    subtitle: Text('Date: ${r.date}, Time: ${r.time}'),
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