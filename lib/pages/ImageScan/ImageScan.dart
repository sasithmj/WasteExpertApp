import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:wasteexpert/controllers/image_recognition_controller.dart';
import 'package:wasteexpert/pages/location/nearby_bin_map.dart';

class ImageScan extends StatefulWidget {
  const ImageScan({super.key});

  @override
  State<ImageScan> createState() => _ImageScanState();
}

class _ImageScanState extends State<ImageScan>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false;

  List<String>? _recognizedItems;
  String? _recognizedItem;

  // Predefined waste categories
  final List<String> _wasteCategories = [
    "Food",
    "Plastic",
    "Paper",
    "Glass",
    "Metal"
  ];

  @override
  void initState() {
    super.initState();
    _openCameraOnLoad();

    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  Future<void> _openCameraOnLoad() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      _imageFile = image;
    });

    if (image != null) {
      await _recognizeWaste();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  String _guessWasteType(String item) {
    if (item.toLowerCase().contains('bottle') ||
        item.toLowerCase().contains('container')) {
      return 'Plastic';
    } else if (item.toLowerCase().contains('food') ||
        item.toLowerCase().contains('fruit') ||
        item.toLowerCase().contains('vegetable')) {
      return 'Organic';
    } else if (item.toLowerCase().contains('can') ||
        item.toLowerCase().contains('aluminum')) {
      return 'Metal';
    } else if (item.toLowerCase().contains('paper') ||
        item.toLowerCase().contains('cardboard')) {
      return 'Paper';
    } else if (item.toLowerCase().contains('glass') ||
        item.toLowerCase().contains('jar')) {
      return 'Glass';
    }
    return 'Unknown';
  }

  Future<void> _recognizeWaste() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final File imageFile = File(_imageFile!.path);
      final compressedImageFile = await _compressImage(imageFile);
      ImageRecognitionController controller = ImageRecognitionController();
      final recognizedData =
          await controller.recognizeWaste(photo: compressedImageFile);

      setState(() {
        if (recognizedData != null) {
          _recognizedItems = recognizedData
              .map<String>((item) => item['name'] as String)
              .toList();
          _recognizedItem = _recognizedItems![0];
        } else {
          _recognizedItems = [];
        }
      });

      // Check if recognized items match predefined categories
      List<String> matchedCategories = _recognizedItems!
          .where((item) => _wasteCategories.contains(item))
          .toList();

      if (matchedCategories.isEmpty) {
        // If no direct matches, try to guess the waste type
        for (String item in _recognizedItems!) {
          String guessedType = _guessWasteType(item);
          if (guessedType != 'Unknown') {
            matchedCategories.add(guessedType);
            break;
          }
        }
      }

      if (matchedCategories.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SmartBinMap(wasteCategories: matchedCategories),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Unable to determine waste category. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to Recognize $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageFile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.file(
            File(_imageFile!.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
                    ],
                    stops: [
                      _animation.value - 0.5,
                      _animation.value + 0.5,
                    ],
                  ).createShader(rect);
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: _recognizedItems == null || _recognizedItems!.isEmpty
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            'Analyzing...',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text(
                              '${_recognizedItems![0]}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ]),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
