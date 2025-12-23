import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BikeData {
  final String id;
  final bool isActive;

  BikeData({required this.id, required this.isActive});
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Firestore collection reference
  final CollectionReference _bikesRef =
      FirebaseFirestore.instance.collection('Bike');

  int _countActive(List<QueryDocumentSnapshot> docs) => docs
      .where((d) => (d.data() as Map<String, dynamic>)['Active'] == true)
      .length;

  int _countInactive(List<QueryDocumentSnapshot> docs) => docs
      .where((d) => (d.data() as Map<String, dynamic>)['Active'] != true)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBikeDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _bikesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final total = docs.length;
          final active = _countActive(docs);
          final inactive = _countInactive(docs);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total',
                          value: total.toString(),
                          color: Colors.blue,
                          icon: Icons.pedal_bike,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Active',
                          value: active.toString(),
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Inactive',
                          value: inactive.toString(),
                          color: Colors.red,
                          icon: Icons.cancel,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Bikes Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bikes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/map');
                        },
                        icon: const Icon(Icons.map, size: 18),
                        label: const Text('Show in maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bikes List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final bike = BikeData(
                        id: data['ID']?.toString() ?? doc.id,
                        isActive: data['Active'] == true,
                      );
                      return _buildBikeCardFromDoc(doc, bike);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBikeCard(BikeData bike) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bike Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bike.isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.pedal_bike,
              color: bike.isActive ? Colors.green : Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Bike ID
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bike.id,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: bike.isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bike.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Button
          IconButton(
            onPressed: () {
              // Navigate to map with this specific bike
              Navigator.pushNamed(context, '/map');
            },
            icon: const Icon(Icons.location_on),
            color: Colors.blue,
            iconSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildBikeCardFromDoc(QueryDocumentSnapshot doc, BikeData bike) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bike Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bike.isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.pedal_bike,
              color: bike.isActive ? Colors.green : Colors.red,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Bike ID and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bike.id,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: bike.isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bike.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions: location, edit, delete
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/map');
            },
            icon: const Icon(Icons.location_on),
            color: Colors.blue,
            iconSize: 28,
          ),
          IconButton(
            onPressed: () => _showEditBikeDialog(context, doc),
            icon: const Icon(Icons.edit),
            color: Colors.orange,
          ),
          IconButton(
            onPressed: () => _deleteBike(context, doc),
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBikeDialog(BuildContext context) async {
    final TextEditingController idController = TextEditingController();
    bool isActive = false;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bike'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'Bike ID'),
            ),
            Row(
              children: [
                const Text('Active'),
                const SizedBox(width: 8),
                StatefulBuilder(builder: (context, setState) {
                  return Switch(
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
                  );
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = idController.text.trim();
              if (id.isEmpty) return;
              try {
                await _bikesRef.add({'ID': id, 'Active': isActive});
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bike added')));
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditBikeDialog(
      BuildContext context, QueryDocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final TextEditingController idController =
        TextEditingController(text: data['ID']?.toString() ?? '');
    bool isActive = data['Active'] == true;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bike'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(labelText: 'Bike ID'),
            ),
            Row(
              children: [
                const Text('Active'),
                const SizedBox(width: 8),
                StatefulBuilder(builder: (context, setState) {
                  return Switch(
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v),
                  );
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = idController.text.trim();
              if (id.isEmpty) return;
              try {
                await _bikesRef
                    .doc(doc.id)
                    .update({'ID': id, 'Active': isActive});
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bike updated')));
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBike(
      BuildContext context, QueryDocumentSnapshot doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bike'),
        content: const Text('Are you sure you want to delete this bike?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _bikesRef.doc(doc.id).delete();
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Bike deleted')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
