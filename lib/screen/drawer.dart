import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provaandre2bim/screen/addVehicleScreen.dart';
import 'package:provaandre2bim/screen/historyScreen.dart';
import 'package:provaandre2bim/screen/loginScreen.dart';
import 'package:provaandre2bim/screen/mainScreen.dart';
import 'package:provaandre2bim/screen/perfilScreen.dart';
import 'package:provaandre2bim/screen/vehicleScreen.dart';

class drawer extends StatefulWidget {
  const drawer({super.key});

  @override
  State<drawer> createState() => _drawerState();
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class _drawerState extends State<drawer> {

  User? _user;
  String _userName = "Usuário";

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _getUserData();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
    setState(() {
      _userName = userDoc['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_user!.email!, style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const Divider(),
          ListTile(title: const Text("Home"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>mainScreen()));
          }),
          ListTile(title: const Text("Meus veículos"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>vehicleScreen()));
          },),
          ListTile(title: const Text("Adicionar veículos"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>VehicleRegistrationScreen()));
          },),
          ListTile(title: const Text("Histórico de abastecimentos"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>historyScreen()));
          },),
          ListTile(title: const Text("Perfil"), onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>perfilScreen()));
          },),
          ListTile(
            title: const Text("Logout"),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => loginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
