import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class BluetoothSelectionScreen extends StatefulWidget {
  const BluetoothSelectionScreen({Key? key}) : super(key: key);

  @override
  State<BluetoothSelectionScreen> createState() =>
      _BluetoothSelectionScreenState();
}

class _BluetoothSelectionScreenState extends State<BluetoothSelectionScreen> {
  int? selectedIndex;
  bool isScanning = false;
  List<ScanResult> scanResults = [];
  StreamSubscription<List<ScanResult>>? scanSubscription;
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartScan();
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _checkPermissionsAndStartScan() async {
    // Check Bluetooth permissions
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }

    // Start scanning automatically
    startScanning();
  }

  void startScanning() async {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    try {
      // Check if Bluetooth is on
      var adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please turn on Bluetooth'),
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            isScanning = false;
          });
        }
        return;
      }

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            scanResults = results;
          });
        }
      });

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 15));

      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning: $e')),
        );
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  String getDeviceName(ScanResult result) {
    if (result.device.platformName.isNotEmpty) {
      return result.device.platformName;
    }
    if (result.advertisementData.advName.isNotEmpty) {
      return result.advertisementData.advName;
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header avec AppBar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 212, 209, 209),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Bluetooth Devices',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/map');
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Liste des appareils
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.blue.shade300,
                      Colors.blue.shade200,
                      Colors.blue.shade100,
                    ],
                  ),
                ),
                child: scanResults.isEmpty && !isScanning
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bluetooth_disabled,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No devices found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the search button to scan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        itemCount: scanResults.length,
                        itemBuilder: (context, index) {
                          final result = scanResults[index];
                          final deviceName = getDeviceName(result);
                          final deviceId = result.device.remoteId.toString();
                          final isSelected = selectedDevice == result.device;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDevice = result.device;
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Icône Bluetooth
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: Colors.cyan,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.bluetooth,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Nom et adresse
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          deviceName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          deviceId,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Signal strength indicator
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.signal_cellular_alt,
                                        color: result.rssi > -70
                                            ? Colors.green
                                            : result.rssi > -90
                                                ? Colors.orange
                                                : Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${result.rssi} dBm',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 8),

                                  // Indicateur de sélection
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),

      // Bouton flottant pour scanner
      floatingActionButton: FloatingActionButton(
        onPressed: isScanning ? null : startScanning,
        backgroundColor: Colors.blue,
        child: isScanning
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}
