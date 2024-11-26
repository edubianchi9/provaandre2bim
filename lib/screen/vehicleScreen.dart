import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provaandre2bim/screen/drawer.dart';
import 'package:provaandre2bim/screen/vehicleInfoScreen.dart';

class vehicleScreen extends StatefulWidget {
  const vehicleScreen({super.key});

  @override
  State<vehicleScreen> createState() => _vehicleScreenState();
}

class _vehicleScreenState extends State<vehicleScreen> {
  User? _currentUser;
  String _displayName = "Usuário";

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (_currentUser != null) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          _displayName = userSnapshot['nome'] ?? 'Usuário';
        });
      } else {
        debugPrint("Usuário não encontrado no Firestore.");
      }
    }
  }

  Future<List<Map<String, dynamic>>> _retrieveUserVehicles() async {
    if (_currentUser == null) {
      debugPrint("Nenhum usuário autenticado.");
      return [];
    }

    try {
      final vehiclesQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('mycars')
          .get();

      return vehiclesQuery.docs.map((doc) {
        final vehicleData = doc.data() as Map<String, dynamic>;
        return {
          ...vehicleData,
          'id': doc.id,
          'liters': vehicleData['liters'] ?? 0.0,
          'kilometrage': vehicleData['kilometrage'] ?? 0,
          'average': vehicleData['average'] ?? 0.0,
        };
      }).toList();
    } catch (error) {
      debugPrint("Erro ao carregar veículos: $error");
      return [];
    }
  }

  Future<void> _removeVehicle(String vehicleId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('mycars')
          .doc(vehicleId)
          .delete();

      await FirebaseFirestore.instance.collection('cars').doc(vehicleId).delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veículo removido com sucesso!'),
      ));
      setState(() {});
    } catch (error) {
      debugPrint("Erro ao remover veículo: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Falha ao excluir o veículo.'),
      ));
    }
  }

  void _openEditDialog(BuildContext context, Map<String, dynamic> vehicle) {
    final nameController = TextEditingController(text: vehicle['name']);
    final modelController = TextEditingController(text: vehicle['model']);
    final litersController = TextEditingController(text: vehicle['liters'].toString());
    final kilometrageController =
    TextEditingController(text: vehicle['kilometrage'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Atualizar veículo"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nome"),
                ),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: "Modelo"),
                ),
                TextField(
                  controller: litersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Litros"),
                ),
                TextField(
                  controller: kilometrageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quilometragem"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'name': nameController.text.trim(),
                  'model': modelController.text.trim(),
                  'liters': double.tryParse(litersController.text.trim()) ?? 0.0,
                  'kilometrage': int.tryParse(kilometrageController.text.trim()) ?? 0,
                };

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .collection('mycars')
                      .doc(vehicle['id'])
                      .update(updatedData);

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Informações do veículo atualizadas."),
                  ));
                  Navigator.pop(context);
                  setState(() {});
                } catch (error) {
                  debugPrint("Erro ao atualizar veículo: $error");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Erro: $error"),
                  ));
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veículos cadastrados"),
      ),
      drawer: const drawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _retrieveUserVehicles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                  child: Text("Erro ao carregar a lista de veículos."));
            }
            final vehicles = snapshot.data ?? [];
            if (vehicles.isEmpty) {
              return const Center(child: Text("Nenhum veículo encontrado."));
            }
            return ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => vehicleInfoScreen(car: vehicle),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            child: Text(
                              (vehicle['name']?.substring(0, 1).toUpperCase() ?? '?'),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle['name'] ?? 'Nome não informado',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Modelo: ${vehicle['model'] ?? 'Desconhecido'}',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openEditDialog(context, vehicle),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeVehicle(vehicle['id']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              },
            );
          },
        ),
      ),
    );
  }
}
