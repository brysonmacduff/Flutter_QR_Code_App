import 'package:flutter/material.dart';
import 'package:ceg4912_project/login.dart';
import 'package:provider/provider.dart';

import 'BlockchainTestPage.dart';
import 'Models/ReceiptSystemModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReceiptSystemModel(),
      child: MaterialApp(
        title: 'Flutter TODO',
        home: ReceiptSystem(),
      ),
    );
  }
}
