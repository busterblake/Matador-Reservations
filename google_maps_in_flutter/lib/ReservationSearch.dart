import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addReservation.dart';

class ReservationSearch extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const ReservationSearch({super.key, required this.restaurant});

  @override
  State<ReservationSearch> createState() => ReservationSearchPageState();
}

class ReservationSearchPageState extends State<ReservationSearch> {
  String _searchField = 'Name';
  String _searchQuery = '';
  String _sortField = 'Date';
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allReservations = [];

  final List<String> _searchOptions = ['All', 'Name', 'Time', 'Table', 'Date', 'Today'];
  final List<String> _sortOptions = ['Name', 'Date', 'Time', 'Party Size'];

  @override
  void initState() {
    super.initState();
    _loadReservationsForRestaurant();
  }

  Future<void> _loadReservationsForRestaurant() async {
    final restaurantId = widget.restaurant['id'];

  // reservations are stored as 
  // reservations (collections) ->
  // matador# (document) -> fields are ->
  // email, name, partySize, restaurantId, tableId, time, userId...
    final docSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .doc(restaurantId)
        .get();

    final data = docSnapshot.data();
    if (data == null) return;

    final List<Map<String, dynamic>> loaded = data.entries
        .map((entry) {
          final res = entry.value;
          if (res is Map<String, dynamic>) {
            return {
              ...res,
              'id': entry.key,
            };
          }
          return null;
        })
        .where((e) => e != null)
        .cast<Map<String, dynamic>>()
        .toList();

    setState(() {
      _allReservations = loaded;
    });
  }

  void _performSearch() {
  final today = DateTime.now();
  List<Map<String, dynamic>> results = [];

  if (_searchField == 'All') {
    results = List.from(_allReservations); // just show everything
  } else {
    results = _allReservations.where((res) {
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
              try {
               final inputParts = _searchQuery.split('-');
                    if (inputParts.length == 3) {
                     final inputDate = DateTime(
                        int.parse(inputParts[0]), // year
                        int.parse(inputParts[1]), // month
                        int.parse(inputParts[2]), // day
                  );
                      if (res['date'] is Timestamp) {
                      final reservationDate = (res['date'] as Timestamp).toDate();
                      return reservationDate.year == inputDate.year &&
                      reservationDate.month == inputDate.month &&
                      reservationDate.day == inputDate.day;
              }
         }
  } catch (_) {
    return false;
  }
  return false;

        case 'Today':
          if (res['date'] is Timestamp) {
            final DateTime reservationDate = (res['date'] as Timestamp).toDate();
            return reservationDate.year == today.year &&
                reservationDate.month == today.month &&
                reservationDate.day == today.day;
          }
          return false;
        default:
          return false;
      }
    }).toList();
  }

  _sortResults(results);

  setState(() {
    _searchResults = results;
  });
}


  void _sortResults(List<Map<String, dynamic>> list) {
    list.sort((a, b) {
      switch (_sortField) {
        case 'Name':
          return a['name']?.toString().compareTo(b['name']?.toString() ?? '') ?? 0;
        case 'Date':
          final dateA = (a['date'] is Timestamp) ? (a['date'] as Timestamp).toDate() : DateTime(1970);
          final dateB = (b['date'] is Timestamp) ? (b['date'] as Timestamp).toDate() : DateTime(1970);
          return dateA.compareTo(dateB);
        case 'Time':
          return a['time']?.toString().compareTo(b['time']?.toString() ?? '') ?? 0;
        case 'Party Size':
          return (a['partySize'] ?? 0).compareTo(b['partySize'] ?? 0);
        default:
          return 0;
      }
    });
  }

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal().toString().split(' ')[0];
    }
    return value?.toString() ?? '';
  }

  String _formatTime(dynamic value) {
    return value?.toString() ?? '';
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Search Reservations"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    ),
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
          if (_searchField != 'Today')
            TextField(
              decoration: const InputDecoration(labelText: 'Enter search value'),
              onChanged: (value) => _searchQuery = value,
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _performSearch,
                child: const Text('Search'),
              ),
              ElevatedButton(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Addreservation(restaurant: widget.restaurant),
      ),
    );
    if (result == true) {
      _loadReservationsForRestaurant(); // Refresh list
    }
  },
  child: const Text('Add a Reservation'),
),

            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("Sort by: "),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _sortField,
                items: _sortOptions.map((String field) {
                  return DropdownMenuItem(
                    value: field,
                    child: Text(field),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _sortField = value!;
                    _sortResults(_searchResults); // Re-sort on dropdown change
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                          'Date: ${_formatDate(r['date'])}, Time: ${_formatTime(r['time'])}, Party Size: ${r['partySize'] ?? 'N/A'}',
                        ),
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
