from graphviz import Digraph

uml = Digraph(comment='UML for Matador Reservation App')
uml.attr(rankdir='LR')

uml.node('MatadorResApp', '''+ _currentIndex: int
+ time: TimeOfDay?
+ partySize: String
+ dateSelected: DateTime?
+ temptime: TimeOfDay?
+ temppartySize: String
+ tempdateSelected: DateTime?
+ selectedTime: TimeOfDay?
+ _markers: Set<Marker>
+ _pageController: PageController
+ mapController: GoogleMapController
---
+ _loadMarkersFromJson()
+ disablemarker(markerId)
+ build(context)
''')

uml.node('SearchPage', '''StatefulWidget
---
+ createState() => _SearchPageState''')

uml.node('_SearchPageState', '''State<SearchPage>
+ _searchController: TextEditingController
+ _restaurants: List<Map>
+ _filteredRestaurants: List<Map>
---
+ initState()
+ _loadRestaurants()
+ dispose()
+ build(context)
''')

uml.node('BookingPage', '''StatelessWidget
---
+ build(context)''')

uml.node('ProfilePage', '''StatelessWidget
---
+ build(context)''')

uml.node('MenuPage', '''StatelessWidget
+ restaurant: Map<String, dynamic>
---
+ build(context)''')

uml.node('RestaurantCards', '''StatelessWidget
+ restaurant: Map<String, dynamic>
---
+ build(context)''')

uml.node('SearchBar', '''StatelessWidget
+ _searchController: TextEditingController
---
+ build(context)''')

# Relationships
uml.edge('MatadorResApp', 'SearchPage', label='uses')
uml.edge('MatadorResApp', 'BookingPage', label='uses')
uml.edge('MatadorResApp', 'ProfilePage', label='uses')
uml.edge('SearchPage', '_SearchPageState', label='creates')
uml.edge('_SearchPageState', 'RestaurantCards', label='uses')
uml.edge('_SearchPageState', 'SearchBar', label='uses')
uml.edge('RestaurantCards', 'MenuPage', label='navigates to')

uml.render('matador_uml', format='png', cleanup=True)
