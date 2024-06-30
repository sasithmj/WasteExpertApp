import 'package:flutter/material.dart';
import 'package:wasteexpert/controllers/user_controller.dart';
import 'package:wasteexpert/widgets/profile/Add_address_form.dart';

class ManageLocation extends StatefulWidget {
  final String email;
  const ManageLocation({required this.email, super.key});

  @override
  State<ManageLocation> createState() => _ManageLocationState();
}

class _ManageLocationState extends State<ManageLocation> {
  late String email;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    UserController userController = UserController();
    Map<String, dynamic>? data = await userController.getUserData(email);
    setState(() {
      userData = data;
      isLoading = false;
    });
    print(userData!["user"]["address"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Location'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData != null && userData!["user"]["address"] != null
              ? Container(
                padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddressForm(email: email),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 12,),
                      Text('${userData!["user"]['address']["street"]},'),
                      Text('${userData!["user"]['address']["city"]},'),
                      Text('${userData!["user"]['address']["state"]},'),
                      Text('${userData!["user"]['address']["zip"]}.'),
                    ],
                  ),
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressForm(email: email),
                        ),
                      );
                    },
                    child: Text('Add Location'),
                  ),
                ),
    );
  }
}
