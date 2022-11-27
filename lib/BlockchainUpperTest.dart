//import 'package:ceg4912_project/BlockchainTestPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Models/ReceiptSystemModel.dart';

class ReceiptSystem extends StatelessWidget with ChangeNotifier {
  ReceiptSystem({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var listModel = Provider.of<ReceiptSystemModel>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text("Test Dapp"),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => listModel.insertReceipt(1, "datetime", 1, 34, 1)));
  }
}
