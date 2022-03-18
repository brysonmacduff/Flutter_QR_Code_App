import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class SmartContract extends StatefulWidget {
  const SmartContract({Key? key}) : super(key: key);

  @override
  _SmartContractPageState createState() => _SmartContractPageState();
}

class _SmartContractPageState extends State<SmartContract> {
  late Client httpClient;
  late Web3Client ethClient;
  
  @override
  void initState() {
    super.initState(); 
    httpClient = Client();
    ethClient = Web3Client("http://localhost:8545", httpClient);
  }

  // TODO: Create the Smart Contract & load it into this application

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
