import 'package:flutter/material.dart';
import 'package:wasteexpert/models/Reward/RewardModel.dart';

class RewardCard extends StatelessWidget {
  final List<Reward> rewards;
  final int maxPoints;

  const RewardCard({super.key, required this.rewards, this.maxPoints = 2500});

  int get totalPoints =>
      rewards.fold(0, (sum, reward) => sum + reward.rewardPoints);

  double get progressValue => (totalPoints / maxPoints).clamp(0.0, 1.0);

  // Calculate approximate price in rupees
  double get approximatePrice => totalPoints * 0.25;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: AnimatedUserProfileCard(
          profilePictureUrl:
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRbR8oFnbPmAOicYeUuTJPFGtffjQwtObUPKA&s',
          userName: 'My Rewards',
          pointsEarned: totalPoints,
          progressValue: progressValue,
          maxPoints: maxPoints,
          approximatePrice: approximatePrice,
        ),
      ),
    );
  }
}

class AnimatedUserProfileCard extends StatefulWidget {
  final String profilePictureUrl;
  final String userName;
  final int pointsEarned;
  final double progressValue;
  final int maxPoints;
  final double approximatePrice;

  AnimatedUserProfileCard({
    required this.profilePictureUrl,
    required this.userName,
    required this.pointsEarned,
    required this.progressValue,
    required this.maxPoints,
    required this.approximatePrice,
  });

  @override
  _AnimatedUserProfileCardState createState() =>
      _AnimatedUserProfileCardState();
}

class _AnimatedUserProfileCardState extends State<AnimatedUserProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          child: Card(
            elevation: 5 + _glowAnimation.value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.4, 0.6, 0.9],
                  colors: [
                    Color.fromARGB(255, 0, 28, 48),
                    Color.fromARGB(255, 100, 204, 197),
                    Color.fromARGB(255, 23, 107, 135),
                    Color.fromARGB(255, 0, 28, 48),
                  ],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: _glowAnimation.value * 3,
                    spreadRadius: _glowAnimation.value,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: _glowAnimation.value * 5,
                          spreadRadius: _glowAnimation.value,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(widget.profilePictureUrl),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.pointsEarned}',
                        style: const TextStyle(
                          fontSize: 44,
                          color: Color.fromARGB(255, 255, 185, 7),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        ' Points',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 249, 186, 26),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '~ Rs.${widget.approximatePrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 237, 237, 237),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    color: Colors.amber,
                    minHeight: 20,
                    borderRadius: BorderRadius.circular(12),
                    value: widget.progressValue,
                    semanticsLabel: 'Reward Points',
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      "${widget.maxPoints}",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 237, 237, 237),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
