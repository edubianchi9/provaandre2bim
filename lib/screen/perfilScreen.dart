import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provaandre2bim/screen/drawer.dart';

class perfilScreen extends StatefulWidget {
  const perfilScreen({super.key});

  @override
  State<perfilScreen> createState() => _perfilScreenState();
}

class _perfilScreenState extends State<perfilScreen> {
  User? user;
  String? email;
  String? name;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          name = data['name'] ?? 'Nome não disponível';
          email = user!.email ?? 'Email não disponível';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
      ),
      drawer: drawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Text(
                        (name?.substring(0, 1).toUpperCase() ?? '?'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name ?? 'Carregando...',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email ?? 'Carregando...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text(
                  "Informações Adicionais",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Você pode visualizar suas informações aqui.",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
