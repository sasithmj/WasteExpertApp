import 'package:flutter/material.dart';

class NearByBins extends StatefulWidget {
  const NearByBins({super.key});

  @override
  State<NearByBins> createState() => _NearByBinsState();
}

class _NearByBinsState extends State<NearByBins> {
  int _selectedButtonIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            "NearBy Bins",
            style: TextStyle(fontSize: 20, color: Colors.black87,fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ToggleButtons(
              isSelected:
                  List.generate(5, (index) => index == _selectedButtonIndex),
              onPressed: (int index) {
                setState(() {
                  _selectedButtonIndex = index;
                });
              },
              selectedColor: Colors.blue,
              color: Colors.grey,
              fillColor: Colors.blue.withOpacity(0.1),
              borderWidth: 0,
              children: [
                _buildButton(0, 'assets/food.png', 'Food'),
                _buildButton(1, 'assets/plastic.png', 'Plastic'),
                _buildButton(2, 'assets/glass.png', 'Glass'),
                _buildButton(3, 'assets/metal.png', 'Metal'),
                _buildButton(4, 'assets/paper.png', 'Paper'),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 36,
        )
      ],
    );
  }
}

Widget _buildButton(int index, String imagePath, String name) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        Image.asset(
          imagePath,
          width: 75,
          height: 100,
        ),
        const SizedBox(height: 5),
        Text(name),
      ],
    ),
  );
}
