import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:wasteexpert/controllers/schedule_controller.dart';
import 'package:wasteexpert/controllers/user_controller.dart';
import 'dart:convert';
import 'package:wasteexpert/models/WasteSchedule/WasteScheduleModel.dart';
import 'package:wasteexpert/pages/profile/ManageLocation.dart';

// ScheduleWaste widget
class ScheduleWaste extends StatefulWidget {
  final userId;
  final email;
  const ScheduleWaste({@required this.userId, @required this.email, super.key});

  @override
  State<ScheduleWaste> createState() => _ScheduleWasteState();
}

class _ScheduleWasteState extends State<ScheduleWaste> {
  double _currentSliderValue = 20;
  bool _userAddress = true;

  final List<String> items = [
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'Organic',
  ];

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  final List<WasteItem> wasteItems = [];

  @override
  void initState() {
    super.initState();
    _checkUserAddress().then((hasAddress) {
      setState(() {
        _userAddress = hasAddress;
      });
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (selectedValue != null) {
      setState(() {
        wasteItems.add(WasteItem(
            wastetype: selectedValue!, quantity: _currentSliderValue));
        // Reset the form
        selectedValue = null;
        _currentSliderValue = 20;
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      wasteItems.removeAt(index);
    });
  }

  int _totalItems() {
    return wasteItems.length;
  }

  double _totalWeight() {
    return wasteItems.fold(0, (sum, item) => sum + item.quantity);
  }

  Future<bool> _checkUserAddress() async {
    UserController user = UserController();
    final userdata = await user.getUserData(widget.email);
    print(userdata);
    if (userdata!["user"]["address"] == null) {
      _showAddressNotFilledDialog();
      return false;
    }
    return true;
  }

  Future<void> _showAddressNotFilledDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pickup Address Not Filled'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Your waste pickup address is not registered. Please update your address in the profile.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ManageLocation(email: widget.email)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Item'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteItem(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Map<String, double> _totalWeightByType() {
    Map<String, double> weightByType = {}; // Start with empty map

    for (var item in wasteItems) {
      weightByType[item.wastetype] =
          (weightByType[item.wastetype] ?? 0) + item.quantity;
    }

    // Remove any zero values
    weightByType.removeWhere((key, value) => value == 0);

    print(weightByType);
    return weightByType;
  }

  void _submitSchedule() async {
    if (wasteItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add waste items before scheduling')),
      );
      return;
    }

    // Get the aggregated waste items using _totalWeightByType
    final aggregatedWaste = _totalWeightByType();

    // Convert the aggregated map to list of WasteItem
    final List<WasteItem> aggregatedWasteItems =
        aggregatedWaste.entries.map((entry) {
      return WasteItem(wastetype: entry.key, quantity: entry.value);
    }).toList();

    // Create a Schedule instance with aggregated items
    final schedule = ScheduleData(
      userId: widget.userId,
      wasteTypes: aggregatedWasteItems, // Using aggregated list
      scheduledDate: DateTime.now(),
      ScheduleState: 'Waiting',
    );

    // Submit the schedule using the controller
    if (_userAddress) {
      try {
        final controller = ScheduleController();
        await controller.scheduleWaste(schedule);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule submitted successfully')),
        );

        // Clear the waste items
        setState(() {
          wasteItems.clear();
        });
      } catch (e) {
        // Show error message if something goes wrong
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting schedule: ${e.toString()}')),
        );
      }
    } else {
      _showAddressNotFilledDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                "My Trash Bin",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 216, 216, 216),
                    spreadRadius: 1,
                    blurRadius: 15,
                    offset: Offset(0, 15),
                  ),
                ],
              ),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            hint: Text(
                              'Select Waste Type',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            items: items
                                .map((item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            value: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    const Text(
                      "Weight",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      thumbColor: const Color.fromARGB(255, 23, 107, 135),
                      activeColor: const Color.fromARGB(255, 23, 107, 135),
                      value: _currentSliderValue,
                      max: 100,
                      divisions: 5,
                      label: _currentSliderValue.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _currentSliderValue = value;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Text("${index * 20}g+");
                        }),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all<Size>(
                          Size(width, 25.0),
                        ),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey;
                            }
                            return const Color.fromARGB(255, 23, 107, 135);
                          },
                        ),
                      ),
                      onPressed: _addItem,
                      child: const Text(
                        "Add to bin",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            if (wasteItems.isNotEmpty) _buildSummary(),
            const SizedBox(
              height: 24,
            ),
            _buildWasteItemsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: wasteItems.length,
      itemBuilder: (context, index) {
        final item = wasteItems[index];
        return Card(
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(
                    item.wastetype,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Weight: ${item.quantity}g'),
                ),
              ),
              IconButton(
                iconSize: 25,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Color.fromARGB(255, 251, 68, 68),
                ),
                onPressed: () => _showDeleteConfirmationDialog(index),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummary() {
    final weightByType = _totalWeightByType();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: const Border(
          left: BorderSide(
            width: 4.0,
            color: Color.fromARGB(255, 100, 204, 197),
          ),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Waste Summary",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Items: ${_totalItems()}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                "Total Weight: ${_totalWeight()}g",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Waste Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weightByType.entries
                .where((entry) => entry.value > 0)
                .map((entry) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 65, 118, 136),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${entry.value}g",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 100, 204, 197),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
              ),
              onPressed: _submitSchedule,
              child: const Text(
                "REQUEST PICKUP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
