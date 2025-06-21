// lib/screens/tracking_page.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Added .dart extension
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../screens/profile_screen.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../providers/map_style_provider.dart'; // Import MapStyleProvider

class TrackingPage extends StatefulWidget {
  final String token;
  final int driverId;
  final String driverName;
  final VoidCallback onLogout; // Add onLogout callback

  const TrackingPage({
    required this.token,
    required this.driverId,
    required this.driverName,
    required this.onLogout, // Required onLogout
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
  Timer? reconnectTimer;

  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  static const LatLng _initialCameraPosition = LatLng(39.7392, -104.9903);

  int _selectedIndex = 0; // For BottomNavigationBar

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
        'extraHeaders': {
          'token': widget.token
        },
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
        distanceFilter: 5, // Update every 5 meters moved
        // The 'timeInterval' parameter is no longer available in recent geolocator versions.
        // Location updates are primarily controlled by accuracy and distanceFilter.
        // If time-based updates are strictly needed, consider implementing a custom timer
        // that checks the last position timestamp and forces an update if time limit is exceeded.
      ),
    ).listen((position) {
      _sendLocationUpdate(position);
    }, onError: (e) {
      print("Location stream error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location stream error: ${e.toString()}")),
        );
      }
    });
  }

  void _sendLocationUpdate(Position position) {
    if (!isConnected || socket == null || !socket!.connected) return;

    setState(() {
      currentPosition = position;
      _updateMarker(position); // Update map marker when position changes
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

  void _updateMarker(Position position) {
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

    // Animate map camera to the new position
    // Use `move` for instant jump or `fitCamera` for animation with `flutter_map`.
    // The `animateTo` method and `zoom` getter are not directly available on MapController.
    // If you need a smooth animation, consider a custom implementation or specific flutter_map plugins.
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

  // Bottom Navigation Bar handler
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
    // Consume MapStyleProvider to get the current map style URL
    final mapStyleProvider = Provider.of<MapStyleProvider>(context);

    List<Widget> widgetOptions = <Widget>[
      // Map View
      Column(
        children: [
          ListTile(
            title: const Text("Location Status"),
            subtitle: Text(connectionStatus),
            trailing: !isConnected
                ? IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _connectSocketIO,
                  )
                : null,
          ),
          if (currentPosition != null) ...[
            ListTile(
              title: const Text("Latitude"),
              subtitle: Text(currentPosition!.latitude.toStringAsFixed(6)),
            ),
            ListTile(
              title: const Text("Longitude"),
              subtitle: Text(currentPosition!.longitude.toStringAsFixed(6)),
            ),
          ],
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: currentPosition != null
                    ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
                    : _initialCameraPosition,
                initialZoom: 15.0,
                keepAlive: true, // Keep the map state alive when tab changes
              ),
              children: [
                TileLayer(
                  urlTemplate: mapStyleProvider.currentMapStyle.url, // Use selected map style
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
        onLogout: widget.onLogout, // Pass logout callback to ProfileScreen
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
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color, // Ensure unselected icons are visible in dark mode
        onTap: _onItemTapped,
      ),
    );
  }
}