import 'package:flutter/material.dart';
import 'package:wasteexpert/models/Reward/RewardModel.dart';

class PointsHistory extends StatelessWidget {
  final List<Reward> rewards;

  const PointsHistory({super.key, required this.rewards});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Points History",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Schedule ID: ${reward.scheduleId}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      " ${reward.rewardPoints} points",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Waste List:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...reward.wasteList.map((wasteItem) => Text(
                                      '${wasteItem.wastetype}: ${wasteItem.quantity}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ButtonBar(
                            children: [
                              TextButton(
                                onPressed: () {
                                  // Handle button press
                                },
                                child: const Text('Details'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
