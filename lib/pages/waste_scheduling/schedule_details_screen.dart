import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wasteexpert/controllers/schedule_controller.dart';
import 'package:wasteexpert/pages/profile/Myshedules.dart';

class ScheduleDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;

  ScheduleDetailsScreen({required this.schedule});

  @override
  _ScheduleDetailsScreenState createState() => _ScheduleDetailsScreenState();
}

class _ScheduleDetailsScreenState extends State<ScheduleDetailsScreen> {
  late DateTime scheduledDate;

  @override
  void initState() {
    super.initState();
    scheduledDate = DateTime.parse(widget.schedule['ScheduledDate']);
  }

  void _changeSchedule() async {
    DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: scheduledDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (newDate != null) {
      try {
        ScheduleController schedule = ScheduleController();
        await schedule.updatescheduleDate(
            widget.schedule['_id'], newDate.toIso8601String());
      } catch (e) {
        print(e);
      }
      setState(() {
        scheduledDate = newDate;
        widget.schedule['ScheduledDate'] = scheduledDate.toIso8601String();
      });
    }
  }

  void _deleteSchedule() async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this schedule?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false when cancelled
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true when confirmed
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        ScheduleController schedule = ScheduleController();
        await schedule.deletescheduleData(widget.schedule['_id']);
        Navigator.popUntil(context, (route) => route.isFirst);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final wasteTypes = widget.schedule['WasteType'] as List;
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(scheduledDate);
    final status = widget.schedule['ScheduleState'];
    // final status = "Scheduled";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            _buildTimeline(status),
            const SizedBox(height: 20),
            Text(
              'Schedule ID: ${widget.schedule["_id"]}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Scheduled Date: $formattedDate',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Collector: ${widget.schedule["collector"]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Waste Types:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: wasteTypes.map((waste) {
                return Chip(
                  label: Text('${waste["wastetype"]}: ${waste["quantity"]}g'),
                  backgroundColor: const Color.fromARGB(255, 65, 118, 136),
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Additional Description: ${widget.schedule["description"] ?? "No description available."}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(width / 1.7, 40.0),
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (states) {
                        return const Color.fromARGB(255, 23, 107, 135);
                      },
                    ),
                  ),
                  onPressed: _changeSchedule,
                  child: const Text(
                    "Change schedule",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(width / 4, 40.0),
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (states) {
                        return const Color.fromARGB(255, 205, 1, 66);
                      },
                    ),
                  ),
                  onPressed: _deleteSchedule,
                  child: const Text(
                    "Remove",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final stages = ['Waiting', 'Scheduled', 'Picked Up'];
    final currentIndex = stages.indexOf(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          final isCompleted = index <= currentIndex;
          final isActive = index == currentIndex;

          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isCompleted ? _getStatusColor(stage) : Colors.grey[400],
                  ),
                  child: isActive
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
                const SizedBox(height: 5),
                Text(
                  stage,
                  style: TextStyle(
                    color: isActive ? _getStatusColor(stage) : Colors.black,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Waiting':
        return Colors.green;
      case 'Scheduled':
        return Colors.green;
      case 'Picked Up':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
