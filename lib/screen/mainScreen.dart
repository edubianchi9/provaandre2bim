import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provaandre2bim/screen/drawer.dart';

class mainScreen extends StatefulWidget {
  const mainScreen({super.key});

  @override
  State<mainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  User? _user;
  String _userName = "Usuário";

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    if (_user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['nome'] ?? 'Usuário';
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getCars() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('cars').get();
      List<Map<String, dynamic>> carsList = [];
      querySnapshot.docs.forEach((doc) {
        carsList.add(doc.data() as Map<String, dynamic>);
      });
      return carsList;
    } catch (e) {
      print("Erro ao buscar carros: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      drawer: drawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getCars(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar carros'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhum carro cadastrado.'));
                  } else {
                    List<Map<String, dynamic>> cars = snapshot.data!;
                    return ListView.builder(
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        var car = cars[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car['name'] ?? 'Nome desconhecido',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Modelo: ${car['model'] ?? 'Desconhecido'}',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      car['year'] ?? 'Ano desconhecido',
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16, color: Colors.grey),
                                Text(
                                  'Placa: ${car['placa'] ?? 'Não informada'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Quilometragem: ${car['kilometrage'] ?? 'Não informado'} km',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Litros abastecidos: ${car['liters'] ?? 'Não informado'} L',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );

                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}