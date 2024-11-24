import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleDetailCard extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final VoidCallback onTap;

  const ScheduleDetailCard({
    Key? key,
    required this.schedule,
    required this.onTap,
  }) : super(key: key);

  String _getStateColor(String state) {
    if (state.startsWith('Waiting')) {
      return '#FFA500'; // Orange for waiting
    } else if (state.startsWith('Scheduled')) {
      return '#4CAF50'; // Green for scheduled
    } else if (state.startsWith('PickedUp')) {
      return '#2196F3'; // Blue for picked up
    }
    return '#757575'; // Grey for default
  }

  @override
  Widget build(BuildContext context) {
    final wasteTypes = schedule['WasteType'] as List;
    final scheduledDate = DateTime.parse(schedule['ScheduledDate']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(scheduledDate);
    final formattedTime = DateFormat('hh:mm a').format(scheduledDate);

    String state = schedule['ScheduleState'];
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(int.parse(_getStateColor(state).substring(1, 7),
                              radix: 16) +
                          0xFF000000)
                      .withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(int.parse(
                                _getStateColor(state).substring(1, 7),
                                radix: 16) +
                            0xFF000000),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        state.split(RegExp(r'\d'))[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '#${schedule["_id"].toString().substring(0, 8)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time,
                            size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (stateDate.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event_available,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Updated: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(stateDate))}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Waste Types:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: wasteTypes.map<Widget>((waste) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 65, 118, 136)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color.fromARGB(255, 65, 118, 136)
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Color.fromARGB(255, 65, 118, 136),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${waste["wastetype"]}: ${waste["quantity"]}g',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 65, 118, 136),
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
            ],
          ),
        ),
      ),
    );
  }
}
