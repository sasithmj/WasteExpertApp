import 'package:flutter/material.dart';

class ShowPoints extends StatelessWidget {
  const ShowPoints({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [
              0.1,
              0.4,
              0.6,
              0.9,
            ],
            colors: [
              Color.fromARGB(255, 0, 28, 48),
              Color.fromARGB(255, 100, 204, 197),
              Color.fromARGB(255, 23, 107, 135),
              Color.fromARGB(255, 0, 28, 48),
            ],
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 12,
          ),
          const Text(
            "You Earned,",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
          ),
          const Text(
            "250 points",
            style: TextStyle(
                color: Color.fromARGB(255, 255, 195, 43),
                fontWeight: FontWeight.w800,
                fontSize: 32),
          ),
          const SizedBox(
            height: 24,
          ),
          const LinearProgressIndicator(
            color: Colors.amber,
            minHeight: 10,
            value: 0.2,
            semanticsLabel: 'Linear progress indicator',
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.stars),
                label: const Text(
                  "Redeem Now",
                  style: TextStyle(color: Color.fromARGB(255, 88, 59, 0)),
                ),
                onPressed: null,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.amber; // Color when button is disabled
                      }
                      return const Color.fromARGB(
                          255, 23, 107, 135); // Color when button is enabled
                    },
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
