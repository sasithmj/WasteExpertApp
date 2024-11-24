import 'package:flutter/material.dart';
import 'package:wasteexpert/controllers/reward_controller.dart';
import 'package:wasteexpert/controllers/user_controller.dart';
import 'package:wasteexpert/models/Reward/RewardModel.dart';
import 'package:wasteexpert/pages/Rewards/reward.dart';

class ShowPoints extends StatefulWidget {
  const ShowPoints({Key? key}) : super(key: key);

  @override
  State<ShowPoints> createState() => _ShowPointsState();
}

class _ShowPointsState extends State<ShowPoints> {
  final GarbageWeightController _controller = GarbageWeightController();
  final UserController _usercontroller = UserController();
  List<Reward> _rewards = [];
  bool _isLoading = true;
  String? _message;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchRewards();
  }

  Future<void> _fetchRewards() async {
    try {
      String? UserId = await _usercontroller.getUserIdFromPrefs();
      print("Userid id getrewards ${UserId}");
      List<Reward> rewards = await _controller.fetchGarbageWeights(UserId!);
      int totalPoints =
          rewards.fold(0, (sum, reward) => sum + reward.rewardPoints);
      setState(() {
        _rewards = rewards;
        _isLoading = false;
        _totalPoints = totalPoints;
        if (_rewards.isEmpty) {
          _message = "Welcome! Start recycling to earn your first points.";
        }
      });
    } catch (e) {
      print('Error fetching rewards: $e');
      setState(() {
        _isLoading = false;
        if (e is Exception && e.toString().contains('404')) {
          _message =
              "Start recycling to see your progress!";
        } else {
          _message =
              "Oops! We couldn't load your rewards. Please try again later.";
        }
      });
    }
  }

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
          stops: [0.1, 0.4, 0.6, 0.9],
          colors: [
            Color.fromARGB(255, 0, 28, 48),
            Color.fromARGB(255, 100, 204, 197),
            Color.fromARGB(255, 23, 107, 135),
            Color.fromARGB(255, 0, 28, 48),
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            "Your Rewards",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                )
              : _message != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _message!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                    )
                  : Text(
                      "$_totalPoints points",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 195, 43),
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                      ),
                    ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            color: Colors.amber,
            minHeight: 10,
            value: _totalPoints / 2500, // Assuming 2500 is the max points
            semanticsLabel: 'Reward Points',
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: const Text(
              "2500",
              style: TextStyle(
                color: Color.fromARGB(255, 237, 237, 237),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NeonButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RewardPage()),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, color: Color.fromARGB(255, 88, 59, 0)),
                    SizedBox(width: 8),
                    Text(
                      "Redeem Now",
                      style: TextStyle(color: Color.fromARGB(255, 88, 59, 0)),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class NeonButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const NeonButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  _NeonButtonState createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: NeonBorderPainter(_controller.value),
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class NeonBorderPainter extends CustomPainter {
  final double animationValue;

  NeonBorderPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    final paint = Paint()
      ..color = Colors.red.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);

    final path = Path()..addRRect(rrect);
    final pathMetric = path.computeMetrics().first;

    final dashLength = pathMetric.length * 0.25;
    final dashGap = pathMetric.length * 0.75;
    final startingPoint = pathMetric.length * animationValue;

    final extractedPath = pathMetric.extractPath(
      startingPoint,
      startingPoint + dashLength,
    );

    canvas.drawPath(extractedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
