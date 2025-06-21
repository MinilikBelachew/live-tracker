import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../screens/profile_screen.dart';
import 'package:provider/provider.dart';
import '../providers/map_style_provider.dart';
import 'package:geocoding/geocoding.dart'; // NEW: Import geocoding package

class TrackingPage extends StatefulWidget {
  final String token;
  final int driverId;
  final String driverName;
  final VoidCallback onLogout;

  const TrackingPage({
    required this.token,
    required this.driverId,
    required this.driverName,
    required this.onLogout,
    super.key,
  });

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  IO.Socket? socket;
  StreamSubscription<Position>? positionSub;
  bool isConnected = false;
  Position? currentPosition;
  String connectionStatus = "Connecting...";
  String currentAddress =
      "Fetching address..."; // NEW: State variable for address
  Timer? reconnectTimer;

  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  static const LatLng _initialCameraPosition = LatLng(39.7392, -104.9903);

  int _selectedIndex = 0;

  final String serverUrl = 'http://192.168.235.177:4000';

  @override
  void initState() {
    super.initState();
    _initConnection();
  }

  Future<void> _initConnection() async {
    await _checkLocationPermissions();
    _connectSocketIO();
  }

  Future<void> _checkLocationPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) throw "Location services disabled";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw "Location permissions denied";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw "Location permissions permanently denied";
      }
    } catch (e) {
      print("Location error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission error: ${e.toString()}")),
        );
      }
    }
  }

  void _connectSocketIO() {
    if (socket != null) {
      socket!.dispose();
    }
    setState(() => connectionStatus = "Connecting...");

    try {
      socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'extraHeaders': {'token': widget.token},
      });

      socket!.connect();

      socket!.onConnect((_) {
        print('Socket.IO Connected');
        setState(() {
          isConnected = true;
          connectionStatus = "Connected";
        });
        _startLocationUpdates();
        reconnectTimer?.cancel();
      });

      socket!.onDisconnect((_) {
        print('Socket.IO Disconnected');
        _handleDisconnect("Disconnected by server");
      });

      socket!.onError((error) {
        print('Socket.IO Error: $error');
        _handleDisconnect("Error: $error");
      });

      socket!.on('connect_error', (error) {
        print('Socket.IO Connect Error: $error');
        _handleDisconnect("Connection Error: $error");
      });
    } catch (e) {
      _handleDisconnect(e.toString());
    }
  }

  void _startLocationUpdates() {
    positionSub?.cancel();
    positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(
      (position) {
        _sendLocationUpdate(position);
      },
      onError: (e) {
        print("Location stream error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location stream error: ${e.toString()}")),
          );
        }
      },
    );
  }

  Future<void> _sendLocationUpdate(Position position) async {
    if (!isConnected || socket == null || !socket!.connected) return;

    setState(() {
      currentPosition = position;
    });

    // NEW: Perform reverse geocoding
    String address = "Fetching address...";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      print("Geocoding error: $e");
      address = "Address not found";
    }

    setState(() {
      currentAddress = address; // Update the address state
      _updateMarker(position, address); // Pass address to updateMarker
    });

    try {
      socket!.emit("driverLocation", {
        "driverId": widget.driverId,
        "lat": position.latitude,
        "lng": position.longitude,
        "token": widget.token,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print("Send error: $e");
    }
  }

  void _updateMarker(Position position, String address) {
    // Updated to accept address
    _markers.clear();
    final LatLng latLng = LatLng(position.latitude, position.longitude);

    _markers.add(
      Marker(
        point: latLng,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 40,
            ),
            Text(
              widget.driverName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );

    _mapController.move(latLng, _mapController.camera.zoom);
  }

  void _handleDisconnect(String reason) {
    if (!mounted) return;

    setState(() {
      isConnected = false;
      connectionStatus = "Disconnected: $reason";
    });

    positionSub?.cancel();
    reconnectTimer?.cancel();

    reconnectTimer = Timer(const Duration(seconds: 5), () {
      print("Attempting to reconnect...");
      _connectSocketIO();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    positionSub?.cancel();
    socket?.disconnect();
    socket?.dispose();
    reconnectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapStyleProvider = Provider.of<MapStyleProvider>(context);

    List<Widget> _widgetOptions = <Widget>[
      // Map View
      Column(
        children: [
          ListTile(
            title: const Text("Location Status"),
            subtitle: Text(connectionStatus),
            trailing:
                !isConnected
                    ? IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _connectSocketIO,
                    )
                    : null,
          ),
          // NEW: Display the formatted address instead of Lat/Lng
          ListTile(
            title: const Text("Current Location"),
            subtitle: Text(currentAddress),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    currentPosition != null
                        ? LatLng(
                          currentPosition!.latitude,
                          currentPosition!.longitude,
                        )
                        : _initialCameraPosition,
                initialZoom: 15.0,
                keepAlive: true,
              ),
              children: [
                TileLayer(
                  urlTemplate: mapStyleProvider.currentMapStyle.url,
                  userAgentPackageName: 'com.example.flutter_driver_app',
                ),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
        ],
      ),
      // Profile Screen
      ProfileScreen(
        driverName: widget.driverName,
        driverId: widget.driverId.toString(),
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver App'),
        actions: [
          Icon(
            isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        onTap: _onItemTapped,
      ),
    );
  }
}
