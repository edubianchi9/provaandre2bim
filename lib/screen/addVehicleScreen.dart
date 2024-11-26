import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provaandre2bim/screen/drawer.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _fuelController = TextEditingController();
  final _mileageController = TextEditingController();
  final _averageController = TextEditingController();

  Future<void> _saveVehicle() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      final vehicleData = {
        'name': _nameController.text,
        'model': _modelController.text,
        'year': _yearController.text,
        'placa': _plateController.text,
        'liters': double.tryParse(_fuelController.text) ?? 0.0,
        'kilometrage': int.tryParse(_mileageController.text) ?? 0,
        'average': double.tryParse(_averageController.text) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final carRef = await FirebaseFirestore.instance.collection('cars').add(vehicleData);
      final userId = user.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('mycars')
          .doc(carRef.id)
          .set(vehicleData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo registrado com sucesso!')),
      );

      _clearFormFields();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $error')),
      );
    }
  }

  void _clearFormFields() {
    _nameController.clear();
    _modelController.clear();
    _yearController.clear();
    _plateController.clear();
    _fuelController.clear();
    _mileageController.clear();
    _averageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Veículo")),
      drawer: drawer(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nome',
                validatorMessage: 'Informe o nome',
              ),
              _buildTextField(
                controller: _modelController,
                label: 'Modelo',
                validatorMessage: 'Informe o modelo',
              ),
              _buildTextField(
                controller: _yearController,
                label: 'Ano',
                validatorMessage: 'Informe o ano',
              ),
              _buildTextField(
                controller: _plateController,
                label: 'Placa',
                validatorMessage: 'Informe a placa',
              ),
              _buildTextField(
                controller: _fuelController,
                label: 'Litros iniciais',
                keyboardType: TextInputType.number,
                validatorMessage: 'Informe os litros',
              ),
              _buildTextField(
                controller: _mileageController,
                label: 'Quilometragem',
                keyboardType: TextInputType.number,
                validatorMessage: 'Informe a quilometragem',
              ),
              _buildTextField(
                controller: _averageController,
                label: 'Média',
                keyboardType: TextInputType.number,
                validatorMessage: 'Informe a média',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Cadastrar"),
        icon: const Icon(Icons.add),
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _saveVehicle();
          }
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validatorMessage,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) =>
        value == null || value.isEmpty ? validatorMessage : null,
      ),
    );
  }
}
