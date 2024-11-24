import 'package:flutter/material.dart';
import 'package:wasteexpert/controllers/user_controller.dart';
import 'package:wasteexpert/widgets/profile/Add_address_form.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ManageLocation extends StatefulWidget {
  final String email;
  const ManageLocation({required this.email, Key? key}) : super(key: key);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Location'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (userData != null && userData!["user"]["address"] != null) {
      return _buildAddressCard();
    } else {
      return _buildAddAddressButton();
    }
  }

  Widget _buildAddressCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black54),
                  onPressed: () => _navigateToEditAddress(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAddressLine(
                Icons.location_on, userData!["user"]['address']["street"]),
            _buildAddressLine(
                Icons.location_city, userData!["user"]['address']["city"]),
            _buildAddressLine(Icons.map, userData!["user"]['address']["state"]),
            _buildAddressLine(
                Icons.pin_drop, userData!["user"]['address']["zip"]),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddressForm.adddata(email: email),
            ),
          );
        },
        child: Text('Add Location'),
      ),
    );
  }

  void _navigateToEditAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressForm.updatedata(
          email: email,
          street: userData!["user"]['address']["street"],
          city: userData!["user"]['address']["city"],
          state: userData!["user"]['address']["state"],
          zip: userData!["user"]['address']["zip"],
        ),
      ),
    );
  }

  void _navigateToAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressForm.adddata(email: email),
      ),
    );
  }
}
