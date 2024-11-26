import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class vehicleInfoScreen extends StatefulWidget {
  final Map<String, dynamic> car;

  const vehicleInfoScreen({Key? key, required this.car}) : super(key: key);

  @override
  State<vehicleInfoScreen> createState() => _vehicleInfoScreenState();
}

class _vehicleInfoScreenState extends State<vehicleInfoScreen> {
  late Map<String, dynamic> car;

  @override
  void initState() {
    super.initState();
    car = widget.car;
  }

  Future<void> _updateCarFirestore(String carId, Map<String, dynamic> updates) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Usuário não autenticado");

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final carRef = FirebaseFirestore.instance.collection('cars').doc(carId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(carRef, updates);
      transaction.set(userRef.collection('mycars').doc(carId), updates, SetOptions(merge: true));
    });
  }

  Future<void> _handleFuelUpdate(BuildContext context, double liters, int kilometrage) async {
    try {
      final previousKilometrage = car['kilometrage'] ?? 0;
      if (kilometrage <= previousKilometrage) throw Exception("Quilometragem inválida.");

      // Atualizar média de consumo
      final distance = kilometrage - previousKilometrage;
      final average = distance / liters;

      // Atualizar Firestore
      await _updateCarFirestore(car['id'], {
        'liters': FieldValue.increment(liters),
        'kilometrage': kilometrage,
        'average': average,
      });

      // Atualizar estado local
      setState(() {
        car['liters'] = (car['liters'] ?? 0) + liters;
        car['kilometrage'] = kilometrage;
        car['average'] = average;
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dados atualizados com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar: $e")),
      );
    }
  }

  void _showFuelDialog(BuildContext context) {
    final TextEditingController litersController = TextEditingController();
    final TextEditingController kilometrageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Abastecer Veículo", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: litersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Litros abastecidos",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: kilometrageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quilometragem atual",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final liters = double.tryParse(litersController.text);
                  final kilometrage = int.tryParse(kilometrageController.text);

                  if (liters == null || kilometrage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor, insira valores válidos.")),
                    );
                    return;
                  }

                  _handleFuelUpdate(context, liters, kilometrage);
                },
                child: const Text("Salvar"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(car['name'] ?? 'Veículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nome: ${car['name'] ?? 'Desconhecido'}"),
            Text("Modelo: ${car['model'] ?? 'Desconhecido'}"),
            Text("Ano: ${car['year'] ?? 'Desconhecido'}"),
            Text("Placa: ${car['placa'] ?? 'Desconhecido'}"),
            Text("Kilometragem: ${car['kilometrage'] ?? 'Não informado'}"),
            Text("Litros abastecidos: ${car['liters'] ?? 'Não informado'}"),
            Text("Média de consumo: ${car['average']?.toStringAsFixed(2) ?? 'Não informado'}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showFuelDialog(context),
              child: const Text("Abastecer"),
            ),
          ],
        ),
      ),
    );
  }
}
