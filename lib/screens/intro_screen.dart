import 'package:agscoutapp/screens/login_screen.dart';
import 'package:agscoutapp/services/scout-type-offline-service.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/screens/signup_screen.dart';
import 'package:agscoutapp/utilities//widgets.dart';

class IntroScreen extends StatelessWidget {
  static const String routeName = 'intro_screen';
  final background = Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/background_image.jpg'),
        fit: BoxFit.cover,
      ),
    ),
  );

  final greenOpacity = Container(
//    color: Color.fromRGBO(107, 159, 20, 0.7), //light green
    color: Color.fromRGBO(0, 107, 43, 0.9), //deep green Hex #006b2b
//    color: Color.fromRGBO(0, 0, 0, 0.6), //deep green
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
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
              AccountButtons(
                buttonText: 'Regístrate',
                borderSide: BorderSide(color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, SignUp.routeName);
                },
                textColor: Colors.white,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                width: 350,
                height: 50,
                child: AccountButtons(
                  backgroundColor: Colors.white,
                  textColor: Color.fromRGBO(0, 107, 43, 10),
                  buttonText: 'Iniciar sesión',
                  borderSide: BorderSide(color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, Login.routeName);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
