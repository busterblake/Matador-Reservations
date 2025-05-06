import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_in_flutter/main.dart';



class ProfilePageLoggedIn extends StatefulWidget {
 const ProfilePageLoggedIn({super.key});


 @override
 State<ProfilePageLoggedIn> createState() => _ProfilePageLoggedInState();
}


class _ProfilePageLoggedInState extends State<ProfilePageLoggedIn> {
 final user = FirebaseAuth.instance.currentUser;


 // Temporary mock list of reservations
 List<String> reservations = [
   'Reservation at x - 6:00 PM',
   'Reservation at y - 7:30 PM',
   'Reservation at z - 8:00 PM',
 ];


 void _confirmDelete(int index) {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: const Text('Delete Reservation'),
       content: const Text('Do you want to delete this reservation?'),
       actions: [
         TextButton(
           onPressed: () => Navigator.pop(context), // Close dialog
           child: const Text('No'),
         ),
         TextButton(
           onPressed: () {
             setState(() {
               reservations.removeAt(index);
             });
             Navigator.pop(context); // Close dialog
           },
           child: const Text('Yes'),
         ),
       ],
     ),
   );
 }


 void _editReservation(int index) {
   TextEditingController editController = TextEditingController(text: reservations[index]);


   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: const Text('Edit Reservation'),
       content: TextField(
         controller: editController,
         decoration: const InputDecoration(
           labelText: 'Update your reservation',
           border: OutlineInputBorder(),
         ),
       ),
       actions: [
         TextButton(
           onPressed: () => Navigator.pop(context), // Close without saving
           child: const Text('Cancel'),
         ),
         TextButton(
           onPressed: () {
             setState(() {
               reservations[index] = editController.text;
             });
             Navigator.pop(context); // Close after saving
           },
           child: const Text('Save'),
         ),
       ],
     ),
   );
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Welcome'),
       centerTitle: true,
       leading: IconButton(
         icon: const Icon(Icons.arrow_back),
         onPressed: () {
           Navigator.pop(context); // Go back
         },
       ),
     ),
     body: Padding(
       padding: const EdgeInsets.all(24.0),
       child: Column(
         children: [
           Text(
             'Logged in as:\n${user?.email ?? 'Unknown'}',
             style: const TextStyle(fontSize: 18),
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 24),
           const Text(
             'Current Reservations',
             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
           ),
           const SizedBox(height: 12),
           Expanded(
             child: reservations.isEmpty
                 ? const Center(
                     child: Text(
                       'No reservations yet.',
                       style: TextStyle(fontSize: 16),
                     ),
                   )
                 : ListView.builder(
                     itemCount: reservations.length,
                     itemBuilder: (context, index) {
                       return Card(
                         margin: const EdgeInsets.symmetric(vertical: 8),
                         child: ListTile(
                           title: Text(reservations[index]),
                           trailing: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               IconButton(
                                 icon: const Icon(Icons.edit),
                                 onPressed: () => _editReservation(index),
                               ),
                               IconButton(
                                 icon: const Icon(Icons.delete),
                                 onPressed: () => _confirmDelete(index),
                               ),
                             ],
                           ),
                         ),
                       );
                     },
                   ),
           ),
           const SizedBox(height: 12),
           ElevatedButton(
             onPressed: () async {
               await FirebaseAuth.instance.signOut();
               Navigator.pushAndRemoveUntil(
                 context,
                 MaterialPageRoute(builder: (context) => MatadorResApp()),
                 (Route<dynamic> route) => false,
               );
             },
             child: const Text('Logout'),
           ),
         ],
       ),
     ),
   );
 }
}

