import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/screens/intro_screen.dart';
import 'package:agscoutapp/screens/invite_employee_screen.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dialogue_alert_utilities.dart';

void logoutFunction() async {
  var orgId = await getOrganizationIDFromSF();
  await clearAllSFData();
  await DatabaseHelper.instance.delete(int.parse(orgId));
}

class AccountButtons extends StatelessWidget {
  AccountButtons(
      {@required this.buttonText,
      this.backgroundColor,
      this.onPressed,
      this.textColor,
      this.borderSide});
  final String buttonText;
  final Color backgroundColor;
  final Function onPressed;
  final Color textColor;
  final borderSide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 50,
      child: FlatButton(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
          side: borderSide, //BorderSide(color: Colors.white),
        ),
        onPressed: onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 20.0,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final title;
  final double height;

  CustomAppBar({this.title, this.height});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
//      backgroundColor: Color.fromRGBO(0, 107, 43, 0.9),
      title: title,
      actions: <Widget>[
        GestureDetector(
          child: IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            onPressed: () => showInfoOption(context),
          ),
//          child: Container(
////              margin: EdgeInsets.only(left: 20),
//            child: Icon(
//              Icons.info_outline,
//            ),
//          ),
//          onTap: () {
//            showInfoOption(context);
//          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

//AppBar customAppBar({Text title, dynamic appBar, BuildContext context}) {
//  return AppBar(
//    backgroundColor: Color.fromRGBO(0, 107, 43, 0.9),
//    title: title,
//    actions: <Widget>[
//      GestureDetector(
//        child: Icon(Icons.settings),
//        onTap: () {
//          showInfoOption(context);
////          print(">>>>>>");
//        },
//      ),
//    ],
//  );
//}

class MyBottomNavigator extends StatelessWidget {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  final ValueChanged<int> ontap;
  final int selected;

  const MyBottomNavigator({Key key, this.ontap, this.selected = 0})
      : super(key: key);

  void _onItemTapped(int index) {
    ontap(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Farms'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          title: Text('View Map'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Settings'),
        ),
      ],
      currentIndex: selected,
      selectedItemColor: Colors.green,
      onTap: _onItemTapped,
    );
  }
}

//class customAppBar extends StatelessWidget implements PreferredSizeWidget {
//  final double height;
//  final title;
////  final double height;
////
////  customAppBar({this.title, this.height})
//
//  const customAppBar({
//    Key key,
//    this.title,
//    @required this.height,
//  }) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      children: [
//        Container(
//          color: Colors.grey[300],
//          child: Padding(
//            padding: EdgeInsets.all(30),
//            child: Container(
//              color: Colors.red,
//              padding: EdgeInsets.all(5),
//              child: Row(children: [
//                IconButton(
//                  icon: Icon(Icons.menu),
//                  onPressed: () {
//                    Scaffold.of(context).openDrawer();
//                  },
//                ),
//                Expanded(
//                  child: Container(
//                    color: Colors.white,
//                    child: TextField(
//                      decoration: InputDecoration(
//                        hintText: "Search",
//                        contentPadding: EdgeInsets.all(10),
//                      ),
//                    ),
//                  ),
//                ),
//                IconButton(
//                  icon: Icon(Icons.verified_user),
//                  onPressed: () => null,
//                ),
//              ]),
//            ),
//          ),
//        ),
//      ],
//    );
//  }
//
//  @override
//  Size get preferredSize => Size.fromHeight(height);
//}
