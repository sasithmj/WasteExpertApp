import 'package:flutter/material.dart';

class RequestPickup extends StatelessWidget {
  final Function onRequestPickup;

  const RequestPickup({super.key, required this.onRequestPickup});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/truck.png"),
            fit: BoxFit.cover,
          ),
          color: Color.fromARGB(255, 23, 107, 135),
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Request To PickUp",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(
            height: 12,
          ),
          const Text(
            "Let's Make Our Environment Clean.",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12),
          ),
          const SizedBox(
            height: 24,
          ),
          ElevatedButton(
            onPressed: () => onRequestPickup(),
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.white)),
            child: const Text(
              "Request PickUp",
              style: TextStyle(color: Color.fromARGB(255, 23, 107, 135)),
            ),
          )
        ],
      ),
    );
  }
}
