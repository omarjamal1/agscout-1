import 'package:agscoutapp/screens/new_farm_screen.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:agscoutapp/screens/farms_listing_screen.dart';

enum SingingCharacter { lafayette, jefferson }

SingingCharacter _character = SingingCharacter.lafayette;

class SelectNewFarmOrExistingFarm extends StatefulWidget {
  static const String routeName = 'select_new_or_old_farm';
  @override
  _SelectNewFarmOrExistingFarmState createState() =>
      _SelectNewFarmOrExistingFarmState();
}

class _SelectNewFarmOrExistingFarmState
    extends State<SelectNewFarmOrExistingFarm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Onboarding.'),
        height: 50,
      ),
      body: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 80.0),
            child: Image.asset(
              'images/farm.png',
              height: 150,
            ),
          ),
          SizedBox(
            height: 60.0,
          ),
          Card(
            child: RadioListTile<SingingCharacter>(
              title: const Text('Existing Farm'),
//              value: SingingCharacter.lafayette,
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ListOfFarmsView();
                    },
                  ),
                );
                setState(() {
                  _character = value;
                });
              },
            ),
          ),
          Card(
            child: RadioListTile<SingingCharacter>(
              title: const Text('New Farm'),
              value: SingingCharacter.jefferson,
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AddNewFarm();
                    },
                  ),
                );
                setState(() {
                  _character = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
