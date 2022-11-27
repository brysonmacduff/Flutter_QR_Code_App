import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ceg4912_project/Models/ReceiptSystemModel.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

class ReceiptSystem extends StatefulWidget {
  ReceiptSystem({Key? key}) : super(key: key);

  @override
  _ReceiptSystemState createState() => _ReceiptSystemState();
}

class _ReceiptSystemState extends State<ReceiptSystem> {
  late Client _httpClient;
  late Web3Client _web3client;
  final myAddress = "0x701D1Bb8e71623D9d08118E918a0178372EfC65C";

  var myData;

  @override
  void initState() {
    super.initState();
    _httpClient = Client();
    _web3client =
        Web3Client("http://10.0.2.2:7545", _httpClient, socketConnector: () {
      return IOWebSocketChannel.connect("ws://10.0.2.2:7545/").cast<String>();
    });
  }

  @override
  Widget build(BuildContext context) {
    var listModel = Provider.of<ReceiptSystemModel>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text("Test Dapp"),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () =>
                insertReceipt(1, "I hate this fucking app", 12.20, 1, 1)));
  }

  Future<DeployedContract> loadContract() async {
    String abiStringFile = await rootBundle
        .loadString("./smartcontract/build/contracts/ReceiptSystem.json");
    String contractAddress = "0x4c9224B0Bb5feAB053E93699bd09a804f77DEd20";
    final Contract = DeployedContract(
        ContractAbi.fromJson(
            jsonEncode(jsonDecode(abiStringFile)["abi"]), "ReceiptSystem"),
        EthereumAddress.fromHex(contractAddress));
    return Contract;
  }

  Future<List<dynamic>> Query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await _web3client.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credential = EthPrivateKey.fromHex(
        "dd29ffd251ac57639cbdef7554eaef7456261176193d84e1e804c5a4aba3a2b6");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await _web3client.sendTransaction(
        credential,
        Transaction.callContract(
            contract: contract,
            function: ethFunction,
            parameters: args,
            maxGas: 6721975),
        chainId: 1377);
    return result;
  }

  Future<void> insertReceipt(
      int Rid, String DateTime, double cost, int Mid, int Cid) async {
    var result = await submit("insertReceipt", [
      BigInt.from(Rid),
      DateTime,
      BigInt.from((cost * 100).toInt()),
      BigInt.from(Mid),
      BigInt.from(Cid)
    ]);
    myData = result[0];
    setState(() {});
  }

  Future<int> getReceiptCount() async {
    List<dynamic> result = await Query("getReceiptCount", []);
    return result[0];
  }
}
