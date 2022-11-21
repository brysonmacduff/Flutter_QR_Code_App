import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import './receipt.dart';

class ReceiptSystemModel extends ChangeNotifier {
  List<Receipt> Receipts = [];
  bool isLoading = true;
  int receiptCount = 0;

  final String _rpcUrl = "HTTP://127.0.0.1:7545";
  final String _wsUrl = "ws://127.0.0.1:7545/";

  final String _privatekey =
      "dd29ffd251ac57639cbdef7554eaef7456261176193d84e1e804c5a4aba3a2b6"; //Should not be stored in plainText!!!!!

  late Web3Client _web3client;
  late String _abiCode;

  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late EthereumAddress _ownAddress;
  late DeployedContract _contract;

  late ContractFunction _receiptCount;
  late ContractFunction _receipts;
  late ContractFunction _insertReceipt;
  late ContractFunction _getReceipt;
  late ContractFunction _getReceiptCount;

  ReceiptSystemModel() {
    init();
  }

  Future<void> init() async {
    _web3client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
  }

  Future<void> getAbi() async {
    String abiStringFile = await rootBundle
        .loadString("./smartcontract/build/contracts/ReceiptSystem.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
    await getCredentials();
  }

  Future<void> getCredentials() async {
    _credentials = await EthPrivateKey.fromHex(_privatekey);
    _ownAddress = await _credentials.extractAddress();
    await getDeployedContract();
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "ReceiptSystem"), _contractAddress);
    _receiptCount = _contract.function("ReceiptCount");
    // _receipts = _contract.function("Receipts");
    _insertReceipt = _contract.function("insertReceipt");
    _getReceipt = _contract.function("getReceipt");
    _getReceiptCount = _contract.function("getReceiptCount");
    // await getReceipts();
  }

  getReceipts() async {
    List totalReceiptList = await _web3client
        .call(contract: _contract, function: _receiptCount, params: []);
    BigInt totalReceipt = totalReceiptList[0];
    receiptCount = totalReceipt.toInt();
    Receipts.clear();
    for (var i = 0; i < receiptCount; i++) {
      var temp = await _web3client.call(
          contract: _contract, function: _receipts, params: [BigInt.from(i)]);
      if (temp[1] != "") {
        Receipts.add(
            Receipt.BCParams(temp[0], temp[1], temp[2], temp[3], temp[4]));
      }
    }
    isLoading = false;
    notifyListeners();
  }

  void insertReceipt(
      int Rid, String DateTime, double cost, int Mid, int Cid) async {
    isLoading = true;
    notifyListeners();
    int nCost = (cost * 100).toInt();
    await _web3client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: _insertReceipt,
            parameters: [Rid, DateTime, cost, Mid, Cid]));
    await getReceipts();
  }
}
