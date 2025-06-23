// lib/providers/map_style_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum to define different map styles
enum MapStyle {
  osmStandard(
    name: 'Standard OSM',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  ),
  osmHot(
    name: 'Humanitarian OSM',
    url:
        'https://tileserver.memomaps.de/tilegen/{z}/{x}/{y}.png', // OSM Humanitarian
  ),
  osmCyclo(
    name: 'OpenCycleMap',
    url:
        'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=dd553dcab2134a34b5095b7612231152', // Thunderforest Cycle - Requires API Key
  ),
  stamenToner(
    name: 'Stamen Toner',
    url: 'https://stamen-tiles.a.ssl.fastly.net/toner/{z}/{x}/{y}.png',
  ),
  stamenTerrain(
    name: 'Stamen Terrain',
    url: 'https://stamen-tiles.a.ssl.fastly.net/terrain/{z}/{x}/{y}.png',
  );

  const MapStyle({required this.name, required this.url});
  final String name;
  final String url;
}

class MapStyleProvider with ChangeNotifier {
  MapStyle _currentMapStyle = MapStyle.osmStandard; // Default map style

  MapStyle get currentMapStyle => _currentMapStyle;

  // Load map style preference from SharedPreferences
  Future<void> loadMapStyle() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStyleName = prefs.getString('mapStyle');
    if (savedStyleName != null) {
      try {
        _currentMapStyle = MapStyle.values.firstWhere(
          (style) => style.toString() == 'MapStyle.$savedStyleName',
          orElse: () => MapStyle.osmStandard, // Fallback if not found
        );
      } catch (e) {
        print("Error loading map style: $e");
        _currentMapStyle = MapStyle.osmStandard;
      }
    }
    notifyListeners();
  }

  // Set new map style and save preference
  void setMapStyle(MapStyle style) async {
    _currentMapStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mapStyle', style.name); // Save enum name as string
    notifyListeners();
  }
}


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Enum to define different map styles
// enum MapStyle {
//   osmStandard(
//     name: 'Standard OSM',
//     url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//   ),
//   osmHot(
//     name: 'Humanitarian OSM',
//     url:
//         'https://tileserver.memomaps.de/tilegen/{z}/{x}/{y}.png', // OSM Humanitarian
//   ),
//   osmCyclo(
//     name: 'OpenCycleMap',
//     url:
//         'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=dd553dcab2134a34b5095b7612231152', // Thunderforest Cycle - Requires API Key
//   ),
//   stamenToner(
//     name: 'Stamen Toner',
//     url: 'https://stamen-tiles.a.ssl.fastly.net/toner/{z}/{x}/{y}.png',
//   ),
//   stamenTerrain(
//     name: 'Stamen Terrain',
//     url: 'https://stamen-tiles.a.ssl.fastly.net/terrain/{z}/{x}/{y}.png',
//   );

//   const MapStyle({required this.name, required this.url});
//   final String name;
//   final String url;
// }

// class MapStyleProvider with ChangeNotifier {
//   MapStyle _currentMapStyle = MapStyle.osmStandard; // Default map style

//   MapStyle get currentMapStyle => _currentMapStyle;

//   // Load map style preference from SharedPreferences
//   Future<void> loadMapStyle() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedStyleName = prefs.getString('mapStyle');
//     if (savedStyleName != null) {
//       try {
//         _currentMapStyle = MapStyle.values.firstWhere(
//           (style) => style.toString() == 'MapStyle.$savedStyleName',
//           orElse: () => MapStyle.osmStandard, // Fallback if not found
//         );
//       } catch (e) {
//         print("Error loading map style: $e");
//         _currentMapStyle = MapStyle.osmStandard;
//       }
//     }
//     notifyListeners();
//   }

//   // Set new map style and save preference
//   void setMapStyle(MapStyle style) async {
//     _currentMapStyle = style;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('mapStyle', style.name); // Save enum name as string
//     notifyListeners();
//   }
// }
