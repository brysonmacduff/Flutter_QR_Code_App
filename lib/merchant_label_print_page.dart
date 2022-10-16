import 'package:ceg4912_project/Support/utility.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:zoom_widget/zoom_widget.dart';

class MerchantLabelPrintPage extends StatefulWidget {
  const MerchantLabelPrintPage({Key? key}) : super(key: key);

  @override
  State<MerchantLabelPrintPage> createState() => _MerchantLabelPrintPageState();
}

class _MerchantLabelPrintPageState extends State<MerchantLabelPrintPage> {
  // stores the item for which a barcode label will be printed
  Item _item = Item.empty();

  // TO DO - Add label printing
  void printLabel() {}

  @override
  Widget build(BuildContext context) {
    // receive the item argument from the merchant item page
    _item = (ModalRoute.of(context)!.settings.arguments! as Map)["item"];

    return Scaffold(
        appBar: AppBar(
          title: const Text("Print Item Label"),
          backgroundColor: Utility.getBackGroundColor(),
          actions: [
            IconButton(
              onPressed: printLabel,
              icon: Icon(
                Icons.print,
                color: Utility.getBackGroundColor(),
              ),
            ),
          ],
        ),
        body: Align(
          alignment: Alignment.center,
          child: Zoom(
            child: BarcodeWidget(
              data: _item.toLabelJSON(),
              barcode: Barcode.code128(),
              width: MediaQuery.of(context).size.width / 1.125,
              drawText: false,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: printLabel,
          child: const Icon(
            Icons.print,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
