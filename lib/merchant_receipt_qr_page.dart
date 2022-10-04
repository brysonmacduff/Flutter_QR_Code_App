import 'package:ceg4912_project/Support/utility.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:zoom_widget/zoom_widget.dart';

class MerchantReceiptQRPage extends StatefulWidget {
  const MerchantReceiptQRPage({Key? key}) : super(key: key);

  @override
  State<MerchantReceiptQRPage> createState() => _MerchantReceiptQRPageState();
}

class _MerchantReceiptQRPageState extends State<MerchantReceiptQRPage> {
  @override
  Widget build(BuildContext context) {
    String qrData =
        (ModalRoute.of(context)!.settings.arguments! as Map)["qrData"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt QR Code"),
        backgroundColor: Utility.getBackGroundColor(),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Zoom(
          initTotalZoomOut: true,
          child: BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: qrData,
            width: MediaQuery.of(context).size.width / 1.125,
            height: MediaQuery.of(context).size.width / 1.125,
          ),
        ),
      ),
    );
  }
}
