import 'package:flutter/material.dart';
import 'package:wasteexpert/controllers/reward_controller.dart';
import 'package:wasteexpert/controllers/user_controller.dart';
import 'package:wasteexpert/models/Reward/RewardModel.dart';
import 'package:wasteexpert/widgets/reward/Chart.dart';
import 'package:wasteexpert/widgets/reward/points_history.dart';
import 'package:wasteexpert/widgets/reward/reward_card.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final GarbageWeightController _controller = GarbageWeightController();
  final UserController _usercontroller = UserController();
  List<Reward> _rewards = [];
  bool _isLoading = true;
  String? _errorMessage;
  final int maxPoints = 2500; // Set your desired maximum points here

  @override
  void initState() {
    super.initState();
    _fetchRewards();
  }

  Future<void> _fetchRewards() async {
    try {
      String? UserId = await _usercontroller.getUserIdFromPrefs();
      List<Reward> rewards = await _controller.fetchGarbageWeights(UserId!);
      setState(() {
        _rewards = rewards;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching rewards: $e');
      setState(() {
        _rewards = [];
        _isLoading = false;
      });
      // setState(() {
      //   _isLoading = false;
      //   _errorMessage = 'Failed to load rewards. Please try again later.';
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : Column(
                    children: [
                      RewardCard(rewards: _rewards, maxPoints: maxPoints),
                      PieChartSample2(
                        rewards: _rewards,
                      ),
                      PointsHistory(rewards: _rewards),
                    ],
                  ),
      ),
    );
  }
}
