import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wasteexpert/controllers/schedule_controller.dart';
import 'package:wasteexpert/controllers/user_controller.dart';
import 'package:wasteexpert/pages/waste_scheduling/schedule_details_screen.dart'; // Import the new screen
import 'package:wasteexpert/widgets/profile/ScheduleDetailCard.dart';

class MySchedules extends StatefulWidget {
  const MySchedules({super.key});

  @override
  State<MySchedules> createState() => _MySchedulesState();
}

class _MySchedulesState extends State<MySchedules> {
  String selectedState = 'Waiting';
  List<dynamic> schedules = [];
  String? userId;

  final ScheduleController _schedule = ScheduleController();

  @override
  void initState() {
    super.initState();
    _fetchUserIdAndSchedules();
  }

  Future<void> _fetchUserIdAndSchedules() async {
    UserController userController = UserController();
    String? fetchedUserId = await userController.getUserIdFromPrefs();
    setState(() {
      userId = fetchedUserId;
    });
    if (userId != null) {
      await fetchSchedules(userId!, selectedState);
    }
  }

  Future<void> fetchSchedules(String userId, String selectedState) async {
    try {
      final scheduleData =
          await _schedule.getscheduleWaste(userId, selectedState);

      // Sort schedules by 'ScheduledDate' in descending order
      List<dynamic> sortedSchedules = List.from(scheduleData['scheduls']);
      sortedSchedules.sort((a, b) {
        DateTime dateA = DateTime.parse(a['ScheduledDate']);
        DateTime dateB = DateTime.parse(b['ScheduledDate']);
        return dateB.compareTo(dateA);
      });

      setState(() {
        schedules = sortedSchedules;
      });
      print(schedules);
    } catch (e) {
      print('Error fetching schedules: $e');
    }
  }

  void onStateButtonPressed(String state) {
    setState(() {
      selectedState = state;
      fetchSchedules(userId!, selectedState);
    });
  }

  Widget buildStateButton(String state) {
    bool isSelected = state == selectedState;
    return ElevatedButton(
      onPressed: () => onStateButtonPressed(state),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isSelected
            ? const Color.fromARGB(255, 23, 107, 135)
            : Colors.grey, // Text color
        textStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      child: Text(state),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedules'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStateButton('Waiting'),
              buildStateButton('Scheduled'),
              buildStateButton('PickedUp'),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                final wasteTypes = schedule['WasteType'] as List;
                final scheduledDate = DateTime.parse(schedule['ScheduledDate']);
                final formattedDate =
                    DateFormat('yyyy-MM-dd HH:mm').format(scheduledDate);

                String state = schedule[
                    'ScheduleState']; // Assuming this is how you get the state
                String stateDate = '';
                if (state.startsWith('Scheduled')) {
                  final dateMatch =
                      RegExp(r'Scheduled(\d{4}-\d{2}-\d{2})').firstMatch(state);
                  if (dateMatch != null) {
                    stateDate = dateMatch.group(1) ?? '';
                  }
                } else if (state.startsWith('PickedUp')) {
                  final dateMatch =
                      RegExp(r'PickedUp(\d{4}-\d{2}-\d{2})').firstMatch(state);
                  if (dateMatch != null) {
                    stateDate = dateMatch.group(1) ?? '';
                  }
                }

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScheduleDetailsScreen(schedule: schedule),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with ID and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Schedule ID with icon
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.receipt_long,
                                      size: 20,
                                      color: Color.fromARGB(255, 65, 118, 136),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'ID: ${schedule["_id"].toString().substring(0, 8)}...',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromARGB(255, 65, 118, 136),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: state.startsWith('Waiting')
                                      ? Colors.orange.withOpacity(0.2)
                                      : state.startsWith('Scheduled')
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: state.startsWith('Waiting')
                                        ? Colors.orange
                                        : state.startsWith('Scheduled')
                                            ? Colors.green
                                            : Colors.blue,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  state.split(RegExp(r'\d'))[0],
                                  style: TextStyle(
                                    color: state.startsWith('Waiting')
                                        ? Colors.orange.shade700
                                        : state.startsWith('Scheduled')
                                            ? Colors.green.shade700
                                            : Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Dates section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.event,
                                        size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Scheduled for: $formattedDate',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                if (stateDate.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.update,
                                          size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Updated: $stateDate',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Waste Types Section
                          const Text(
                            'Waste Types',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: wasteTypes.map((waste) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 65, 118, 136)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                              255, 65, 118, 136)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color:
                                            Color.fromARGB(255, 65, 118, 136),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${waste["wastetype"]}: ${waste["quantity"]}g',
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 65, 118, 136),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
