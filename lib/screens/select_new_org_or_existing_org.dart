import 'package:agscoutapp/screens/join_org_with_code.dart';
import 'package:flutter/material.dart';
import 'package:agscoutapp/screens/new_organization.dart';
import 'package:agscoutapp/utilities/widgets.dart';

enum SingingCharacter { lafayette, jefferson }

SingingCharacter _character = SingingCharacter.lafayette;

class SelectNewOrgOrOldOrg extends StatefulWidget {
  static const String routeName = 'select_new_or_existing_org';
  @override
  _SelectNewOrgOrOldOrgState createState() => _SelectNewOrgOrOldOrgState();
}

class _SelectNewOrgOrOldOrgState extends State<SelectNewOrgOrOldOrg> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Inducción'),
        height: 50,
      ),
      body: Column(
//        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 80.0),
            child: Image.asset(
              'images/select_new_or_old_org.png',
              height: 200,
            ),
          ),
          SizedBox(
            height: 60,
          ),
          Card(
            child: RadioListTile<SingingCharacter>(
              title: Text('Organización existente'),
//              value: SingingCharacter.lafayette,
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return JoinOrganizationWithCode();
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
              title: Text('Nueva organización'),
              value: SingingCharacter.jefferson,
              groupValue: _character,
              onChanged: (SingingCharacter value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return NewOrganization();
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
