import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wasteexpert/controllers/schedule_controller.dart';
import 'package:wasteexpert/models/WasteSchedule/SchedulePickupModel.dart';

class WeekNumber extends StatefulWidget {
  final String userId;

  const WeekNumber({Key? key, required this.userId}) : super(key: key);

  @override
  _WeekNumberState createState() => _WeekNumberState();
}

class _WeekNumberState extends State<WeekNumber> {
  List<DateTime> scheduledPickupDates = [];

  @override
  void initState() {
    super.initState();
    _fetchScheduledPickups();
  }

  Future<List<DateTime>> fetchSchedulePickupDates(String userId) async {
    final ScheduleController controller = ScheduleController();
    try {
      List<SchedulePickup> schedulePickups =
          await controller.fetchUserSchedulePickups(userId);
      return schedulePickups.map((pickup) => pickup.date).toList();
    } catch (e) {
      print('Error fetching schedule pickups: $e');
      return [];
    }
  }

  Future<void> _fetchScheduledPickups() async {
    List<DateTime> dates = await fetchSchedulePickupDates(widget.userId);
    setState(() {
      scheduledPickupDates = dates;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(
        7,
        (index) => DateFormat('EEE')
            .format(firstDayOfWeek.add(Duration(days: index))));
    final dates =
        List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int i = 0; i < days.length; i++)
            SingleDay(
              day: days[i],
              date: dates[i],
              isCurrentDate: isSameDate(now, dates[i]),
              isScheduledPickup: scheduledPickupDates
                  .any((pickupDate) => isSameDate(pickupDate, dates[i])),
            ),
        ],
      ),
    );
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

class SingleDay extends StatelessWidget {
  final String day;
  final DateTime date;
  final bool isCurrentDate;
  final bool isScheduledPickup;

  const SingleDay({
    Key? key,
    required this.day,
    required this.date,
    required this.isCurrentDate,
    required this.isScheduledPickup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double boxSize = width / 8;

    Color borderColor = isCurrentDate
        ? const Color.fromARGB(255, 23, 107, 135)
        : const Color.fromARGB(255, 226, 226, 226);

    Color backgroundColor =
        isScheduledPickup ? Colors.green.withOpacity(0.2) : Colors.transparent;

    Color textColor = isCurrentDate
        ? const Color.fromARGB(255, 23, 107, 135)
        : isScheduledPickup
            ? Colors.green
            : Colors.black;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            width: boxSize,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              border: Border.all(color: borderColor),
              color: backgroundColor,
            ),
            height: 70.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  date.day.toString(),
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ),
        ),
        if (isScheduledPickup)
          Positioned(
            top: 5,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
