import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Import for SocketException
import 'dart:async'; // Import for TimeoutException

class LoginPage extends StatefulWidget {
  final Function(String, int, String) onLoggedIn; // Added String for driverName
  const LoginPage({super.key, required this.onLoggedIn});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  // Replace with your computer's IP address and ensure it's a plain URL string
  final String serverUrl = 'http://192.168.235.177:4000';

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$serverUrl/drivers/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mdtUsername': userCtrl.text.trim(),
          'password': passCtrl.text,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Pass driver name as well
        widget.onLoggedIn(data['token'], data['driverId'], data['name']);
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: Cannot connect to server. Please check your connection and server IP ($serverUrl)')),
      );
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection timeout: Server is not responding')),
      );
    } on http.ClientException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('HTTP error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(
                labelText: 'MDT Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('LOGIN', style: TextStyle(fontSize: 18)),
                  ),
            const SizedBox(height: 20),
            Text(
              'Server: $serverUrl',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:io'; // For SocketException
// import 'dart:async'; // For TimeoutException

// class LoginPage extends StatefulWidget {
//   final Function(String, int, String) onLoggedIn; // token, driverId, driverName
//   const LoginPage({super.key, required this.onLoggedIn});

//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController userCtrl = TextEditingController();
//   final TextEditingController passCtrl = TextEditingController();
//   bool isLoading = false;
//   bool obscurePassword = true;

//   // Replace with your server URL (without any formatting characters)
//   final String serverUrl = 'http://192.168.235.177:4000';

//   Future<void> login() async {
//     // Validate inputs
//     if (userCtrl.text.isEmpty || passCtrl.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter both username and password')),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final response = await http.post(
//         Uri.parse('$serverUrl/drivers/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'mdtUsername': userCtrl.text.trim(),
//           'password': passCtrl.text,
//         }),
//       ).timeout(const Duration(seconds: 10));

//       final responseData = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         // Successful login
//         widget.onLoggedIn(
//           responseData['token'],
//           responseData['driverId'],
//           responseData['name'],
//         );
//       } else {
//         // Handle server errors
//         final error = responseData['error'] ?? 'Login failed. Please try again.';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(error)),
//         );
//       }
//     } on SocketException {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Network error: Cannot connect to server')),
//       );
//     } on TimeoutException {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Connection timeout: Server not responding')),
//       );
//     } on http.ClientException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('HTTP error: ${e.message}')),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Unexpected error: ${e.toString()}')),
//       );
//     } finally {
//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Driver Login'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 40),
//             const Icon(
//               Icons.account_circle,
//               size: 100,
//               color: Colors.blue,
//             ),
//             const SizedBox(height: 30),
//             TextField(
//               controller: userCtrl,
//               decoration: const InputDecoration(
//                 labelText: 'MDT Username',
//                 prefixIcon: Icon(Icons.person),
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.text,
//               textInputAction: TextInputAction.next,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: passCtrl,
//               obscureText: obscurePassword,
//               decoration: InputDecoration(
//                 labelText: 'Password',
//                 prefixIcon: const Icon(Icons.lock),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     obscurePassword ? Icons.visibility : Icons.visibility_off,
//                   ),
//                   onPressed: () {
//                     setState(() => obscurePassword = !obscurePassword);
//                   },
//                 ),
//                 border: const OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.visiblePassword,
//               textInputAction: TextInputAction.done,
//               onSubmitted: (_) => login(),
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : login,
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'LOGIN',
//                         style: TextStyle(fontSize: 18),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Server: $serverUrl',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     userCtrl.dispose();
//     passCtrl.dispose();
//     super.dispose();
//   }
// }