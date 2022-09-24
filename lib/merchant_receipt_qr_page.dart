import 'package:ceg4912_project/Support/utility.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:zoom_widget/zoom_widget.dart';

class MerchantReceiptQRPage extends StatefulWidget {
  const MerchantReceiptQRPage({Key? key}) : super(key: key);

  @override
  State<MerchantReceiptQRPage> createState() => _MerchantReceiptQRPageState();
}

class _MerchantReceiptQRPageState extends State<MerchantReceiptQRPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt QR Code"),
        backgroundColor: Utility.getBackGroundColor(),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Zoom(
          initTotalZoomOut: true,
          child: QrImage(
            padding: const EdgeInsets.all(8),
            data:
                (ModalRoute.of(context)!.settings.arguments! as Map)["qrData"],
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      ),
    );
  }
}
