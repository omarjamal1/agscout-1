import 'package:agscoutapp/functions/get_current_location_function.dart';
import 'package:agscoutapp/screens/farms_listing_screen.dart';
import 'package:agscoutapp/screens/maps_screen.dart';
import 'package:agscoutapp/screens/view_organization_profile_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigatorEntry extends StatefulWidget {
  static const String routeName = 'bottom_navigator';
  @override
  _BottomNavigatorEntryState createState() => _BottomNavigatorEntryState();
}

class _BottomNavigatorEntryState extends State<BottomNavigatorEntry> {
  int _selectedIndex = 0;

  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
//    GlobalKey<NavigatorState>(),
  ];
  void getLocation() async {
//    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex].currentState.maybePop();

        print(
            'isFirstRouteInCurrentTab: ' + isFirstRouteInCurrentTab.toString());

        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: Colors.grey,
              ),
              title: Text('HOME'),
              activeIcon: Icon(
                Icons.home,
                color: Colors.green,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.map,
                color: Colors.grey,
              ),
              title: Text('Map'),
              activeIcon: Icon(
                Icons.map,
                color: Colors.green,
              ),
            ),
//            BottomNavigationBarItem(
//              icon: Icon(
//                Icons.scatter_plot,
//                color: Colors.grey,
//                size: 36,
//              ),
//              title: Text('Plot'),
//              activeIcon: Icon(
//                Icons.scatter_plot,
//                color: Colors.green,
//                size: 36,
//              ),
//            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                color: Colors.grey,
                size: 36,
              ),
              title: Text('PROFILE'),
              activeIcon: Icon(
                Icons.settings,
                color: Colors.green,
                size: 36,
              ),
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
//            _buildOffstageNavigator(3),
          ],
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          ListOfFarmsView(),
          ViewMap(),
//          PlotListing(),
          ViewOrganizationProfile(),
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        },
      ),
    );
  }
}
