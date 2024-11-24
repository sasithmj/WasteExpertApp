import 'package:flutter/material.dart';
import 'package:wasteexpert/controllers/user_controller.dart';

class EditProfileScreen extends StatefulWidget {
  final String email;

  const EditProfileScreen({Key? key, required this.email}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController(text: widget.email);
    _mobileController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Map<String, dynamic>? userData =
          await _userController.getUserData(widget.email);
      if (userData != null && userData['user'] != null) {
        setState(() {
          _nameController.text = userData['user']['name'] ?? '';
          _mobileController.text = userData['user']['mobile'] ?? '';
          if (userData['user']['address'] != null) {
            _streetController.text =
                userData['user']['address']['street'] ?? '';
            _cityController.text = userData['user']['address']['city'] ?? '';
            _stateController.text = userData['user']['address']['state'] ?? '';
            _zipController.text = userData['user']['address']['zip'] ?? '';
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to load user data. Please try again.')),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> updatedData = {
          'email': widget.email,
          'name': _nameController.text,
          'mobile': _mobileController.text,
          'street': _streetController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zip': _zipController.text,
        };

        await _userController.updateUserProfile(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool readOnly = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_emailController, 'Email', readOnly: true),
              _buildTextField(_mobileController, 'Mobile'),
              _buildTextField(_streetController, 'Street'),
              _buildTextField(_cityController, 'City'),
              _buildTextField(_stateController, 'State'),
              _buildTextField(_zipController, 'ZIP Code'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 23, 107, 135),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }
}
