import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class MerchantReceiptScanPage extends StatefulWidget {
  const MerchantReceiptScanPage({Key? key}) : super(key: key);

  @override
  State<MerchantReceiptScanPage> createState() =>
      _MerchantReceiptScanPageState();
}

class _MerchantReceiptScanPageState extends State<MerchantReceiptScanPage> {
  // Start the scanning operation of a bar code.
  void startScan() async {
    final String result = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );
    // Pop this page from the stack and return the scan data.
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Label Page"),
      ),
      body: IconButton(
        icon: const Icon(Icons.camera_alt),
        onPressed: startScan,
      ),
    );
  }
}
