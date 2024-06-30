import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wasteexpert/controllers/user_controller.dart';

class AddressForm extends StatefulWidget {
  final String email;
  const AddressForm({required this.email, super.key});

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  void _updateLocation() async {
    if (_formKey.currentState!.validate()) {
      // Process the form data
      final street = _streetController.text;
      final city = _cityController.text;
      final state = _stateController.text;
      final zip = _zipController.text;

      UserController userController = UserController();
      await userController.updateAddress(
        widget.email,
        street,
        city,
        state,
        zip,
      );

      // Optionally, navigate back or show a success message
      Navigator.pop(context); // Navigate back after updating the address
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Street Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a street address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a state';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _zipController,
                decoration: const InputDecoration(labelText: 'Zip Code'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a zip code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(width, 50.0),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey;
                      }
                      return const Color.fromARGB(255, 23, 107, 135);
                    },
                  ),
                ),
                onPressed: () {
                  _updateLocation();
                },
                child: const Text(
                  "Update Address",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
