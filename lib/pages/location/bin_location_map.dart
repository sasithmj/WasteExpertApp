import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wasteexpert/controllers/smartbin_controller.dart';
import 'package:wasteexpert/models/WasteBin/SmartBin.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class BinMap extends StatefulWidget {
  const BinMap({super.key});

  @override
  State<BinMap> createState() => _BinMapState();
}

class _BinMapState extends State<BinMap> {
  final SmartBinController _controller = SmartBinController();
  List<Marker> _markers = [];
  Set<Polyline> _polylines = {};
  late GoogleMapController _mapController;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _distance;
  String? _duration;
  String? _destinationAddress;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _getCurrentLocation();
  }

  Future<void> _loadMarkers() async {
    final bins = await _controller.getAllSmartBins();

    final List<Marker> markerList = [];
    for (var bin in bins) {
      final markerIcon = await _getMarkerIconByName(bin.garbageTypes);
      String imagePath = _getImagePathByName(bin.garbageTypes);
      print(bin.id);
      final marker = Marker(
        markerId: MarkerId(bin.id),
        position: LatLng(bin.locationLat, bin.locationLng),
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: bin.garbageTypes,
          snippet: 'Fill Level: ${bin.fillLevel}',
        ),
        onTap: () => _showBinDetails(bin, imagePath),
      );
      markerList.add(marker);
    }
    setState(() {
      _markers = markerList;
    });
  }

  Future<BitmapDescriptor> _getMarkerIconByName(String name) async {
    String imagePath = _getImagePathByName(name);
    final ByteData bytes = await rootBundle.load(imagePath);
    final Uint8List list = bytes.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(list,
        targetWidth: 96, targetHeight: 110);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedBytes =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(resizedBytes!.buffer.asUint8List());
  }

  String _getImagePathByName(String name) {
    switch (name) {
      case "Food":
        return 'assets/foodbin.png';
      case "Plastic":
        return 'assets/plasticbin.png';
      case "Paper":
        return 'assets/paperbin.png';
      case "Glass":
        return 'assets/glassbin.png';
      case "Metal":
        return 'assets/metalbin.png';
      default:
        return 'assets/metalbin.png';
    }
  }

  Future<void> _getCurrentLocation() async {
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _showBinDetails(SmartBin bin, String imagePath) {
    double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: width,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  bin.garbageTypes + " Bin",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Image(
                  image: AssetImage(imagePath),
                  height: 150,
                  width: 100,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Filled:',
                style: TextStyle(fontSize: 16),
              ),
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(12),
                minHeight: 24,
                value: double.parse(bin.fillLevel),
                color: double.parse(bin.fillLevel) <= 0.75
                    ? Colors.green
                    : Colors.red,
                semanticsLabel: 'Linear progress indicator',
              ),

              const SizedBox(height: 8),

              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(width, 50.0),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      return const Color.fromARGB(255, 23, 107, 135);
                    },
                  ),
                ),
                onPressed: () =>
                    _getDirections(bin.locationLat, bin.locationLng),
                child: const Text(
                  "Get Direction",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // Add more bin details here
            ],
          ),
        );
      },
    );
  }

  Future<void> _getDirections(double binLat, double binLng) async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    String apiKey = 'AIzaSyBG3Ua3R0x4emKkYNkGan-Ds2dDvFUaEmM';
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=$binLat,$binLng&key=$apiKey';

    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      if (data['status'] == 'OK') {
        List<PointLatLng> result = PolylinePoints()
            .decodePolyline(data['routes'][0]['overview_polyline']['points']);

        List<LatLng> polylineCoordinates = [];
        for (var point in result) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ));
          _distance = data['routes'][0]['legs'][0]['distance']['text'];
          _duration = data['routes'][0]['legs'][0]['duration']['text'];
          _destinationAddress = data['routes'][0]['legs'][0]['end_address'];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.759477168102244, 81.23645088628561),
              zoom: 14,
            ),
            markers: Set<Marker>.of(_markers),
            polylines: _polylines,
            onMapCreated: _onMapCreated,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!_isLoading &&
              _distance != null &&
              _duration != null &&
              _destinationAddress != null)
            Positioned(
              top: 20,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        '$_distance Ahead',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$_duration',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      '$_destinationAddress',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
