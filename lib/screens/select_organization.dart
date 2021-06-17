import 'package:flutter/material.dart';
import 'package:agscoutapp/utilities/widgets.dart';
import 'package:groovin_widgets/groovin_widgets.dart';
import 'package:agscoutapp/screens/select_new_farm_or_existing_farm.dart';

class SelectOrganization extends StatefulWidget {
  static const String routeName = 'select_organization';
  @override
  _SelectOrganizationState createState() => _SelectOrganizationState();
}

class _SelectOrganizationState extends State<SelectOrganization> {
  var value;
  String dropdownText = "Select a company";
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text('Select Organization'),
        height: 50,
      ),
      body: Container(
        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 80.0),
              child: Image.asset(
                'images/join_organization.png',
                height: 150,
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Text('Join your organization'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlineDropdownButton(
                items: [
                  DropdownMenuItem(
                    child: Text("Startup Profile"),
                    value: "Startup Profile",
                  ),
                  DropdownMenuItem(
                    child: Text("AG Viewer Profile"),
                    value: "AG Viewer Profile",
                  ),
                  DropdownMenuItem(
                    child: Text("Profile 2"),
                    value: "Profile 2",
                  ),
                  DropdownMenuItem(
                    child: Text("Profile 3"),
                    value: "Profile 3",
                  ),
                ],
                isExpanded: true,
                hint: Text("$dropdownText"),
                value: value,
                onChanged: (value) {
                  setState(() {});
                  dropdownText = value;
                  print(value);
                },
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
            Container(
              width: 350,
              height: 50,
              child: AccountButtons(
//                      backgroundColor: Colors.white,
                textColor: Color.fromRGBO(0, 107, 43, 10),
                buttonText: 'Join',
                borderSide: BorderSide(color: Colors.green),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SelectNewFarmOrExistingFarm();
                  }));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
