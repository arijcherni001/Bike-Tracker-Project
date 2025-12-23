import 'package:bike_tracker_app/screens/admin_dashboard.dart';
import 'package:bike_tracker_app/screens/affichage.dart';
import 'package:bike_tracker_app/screens/ble.dart';
import 'package:bike_tracker_app/screens/historique.dart';
import 'package:bike_tracker_app/screens/login.dart';
import 'package:bike_tracker_app/screens/map_screen.dart';
import 'package:bike_tracker_app/screens/profil.dart';
import 'package:bike_tracker_app/screens/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> askBluetoothPermissions() async {
  // Android 12+ requires BLUETOOTH_SCAN + BLUETOOTH_CONNECT
  await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetooth,
    Permission.location, // parfois nécessaire
  ].request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await askBluetoothPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BikeTracker - Smart Bike Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Gérer les routes avec arguments
        if (settings.name == '/map') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => MapScreen(
              bluetoothLatitude: args?['bluetoothLatitude'],
              bluetoothLongitude: args?['bluetoothLongitude'],
            ),
          );
        }
        // Routes par défaut
        return null;
      },
      routes: {
        '/': (context) => const Welcome(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const CreateAccountScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/profile': (context) => const ProfilePage(),
        '/ble': (context) => const BluetoothSelectionScreen(),
        '/historique': (context) => const BikeTrackerDetailsScreen(),
        '/affichage': (context) => const AffichageScreen(),
      },
    );
  }
}
