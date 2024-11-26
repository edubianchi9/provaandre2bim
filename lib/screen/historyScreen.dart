import 'package:flutter/material.dart';
import 'package:provaandre2bim/screen/drawer.dart';

class historyScreen extends StatefulWidget {
  const historyScreen({super.key});

  @override
  State<historyScreen> createState() => _historyScreenState();
}

class _historyScreenState extends State<historyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: drawer(),
      body: Center(child: Text("Histórico de abastecimentos")),
    );
  }
}
