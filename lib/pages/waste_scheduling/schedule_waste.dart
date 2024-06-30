import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wasteexpert/controllers/schedule_controller.dart';
import 'dart:convert';
import 'package:wasteexpert/models/WasteSchedule/WasteScheduleModel.dart';

// ScheduleWaste widget
class ScheduleWaste extends StatefulWidget {
  final token;
  const ScheduleWaste({@required this.token, super.key});

  @override
  State<ScheduleWaste> createState() => _ScheduleWasteState();
}

class _ScheduleWasteState extends State<ScheduleWaste> {
  double _currentSliderValue = 20;

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
    Map<String, double> weightByType = {
      'Plastic': 0,
      'Paper': 0,
      'Glass': 0,
      'Metal': 0,
      'Organic': 0,
    };

    for (var item in wasteItems) {
      weightByType[item.wastetype] =
          weightByType[item.wastetype]! + item.quantity;
    }
    print(weightByType);
    return weightByType;
  }

  void _submitSchedule() async {
    if (wasteItems.isEmpty) {
      print('No waste items to schedule');
      return;
    }

    // Create a Schedule instance
    final schedule = ScheduleData(
      userId: widget.token, // Replace with actual user ID
      wasteTypes: wasteItems,
      scheduledDate: DateTime.now(), // Replace with actual scheduled date
      location: 'welimada', // Replace with actual location
    );

    // Submit the schedule using the controller
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
                          return Text("${index * 20}g");
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
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 4.0,
            color: Color.fromARGB(255, 100, 204, 197),
          ),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Summary",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...weightByType.entries
                  .where((entry) => entry.value > 0)
                  .map((entry) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 75,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 65, 118, 136),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${entry.key}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "${entry.value}g",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    const Text(
                      "Total items: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${_totalItems()}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    const Text(
                      "Total weight: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "${_totalWeight()}g",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width / 2.5, 25.0),
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
                onPressed: _submitSchedule,
                child: const Text(
                  "Request Pickup",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
