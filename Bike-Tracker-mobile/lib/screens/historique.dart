import 'package:flutter/material.dart';
class BikeTrackerDetailsScreen extends StatefulWidget {
  const BikeTrackerDetailsScreen({Key? key}) : super(key: key);

  @override
  State<BikeTrackerDetailsScreen> createState() => _BikeTrackerDetailsScreenState();
}

class _BikeTrackerDetailsScreenState extends State<BikeTrackerDetailsScreen> {
  bool isConnected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 7, 10, 207),
              Color.fromARGB(255, 50, 135, 205),
              Color.fromARGB(255, 121, 138, 236),
              
              
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar personnalisée
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {},
                    ),
                    const Expanded(
                      child: Text(
                        'BikeTracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.battery_full, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Zone de contenu avec fond blanc
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Boutons Connected/Disconnect
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isConnected ? Colors.green.shade100 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isConnected ? Colors.green : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Connected',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isConnected ? Colors.green.shade700 : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isConnected = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: Colors.red.shade700,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: Colors.red.shade200),
                                  ),
                                ),
                                child: const Text(
                                  'Disconnect',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Informations du dispositif
                        _buildInfoRow('Custom UUID :', '00000ffe0-0000-1000-8000-00805f9b34fb'),
                        _buildInfoRow('Date :', '11/7/2023'),
                        _buildInfoRow('Temps :', '13:28:56'),
                        _buildInfoRow('Latitude :', '36.89761'),
                        _buildInfoRow('Longitude :', '10.19150'),
                        _buildInfoRow('Vitesse :', '0 Km/h'),
                        _buildInfoRow('Distance parcourue :', '0 Km'),

                        const SizedBox(height: 32),

                        // Boutons d'action
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Start Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'End Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'History',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: ' $value',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}