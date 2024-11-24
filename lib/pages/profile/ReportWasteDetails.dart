import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wasteexpert/controllers/user_controller.dart';
import 'package:wasteexpert/controllers/wastereport_controller.dart';
import 'package:wasteexpert/models/WasteReport/WasteReportModel.dart';
import 'package:wasteexpert/Config.url.dart' as UrlConfig;

class ReportWasteDetails extends StatefulWidget {
  const ReportWasteDetails({super.key});

  @override
  State<ReportWasteDetails> createState() => _ReportWasteDetailsState();
}

class _ReportWasteDetailsState extends State<ReportWasteDetails> {
  late WasteReportController _controller;
  List<WasteReportModel> wasteReports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WasteReportController();
    fetchWasteReports();
  }

  Future<void> fetchWasteReports() async {
    try {
      UserController userController = UserController();
      String? fetchedUserId = await userController.getUserIdFromPrefs();
      final reports = await _controller.getWasteReportsByUser(fetchedUserId!);
      print("report: $reports");
      setState(() {
        wasteReports = reports;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching waste reports: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Wastes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: wasteReports.length,
              itemBuilder: (context, index) {
                print(index);
                final report = wasteReports[index];
                return ListTile(
                  leading: report.photo != null && report.photo!.isNotEmpty
                      ? _buildImage(report.photo!)
                      : const Icon(Icons.image_not_supported),
                  title: Text(report.description),
                  subtitle: Text('Date: ${report.reportDate}'),
                  onTap: () {
                    // Navigate to a detailed view if needed
                  },
                );
              },
            ),
    );
  }

  Widget _buildImage(String photoPath) {
    final imageUrl = '${UrlConfig.url}$photoPath'; // Construct the image URL
    print(imageUrl);

    return Image.network(
      imageUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image);
      },
    );
  }
}
