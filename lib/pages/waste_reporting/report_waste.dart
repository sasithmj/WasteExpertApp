import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:wasteexpert/controllers/position_controller.dart';
import 'package:wasteexpert/controllers/wastereport_controller.dart';

class ReportWaste extends StatefulWidget {
  final File imageFile;
  final String userId;

  const ReportWaste({super.key, required this.userId, required this.imageFile});

  @override
  State<ReportWaste> createState() => _ReportWasteState();
}

class _ReportWasteState extends State<ReportWaste> {
  final TextEditingController _descriptionController = TextEditingController();
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  Map<String, bool> _selectedWasteTypes = {
    'Plastic': false,
    'Glass': false,
    'Organic': false,
    'Metal': false,
    'Paper': false,
    'Other': false,
  };
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  Future<void> _getCurrentPosition() async {
    PositionController positionController = PositionController();
    Position? position = await positionController.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;
    final compressedImage = img.encodeJpg(image, quality: 50);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/compressed_image.jpg');
    await tempFile.writeAsBytes(compressedImage);

    return tempFile;
  }

  Future<void> _reportWaste() async {
    setState(() {
      _isLoading = true;
    });

    final description = _descriptionController.text;
    final selectedWasteTypes = _selectedWasteTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    final userId = widget.userId;
    final reportDate = DateTime.now();

    // Compress image file
    final compressedImageFile = await _compressImage(widget.imageFile);

    if (_currentPosition != null) {
      WasteReportController controller = WasteReportController();
      try {
        await controller.reportWaste(
          userId: userId,
          photo: compressedImageFile,
          locationLat: _currentPosition!.latitude,
          locationLng: _currentPosition!.longitude,
          reportDate: reportDate.toIso8601String(),
          description: description,
          wasteTypes: selectedWasteTypes,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report successfully created'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create report: $error'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get current position'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showWasteTypesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Select Waste Types'),
              content: SingleChildScrollView(
                child: Column(
                  children: _selectedWasteTypes.keys.map((wasteType) {
                    return CheckboxListTile(
                      title: Text(wasteType),
                      value: _selectedWasteTypes[wasteType],
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedWasteTypes[wasteType] = value ?? false;
                        });
                        this.setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Waste'),
      ),
      body: Stack(
        children: [
          _currentPosition != null
              ? GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: _currentPosition!,
                    ),
                  },
                )
              : const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(16.0),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Report Waste',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.file(
                          widget.imageFile,
                          height: 100,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText:
                                  'Describe the waste state and location',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _showWasteTypesDialog,
                      child: const Text(
                        'Select Waste Types',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _selectedWasteTypes.entries
                          .where((entry) => entry.value)
                          .map((entry) => Chip(
                                label: Text(entry.key),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all<Size>(
                                Size(width, 40.0),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                                  return Colors.green;
                                },
                              ),
                            ),
                            onPressed: _reportWaste,
                            child: const Text(
                              'Report Waste',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
