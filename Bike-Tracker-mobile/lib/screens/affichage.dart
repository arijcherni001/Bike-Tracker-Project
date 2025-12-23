import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:typed_data';

class AffichageScreen extends StatefulWidget {
  const AffichageScreen({Key? key}) : super(key: key);

  @override
  State<AffichageScreen> createState() => _AffichageScreenState();
}

class _AffichageScreenState extends State<AffichageScreen> {
  // Bluetooth
  BluetoothConnection? connection;
  bool isConnected = false;
  bool isConnecting = false;
  Timer? _timer;

  // Données reçues du Bluetooth GPS
  String status = 'Disconnected';
  double latitude = 0.0;
  double longitude = 0.0;
  double altitude = 0.0;
  int satellites = 0;
  String customUUID = '0D00ffeO-OODD-10DD-8000-DD805f9b34fb';

  String receivedData = '';

  // Date et heure locales
  String currentDate = '';
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    connection?.dispose();
    super.dispose();
  }

  // Mettre à jour la date et l'heure locale
  void _updateDateTime() {
    setState(() {
      DateTime now = DateTime.now();
      currentDate = DateFormat('dd/MM/yyyy').format(now);
      currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  // Timer pour mettre à jour l'heure chaque seconde
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  // Demander les permissions Bluetooth
  Future<bool> _requestBluetoothPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.location,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (!allGranted) {
        _showSnackBar('Permissions Bluetooth requises pour se connecter');
      }

      return allGranted;
    } catch (e) {
      print('Erreur lors de la demande de permissions: $e');
      return false;
    }
  }

  // Connexion Bluetooth
  Future<void> _connectToBluetooth() async {
    // Vérifier et demander les permissions d'abord
    bool permissionsGranted = await _requestBluetoothPermissions();
    if (!permissionsGranted) {
      return;
    }

    setState(() {
      isConnecting = true;
    });

    try {
      // Vérifier si le Bluetooth est activé
      bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (isEnabled == false) {
        _showSnackBar('Veuillez activer le Bluetooth');
        setState(() {
          isConnecting = false;
        });
        return;
      }

      // Afficher la liste des appareils Bluetooth disponibles
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();

      if (devices.isEmpty) {
        _showSnackBar('Aucun appareil Bluetooth couplé trouvé');
        setState(() {
          isConnecting = false;
        });
        return;
      }

      // Chercher le module HC-05 ou HC-06
      BluetoothDevice? targetDevice;
      for (var device in devices) {
        if (device.name?.contains('HC-') ?? false) {
          targetDevice = device;
          break;
        }
      }

      if (targetDevice == null) {
        // Si pas trouvé, afficher la liste pour que l'utilisateur choisisse
        targetDevice = await _showDevicesList(devices);
      }

      if (targetDevice != null) {
        // Se connecter à l'appareil
        BluetoothConnection conn = await BluetoothConnection.toAddress(
          targetDevice.address,
        );

        setState(() {
          connection = conn;
          isConnected = true;
          isConnecting = false;
        });

        _showSnackBar('Connecté à ${targetDevice.name}');

        // Écouter les données reçues
        _listenToBluetoothData();
      } else {
        setState(() {
          isConnecting = false;
        });
      }
    } catch (e) {
      _showSnackBar('Erreur de connexion: $e');
      print('Erreur détaillée: $e');
      setState(() {
        isConnecting = false;
        isConnected = false;
      });
    }
  }

  // Afficher la liste des appareils Bluetooth
  Future<BluetoothDevice?> _showDevicesList(
    List<BluetoothDevice> devices,
  ) async {
    return await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir un appareil'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devices[index].name ?? 'Appareil inconnu'),
                  subtitle: Text(devices[index].address),
                  onTap: () {
                    Navigator.pop(context, devices[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Écouter les données Bluetooth
  void _listenToBluetoothData() {
    connection?.input?.listen((Uint8List data) {
      // Convertir les données reçues en String
      String dataString = String.fromCharCodes(data);
      receivedData += dataString;

      // Parser les données quand on a reçu une ligne complète
      if (receivedData.contains('\n')) {
        _parseReceivedData(receivedData);
        receivedData = ''; // Réinitialiser pour la prochaine trame
      }
    }).onDone(() {
      setState(() {
        isConnected = false;
      });
      _showSnackBar('Connexion Bluetooth perdue');
    });
  }

  // Parser les données reçues du GPS Bluetooth
  void _parseReceivedData(String data) {
    try {
      // Format attendu:
      // "Status      : A" ou "V"
      // "Latitude    : 300.21"
      // "Longitude   : 2554"
      // "Altitude    : 515"
      // "Satellites  : 5"

      List<String> lines = data.split('\n');

      setState(() {
        for (String line in lines) {
          String trimmedLine = line.trim();

          if (trimmedLine.contains('Status')) {
            // Extraire le statut (A = Active/Valid, V = Void/Invalid)
            var parts = trimmedLine.split(':');
            if (parts.length >= 2) {
              String statusValue = parts[1].trim();
              status = statusValue == 'A' ? 'GPS Active' : 'GPS Signal Faible';
            }
          } else if (trimmedLine.contains('Latitude')) {
            // Extraire la latitude
            var parts = trimmedLine.split(':');
            if (parts.length >= 2) {
              latitude = double.tryParse(parts[1].trim()) ?? latitude;
            }
          } else if (trimmedLine.contains('Longitude')) {
            // Extraire la longitude
            var parts = trimmedLine.split(':');
            if (parts.length >= 2) {
              longitude = double.tryParse(parts[1].trim()) ?? longitude;
            }
          } else if (trimmedLine.contains('Altitude')) {
            // Extraire l'altitude
            var parts = trimmedLine.split(':');
            if (parts.length >= 2) {
              altitude = double.tryParse(parts[1].trim()) ?? altitude;
            }
          } else if (trimmedLine.contains('Satellites')) {
            // Extraire le nombre de satellites
            var parts = trimmedLine.split(':');
            if (parts.length >= 2) {
              satellites = int.tryParse(parts[1].trim()) ?? satellites;
            }
          }
        }
      });

      print(
          'Données reçues - Status: $status, Lat: $latitude, Long: $longitude, Alt: $altitude, Sat: $satellites');
    } catch (e) {
      print('Erreur de parsing: $e - Data: $data');
    }
  }

  // Déconnexion Bluetooth
  void _disconnectBluetooth() {
    connection?.dispose();
    setState(() {
      isConnected = false;
      connection = null;
    });
    _showSnackBar('Déconnecté');
  }

  // Envoyer une commande au STM32
  void _sendCommand(String command) {
    if (connection != null && isConnected) {
      connection!.output.add(Uint8List.fromList(utf8.encode(command + '\n')));
      _showSnackBar('Commande envoyée: $command');
    } else {
      _showSnackBar('Pas de connexion Bluetooth');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4D7E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'BikeTracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.battery_full, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8EAF6), Color(0xFFC5CAE9), Color(0xFF9FA8DA)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Status Connection
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? Colors.green.shade50
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isConnecting
                          ? null
                          : () {
                              if (isConnected) {
                                _disconnectBluetooth();
                              } else {
                                _connectToBluetooth();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade100,
                        foregroundColor: const Color(0xFF1B4D7E),
                        elevation: 0,
                      ),
                      child: Text(
                        isConnecting
                            ? 'Connexion...'
                            : (isConnected ? 'Disconnect' : 'Connect'),
                      ),
                    ),
                  ],
                ),
              ),

              // Information Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Custom UUID :', customUUID),
                    const SizedBox(height: 12),
                    _buildInfoRow('Date :', currentDate),
                    const SizedBox(height: 12),
                    _buildInfoRow('Temps :', currentTime),
                    const SizedBox(height: 12),
                    _buildInfoRow('Status GPS :', status),
                    const SizedBox(height: 12),
                    _buildInfoRow('Latitude :', latitude.toStringAsFixed(5)),
                    const SizedBox(height: 12),
                    _buildInfoRow('Longitude :', longitude.toStringAsFixed(5)),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        'Altitude :', '${altitude.toStringAsFixed(1)} m'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Satellites :', satellites.toString()),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _sendCommand('GET_DATA');
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualiser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: const Color(0xFF1B4D7E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Ouvrir la carte avec la position GPS actuelle
                          if (latitude != 0.0 && longitude != 0.0) {
                            Navigator.pushNamed(
                              context,
                              '/map',
                              arguments: {
                                'bluetoothLatitude': latitude,
                                'bluetoothLongitude': longitude,
                              },
                            );
                          } else {
                            _showSnackBar('Position GPS non disponible');
                          }
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Carte'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
