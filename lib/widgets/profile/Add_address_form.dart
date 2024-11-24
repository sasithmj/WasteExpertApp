import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wasteexpert/controllers/position_controller.dart';
import 'package:wasteexpert/controllers/user_controller.dart';
import 'package:wasteexpert/pages/profile/ManageLocation.dart';

class AddressForm extends StatefulWidget {
  final String email;
  final String? street;
  final String? city;
  final String? state;
  final String? zip;

  const AddressForm.adddata({required this.email, Key? key})
      : street = null,
        city = null,
        state = null,
        zip = null,
        super(key: key);

  const AddressForm.updatedata({
    required this.email,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    Key? key,
  }) : super(key: key);

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final PositionController _positionController = PositionController();
  late GoogleMapController mapController;
  LatLng _initialPosition = const LatLng(6.756920, 81.247266);
  LatLng? _selectedLatLng;
  bool _isLoading = false; // Added loading state

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.street ?? '');
    _cityController = TextEditingController(text: widget.city ?? '');
    _stateController = TextEditingController(text: widget.state ?? '');
    _zipController = TextEditingController(text: widget.zip ?? '');
    _initializePosition();
  }

  Future<void> _initializePosition() async {
    setState(() => _isLoading = true); // Show loading while getting position
    try {
      final currentPosition =
          await _positionController.getCurrentPositionFromPrefs();
      setState(() {
        _initialPosition =
            LatLng(currentPosition!.latitude, currentPosition.longitude);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _updateLocation() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLatLng != null) {
        setState(() => _isLoading = true); // Show loading while updating
        try {
          final UserController userController = UserController();
          await userController.updateAddress(
            widget.email,
            _streetController.text,
            _cityController.text,
            _stateController.text,
            _zipController.text,
            _selectedLatLng!.latitude,
            _selectedLatLng!.longitude,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => ManageLocation(email: widget.email)),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a location on the map')),
        );
      }
    }
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _selectedLatLng = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title:
                Text(widget.street == null ? 'Add Address' : 'Update Address'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      controller: _streetController,
                      label: 'Street Address',
                      icon: Icons.home,
                    ),
                    _buildInputField(
                      controller: _cityController,
                      label: 'City',
                      icon: Icons.location_city,
                    ),
                    _buildInputField(
                      controller: _stateController,
                      label: 'State',
                      icon: Icons.map,
                    ),
                    _buildInputField(
                      controller: _zipController,
                      label: 'Zip Code',
                      icon: Icons.pin_drop,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select your Collection Location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          onMapCreated: (controller) =>
                              mapController = controller,
                          initialCameraPosition: CameraPosition(
                            target: _initialPosition,
                            zoom: 12,
                          ),
                          onTap: _onMapTapped,
                          markers: _selectedLatLng != null
                              ? {
                                  Marker(
                                    markerId:
                                        const MarkerId('selected-location'),
                                    position: _selectedLatLng!,
                                  ),
                                }
                              : {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size(width, 50.0),
                        ),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>((states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return const Color.fromARGB(255, 23, 107, 135);
                        }),
                      ),
                      onPressed: _isLoading ? null : _updateLocation,
                      child: const Text(
                        "Update Address",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 23, 107, 135),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
