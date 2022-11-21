import 'package:ceg4912_project/BlockchainTestPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ReceiptSystem(),
        child: MaterialApp(title: 'asdfsdf', home: ReceiptSystem()));
  }
}
