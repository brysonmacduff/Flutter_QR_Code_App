import 'package:flutter/material.dart';
//import 'package:web3dart/web3dart.dart';

class SmartContract extends StatelessWidget {
  const SmartContract({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Contract"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
    );
  }
}
