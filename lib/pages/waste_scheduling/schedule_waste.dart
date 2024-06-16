import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScheduleWaste extends StatefulWidget {
  const ScheduleWaste({super.key});

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
        wasteItems
            .add(WasteItem(type: selectedValue!, weight: _currentSliderValue));
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
    return wasteItems.fold(0, (sum, item) => sum + item.weight);
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
      weightByType[item.type] = weightByType[item.type]! + item.weight;
    }

    return weightByType;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(8),
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
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
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
                          child: DropdownButtonFormField2<String>(
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
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: 200,
                            ),
                            dropdownStyleData: const DropdownStyleData(
                              maxHeight: 200,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            dropdownSearchData: DropdownSearchData(
                              searchController: textEditingController,
                              searchInnerWidgetHeight: 50,
                              searchInnerWidget: Container(
                                height: 50,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                  right: 8,
                                  left: 8,
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: textEditingController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: 'Search for an item...',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              searchMatchFn: (item, searchValue) {
                                return item.value
                                    .toString()
                                    .contains(searchValue);
                              },
                            ),
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                textEditingController.clear();
                              }
                            },
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
                      thumbColor: Color.fromARGB(255, 23, 107, 135),
                      activeColor: Color.fromARGB(255, 23, 107, 135),
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
      physics: NeverScrollableScrollPhysics(),
      itemCount: wasteItems.length,
      itemBuilder: (context, index) {
        final item = wasteItems[index];
        return Card(
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(
                    item.type,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('Weight: ${item.weight}g'),
                ),
              ),
              IconButton(
                iconSize: 25,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Color.fromARGB(255, 251, 68, 68),
                ),
                // the method which is called
                // when button is pressed
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
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 75,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 65, 118, 136),
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
                onPressed: _addItem,
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

class WasteItem {
  final String type;
  final double weight;

  WasteItem({required this.type, required this.weight});
}
