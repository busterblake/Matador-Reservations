/// This Page allows the Restaurant to search through their reservations

import 'package:flutter/material.dart';
import 'ReservationData.dart'; 
/// The Reservation class allows the resauarant to search through their reservation if needed
/// 
/// 
class ReservationSearch extends StatefulWidget {
  const ReservationSearch({super.key});

  @override
  State<ReservationSearch> createState() => ReservationSearchPageState();
}
///Allows reservation search <br>
///
///This Class will:
/// 1. Allow the restaurant to choose how they want to search<br>
///       their choices are by name, time, table number, or date
/// 2. restaurant inputs what they are searching by and can see all reservation that fit the given criteria
class ReservationSearchPageState extends State<ReservationSearch> {
  String _searchField = 'Name';
  String _searchQuery = '';
  List<Reservation> _searchResults = [];

  final List<String> _searchOptions = ['Name', 'Time', 'Table', 'Date'];
/// performs the search with the given criteria
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
/// The Build for the page, shows the Ui 
/// 
/// this Widget will: 
///  1. allow the restaurant to choose the value they want to search by using a drop down menu
///  2. actually search for what they want
///  3. display the reservations in their list that fit their criteria
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Reservations")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// the dropdown menu 
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
              /// displays the reservation after clicking search
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