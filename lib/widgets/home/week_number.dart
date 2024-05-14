import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekNumber extends StatelessWidget {
  const WeekNumber({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday));
    final days = List.generate(
        7,
        (index) => DateFormat('EEE')
            .format(firstDayOfWeek.add(Duration(days: index))));
    final dates = List.generate(
        7, (index) => firstDayOfWeek.add(Duration(days: index)).day.toString());

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < days.length; i++)
            SingleDay(
              day: days[i],
              date: dates[i],
              isCurrentDate: now.day ==
                  firstDayOfWeek
                      .add(Duration(days: i))
                      .day, // Check for current date
            ),
        ],
      ),
    );
  }
}

class SingleDay extends StatelessWidget {
  final String day;
  final String date;
  final bool isCurrentDate;

  const SingleDay(
      {super.key,
      required this.day,
      required this.date,
      required this.isCurrentDate});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double boxSize = width / 8;

    return Container(
      width: boxSize,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(
          color: isCurrentDate
              ? Color.fromARGB(255, 23, 107, 135)
              : const Color.fromARGB(255, 226, 226, 226),
        ),
      ),
      height: 70.0, // Adjust height based on your design
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.black, // Change text color for current date
            ),
          ),
          Text(date),
        ],
      ),
    );
  }
}
