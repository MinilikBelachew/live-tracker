import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import '../screens/tracking_page.dart';
import '../providers/theme_provider.dart';
import '../providers/map_style_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize ThemeProvider and load saved theme preference
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // Initialize MapStyleProvider and load saved map style preference
  final mapStyleProvider = MapStyleProvider();
  await mapStyleProvider.loadMapStyle();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => themeProvider),
        ChangeNotifierProvider(create: (context) => mapStyleProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;
  int? _driverId;
  String? _driverName;
  bool _isLoadingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status on app start
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final storedDriverId = prefs.getInt('driverId');
    final storedDriverName = prefs.getString('driverName');

    if (storedToken != null && storedDriverId != null && storedDriverName != null) {
      setState(() {
        _token = storedToken;
        _driverId = storedDriverId;
        _driverName = storedDriverName;
        _isLoadingAuth = false;
      });
    } else {
      setState(() {
        _isLoadingAuth = false;
      });
    }
  }

  // Method to handle user logout
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('driverId');
    await prefs.remove('driverName');
    setState(() {
      _token = null;
      _driverId = null;
      _driverName = null;
    });
  }

  // Method to handle successful login and save credentials
  void _onLoggedIn(String token, int driverId, String driverName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('driverId', driverId);
    await prefs.setString('driverName', driverName);
    setState(() {
      _token = token;
      _driverId = driverId;
      _driverName = driverName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoadingAuth) {
      return MaterialApp(
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        themeMode: themeProvider.themeMode, // Apply theme to loading screen too
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      );
    }

    return MaterialApp(
      title: 'Driver Tracker',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: Colors.blue.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        listTileTheme: ListTileThemeData(
          iconColor: Colors.blue[800],
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue;
            }
            return Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue.withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.5);
          }),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.indigo,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        cardTheme: CardTheme(
          color: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        listTileTheme: ListTileThemeData(
          iconColor: Colors.indigo[300],
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.indigo;
            }
            return Colors.grey[600];
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.indigo.withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.5);
          }),
        ),
      ),
      home: _token == null
          ? LoginPage(onLoggedIn: _onLoggedIn) // Pass _onLoggedIn callback
          : TrackingPage(token: _token!, driverId: _driverId!, driverName: _driverName!, onLogout: _logout),
    );
  }
}

// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // NEW: Import SharedPreferences
// import '../auth/login_page.dart';
// import '../screens/tracking_page.dart';
// import '../providers/theme_provider.dart';
// import '../providers/map_style_provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Initialize ThemeProvider and load saved theme preference
//   final themeProvider = ThemeProvider();
//   await themeProvider.loadTheme();

//   // Initialize MapStyleProvider and load saved map style preference
//   final mapStyleProvider = MapStyleProvider();
//   await mapStyleProvider.loadMapStyle();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => themeProvider),
//         ChangeNotifierProvider(create: (context) => mapStyleProvider),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String? _token;
//   int? _driverId;
//   String? _driverName;
//   bool _isLoadingAuth = true; // NEW: To show loading indicator while checking auth

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus(); // NEW: Check login status on app start
//   }

//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedToken = prefs.getString('token');
//     final storedDriverId = prefs.getInt('driverId');
//     final storedDriverName = prefs.getString('driverName');

//     if (storedToken != null && storedDriverId != null && storedDriverName != null) {
//       setState(() {
//         _token = storedToken;
//         _driverId = storedDriverId;
//         _driverName = storedDriverName;
//         _isLoadingAuth = false;
//       });
//     } else {
//       setState(() {
//         _isLoadingAuth = false;
//       });
//     }
//   }

//   // Method to handle user logout
//   void _logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('token');
//     await prefs.remove('driverId');
//     await prefs.remove('driverName');
//     setState(() {
//       _token = null;
//       _driverId = null;
//       _driverName = null;
//     });
//   }

//   // Method to handle successful login and save credentials
//   void _onLoggedIn(String token, int driverId, String driverName) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('token', token);
//     await prefs.setInt('driverId', driverId);
//     await prefs.setString('driverName', driverName);
//     setState(() {
//       _token = token;
//       _driverId = driverId;
//       _driverName = driverName;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     if (_isLoadingAuth) {
//       return MaterialApp(
//         home: const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         ),
//         themeMode: themeProvider.themeMode, // Apply theme to loading screen too
//         theme: ThemeData.light(),
//         darkTheme: ThemeData.dark(),
//       );
//     }

//     return MaterialApp(
//       title: 'Driver Tracker',
//       themeMode: themeProvider.themeMode,
//       theme: ThemeData.light().copyWith(
//         primaryColor: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.blue,
//           foregroundColor: Colors.white,
//         ),
//         cardTheme: CardTheme(
//           color: Colors.blue.shade50,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: 2,
//         ),
//         listTileTheme: ListTileThemeData(
//           iconColor: Colors.blue[800],
//         ),
//         switchTheme: SwitchThemeData(
//           thumbColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.selected)) {
//               return Colors.blue;
//             }
//             return Colors.grey;
//           }),
//           trackColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.selected)) {
//               return Colors.blue.withOpacity(0.5);
//             }
//             return Colors.grey.withOpacity(0.5);
//           }),
//         ),
//       ),
//       darkTheme: ThemeData.dark().copyWith(
//         primaryColor: Colors.indigo,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.indigo,
//           foregroundColor: Colors.white,
//         ),
//         scaffoldBackgroundColor: Colors.grey[900],
//         cardColor: Colors.grey[850],
//         cardTheme: CardTheme(
//           color: Colors.grey[850],
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: 2,
//         ),
//         listTileTheme: ListTileThemeData(
//           iconColor: Colors.indigo[300],
//         ),
//         switchTheme: SwitchThemeData(
//           thumbColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.selected)) {
//               return Colors.indigo;
//             }
//             return Colors.grey[600];
//           }),
//           trackColor: MaterialStateProperty.resolveWith((states) {
//             if (states.contains(MaterialState.selected)) {
//               return Colors.indigo.withOpacity(0.5);
//             }
//             return Colors.grey.withOpacity(0.5);
//           }),
//         ),
//       ),
//       home: _token == null
//           ? LoginPage(onLoggedIn: _onLoggedIn) // Pass _onLoggedIn callback
//           : TrackingPage(token: _token!, driverId: _driverId!, driverName: _driverName!, onLogout: _logout),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import './auth/login_page.dart';
// import './screens/tracking_page.dart';
// import './providers/theme_provider.dart';
// import './providers/map_style_provider.dart'; 




// // NEW import

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Initialize ThemeProvider and load saved theme preference
//   final themeProvider = ThemeProvider();
//   await themeProvider.loadTheme();

//   // Initialize MapStyleProvider and load saved map style preference
//   final mapStyleProvider = MapStyleProvider();
//   await mapStyleProvider.loadMapStyle();

//   runApp(
//     MultiProvider( // Use MultiProvider to provide multiple ChangeNotifiers
//       providers: [
//         ChangeNotifierProvider(create: (context) => themeProvider),
//         ChangeNotifierProvider(create: (context) => mapStyleProvider), // Provide MapStyleProvider
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String? _token;
//   int? _driverId;
//   String? _driverName; // To pass driver name to profile screen

//   // Method to handle user logout
//   void _logout() {
//     setState(() {
//       _token = null;
//       _driverId = null;
//       _driverName = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Watch for theme changes from ThemeProvider
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return MaterialApp(
//       title: 'Driver Tracker',
//       themeMode: themeProvider.themeMode,
//       theme: ThemeData.light().copyWith(
//         primaryColor: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.blue,
//           foregroundColor: Colors.white,
//         ),
//         cardTheme: CardTheme(
//           color: Colors.blue.shade50,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: 2,
//         ),
//         listTileTheme: ListTileThemeData(
//           iconColor: Colors.blue[800],
//         ),
//         switchTheme: SwitchThemeData(
//           thumbColor: WidgetStateProperty.resolveWith((states) {
//             if (states.contains(WidgetState.selected)) {
//               return Colors.blue;
//             }
//             return Colors.grey;
//           }),
//           trackColor: WidgetStateProperty.resolveWith((states) {
//             if (states.contains(WidgetState.selected)) {
//               return Colors.blue.withOpacity(0.5);
//             }
//             return Colors.grey.withOpacity(0.5);
//           }),
//         ),
//       ),
//       darkTheme: ThemeData.dark().copyWith(
//         primaryColor: Colors.indigo,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.indigo,
//           foregroundColor: Colors.white,
//         ),
//         scaffoldBackgroundColor: Colors.grey[900],
//         cardColor: Colors.grey[850],
//         cardTheme: CardTheme(
//           color: Colors.grey[850],
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: 2,
//         ),
//         listTileTheme: ListTileThemeData(
//           iconColor: Colors.indigo[300],
//         ),
//         switchTheme: SwitchThemeData(
//           thumbColor: WidgetStateProperty.resolveWith((states) {
//             if (states.contains(WidgetState.selected)) {
//               return Colors.indigo;
//             }
//             return Colors.grey[600];
//           }),
//           trackColor: WidgetStateProperty.resolveWith((states) {
//             if (states.contains(WidgetState.selected)) {
//               return Colors.indigo.withOpacity(0.5);
//             }
//             return Colors.grey.withOpacity(0.5);
//           }),
//         ),
//       ),
//       home: _token == null
//           ? LoginPage(onLoggedIn: (tok, id, name) {
//               setState(() {
//                 _token = tok;
//                 _driverId = id;
//                 _driverName = name;
//               });
//             })
//           : TrackingPage(token: _token!, driverId: _driverId!, driverName: _driverName!, onLogout: _logout), // Pass logout callback
//     );
//   }
// }