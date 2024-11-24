import 'package:flutter/material.dart';
import 'package:wasteexpert/widgets/home/nearby_bins.dart';
import 'package:wasteexpert/widgets/home/request_pickup.dart';
import 'package:wasteexpert/widgets/home/show_points.dart';
import 'package:wasteexpert/widgets/home/week_number.dart';

class Home extends StatefulWidget {
  final Function onRequestPickup;
  // Accept nearby bins
  final String userId;

  const Home({super.key, required this.onRequestPickup, required this.userId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeekNumber(userId: widget.userId),
          RequestPickup(onRequestPickup: widget.onRequestPickup),
          ShowPoints(),
          NearByBins(),
        ],
      ),
    );
  }
}
