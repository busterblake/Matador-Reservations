import 'package:flutter/material.dart';
// import 'dart:convert'; unsed import
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'ReservationData.dart';
import 'addReservation.dart';
import 'search_page.dart';
import 'profile_page.dart';

class Resturantreservations extends StatefulWidget {

  
  const Resturantreservations({super.key});
  
  @override
  State<Resturantreservations> createState() => ResturantReservationState();
  
}

class ResturantReservationState extends State<Resturantreservations>{
   int myIndex = 0;
   List<Reservation> data =List.from(reservations);
   final PageController _pageController = PageController(initialPage: 0);

   @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
   @override
   Widget build(BuildContext context) {
    return Scaffold(
      
      

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(iconStyle: IconStyle.Default),
        hasNotch: false,
        //fabLocation: StylishBarFabLocation.center,
        //notchStyle: NotchStyle.circle,
        //currentIndex: _currentIndex,
        items: [
          BottomBarItem(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            title: const Text('Bookings'),
            selectedColor: Colors.pink,
            unSelectedColor: Colors.grey,
          ),
          BottomBarItem(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            title: const Text('Search'),
            selectedColor: Colors.pink,
            unSelectedColor: Colors.grey,
          ),
          BottomBarItem(
            icon: const Icon(Icons.book_online_outlined),
            selectedIcon: const Icon(Icons.book_online),
            title: const Text('New'),
            selectedColor: Colors.pink,
            unSelectedColor: Colors.grey,
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            title: const Text('Profile'),
            selectedColor: Colors.pink,
            unSelectedColor: Colors.grey,
          ),
        ],
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ), 
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          
        Center(child: tableUI(),),
        
          const SearchPage(), // Index 1
          const Addreservation(), // Index 2
          const ProfilePage(), // Index 3
        ],
      ),

    );
  }
  
  Widget tableUI(){
    return SafeArea(
      child: SizedBox.expand(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 10,
            columns: createColumns(), 
            rows: createRows(),
            dataRowMinHeight: 40,
            dataRowMaxHeight: 50,
            ),
          ),
        )
      )
    );
  }

  List<DataColumn> createColumns() {
    return[
      DataColumn(label: Text("Date", textAlign: TextAlign.center,)),
      DataColumn(label: Text("Time", textAlign: TextAlign.center,)),
      DataColumn(label: Text("Size", textAlign: TextAlign.center,)),
      DataColumn(label: Text("Table", textAlign: TextAlign.center,)),
      DataColumn(label: Text("Name", textAlign: TextAlign.center,)),
      DataColumn(label: Text("Phone #", textAlign: TextAlign.center,)),
    ];
  }

  List<DataRow> createRows(){
    return data.map((e){
      return DataRow(cells: [
        DataCell(SizedBox(width: 55, child: FittedBox( fit: BoxFit.scaleDown,child:Text(e.date.toString(), textAlign: TextAlign.center,),),),),
        DataCell(SizedBox(width: 40, child: FittedBox( fit: BoxFit.scaleDown,child:Text(e.time.toString(), textAlign: TextAlign.center,),),),),
        DataCell(SizedBox(width: 10, child: FittedBox( fit: BoxFit.scaleDown,child:Text(e.size.toString(), textAlign: TextAlign.center,),),),),
        DataCell(SizedBox(width: 10, child: FittedBox( fit: BoxFit.scaleDown,child:Text(e.table.toString(), textAlign: TextAlign.center,),),),),
        DataCell(SizedBox(width: 60, child: FittedBox( fit: BoxFit.scaleDown,child:Text(e.name),),),),
        DataCell(SizedBox(width: 70, child: FittedBox( fit: BoxFit.scaleDown,child:Text(e.number.toString(), textAlign: TextAlign.center,),),),),
        ],
      );
    }).toList();
  }
}