import 'package:ceg4912_project/Support/utility.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/services.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:barcode/barcode.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MerchantLabelPrintPage extends StatefulWidget {
  const MerchantLabelPrintPage({Key? key}) : super(key: key);

  @override
  State<MerchantLabelPrintPage> createState() => _MerchantLabelPrintPageState();
}

class _MerchantLabelPrintPageState extends State<MerchantLabelPrintPage> {
  // stores the item for which a barcode label will be printed
  Item _item = Item.empty();

  void printLabel() async {
    // get application document directory
    Directory appDocDir = await getTemporaryDirectory();

    // create an svg barcode image
    final bc = Barcode.code128();
    final svg =
        bc.toSvg(_item.toLabelJSON(), width: 200, height: 200, fontHeight: 0);

    final doc = pw.Document();
    doc.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
          child:
              pw.SvgImage(svg: svg) //pw.Image.memory(imageBytes)//pw.Image(ip),
          );
    }));

    // initiate the print job
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

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
