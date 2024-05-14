import 'package:flutter/material.dart';
import 'package:wasteexpert/widgets/home/nearby_bins.dart';
import 'package:wasteexpert/widgets/home/request_pickup.dart';
import 'package:wasteexpert/widgets/home/show_points.dart';
import 'package:wasteexpert/widgets/home/week_number.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeekNumber(),
          RequestPickup(),
          ShowPoints(),
          NearByBins()
        ],
      ),
    );
  }
}
