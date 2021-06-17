import 'dart:async';

import 'package:agscoutapp/data_models/DatabaseHelper.dart';
import 'package:agscoutapp/screens/farms_listing_screen.dart';
import 'package:agscoutapp/utilities/sharedPreference.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = 'splash_screen';

  final greenOpacity = Container(
    color: Color.fromRGBO(0, 107, 43, 0.9), //deep green Hex #006b2b
  );

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final background = Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/background_image.jpg'),
        fit: BoxFit.cover,
      ),
    ),
  );

//  Load organization profile
  Future<List<Map<String, dynamic>>> _getOrgProfileData() async {
    var orgId = await getOrganizationIDFromSF();

    var orgProfile = await DatabaseHelper.instance.queryOne(int.parse(orgId));
    print(orgProfile);
    return orgProfile;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }

  startTime() async {
    var duration = new Duration(seconds: 2);
    return new Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ListOfFarmsView()));
  }

  final greenOpacity = Container(
    color: Color(0xAA69F0CF),
  );
//  @override
  initScreen(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          background,
          greenOpacity,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'images/ag-viewer-logo.png',
                      height: 150,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                width: 20,
              ),
              Padding(padding: EdgeInsets.only(top: 20.0)),
              CircularProgressIndicator(
                backgroundColor: Colors.white,
                strokeWidth: 1,
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: initScreen(context),
    );
  }
}
