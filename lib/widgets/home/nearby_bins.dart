import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
            style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold),
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
              color: const Color.fromARGB(255, 23, 107, 135),
              fillColor: Colors.blue.withOpacity(0.1),
              borderWidth: 0,
              children: [
                _buildButton(0, 'assets/foodbin.png', 'Food'),
                _buildButton(1, 'assets/plasticbin.png', 'Plastic'),
                _buildButton(2, 'assets/paperbin.png', 'Paper'),
                _buildButton(3, 'assets/glassbin.png', 'Glass'),
                _buildButton(4, 'assets/metalbin.png', 'Metal'),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Divider(),
        ),
        _bindata(
          0,
          "assets/foodbin.png",
          "Colombo",
          "No 2,main street,colombo 02",
          "bin location data",
        ),
        _bindata(
          0,
          "assets/foodbin.png",
          "Colombo",
          "No 2,main street,colombo 02",
          "bin location data",
        ),
        _bindata(
          0,
          "assets/foodbin.png",
          "Colombo",
          "No 2,main street,colombo 02",
          "bin location data",
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
        // Text(name),
      ],
    ),
  );
}

Widget _bindata(
    int index, String imagePath, String city, String address, String link) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color.fromARGB(255, 245, 245, 245)),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 75,
            height: 100,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  address,
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.navigation_rounded,
              color: Colors.white, // Set icon color to white
            ),
            label: const Text(
              "Location",
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
            onPressed: null,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (states) {
                  return const Color.fromARGB(255, 23, 107,
                      135); // Color when button is enabled and disabled
                },
              ),
              foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white), // Set text and icon color to white
            ),
          ),
        ],
      ),
    ),
  );
}
