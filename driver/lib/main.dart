import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth/login_page.dart';
import './screens/tracking_page.dart';
import './providers/theme_provider.dart';
import './providers/map_style_provider.dart'; 




// NEW import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize ThemeProvider and load saved theme preference
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // Initialize MapStyleProvider and load saved map style preference
  final mapStyleProvider = MapStyleProvider();
  await mapStyleProvider.loadMapStyle();

  runApp(
    MultiProvider( // Use MultiProvider to provide multiple ChangeNotifiers
      providers: [
        ChangeNotifierProvider(create: (context) => themeProvider),
        ChangeNotifierProvider(create: (context) => mapStyleProvider), // Provide MapStyleProvider
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
  String? _driverName; // To pass driver name to profile screen

  // Method to handle user logout
  void _logout() {
    setState(() {
      _token = null;
      _driverId = null;
      _driverName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch for theme changes from ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

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
          ? LoginPage(onLoggedIn: (tok, id, name) {
              setState(() {
                _token = tok;
                _driverId = id;
                _driverName = name;
              });
            })
          : TrackingPage(token: _token!, driverId: _driverId!, driverName: _driverName!, onLogout: _logout), // Pass logout callback
    );
  }
}