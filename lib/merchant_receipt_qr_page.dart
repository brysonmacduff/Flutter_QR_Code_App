import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/utility.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:mysql1/mysql1.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'dart:convert';

class MerchantReceiptQRPage extends StatefulWidget {
  const MerchantReceiptQRPage({Key? key}) : super(key: key);
  static bool allowQueries = false;

  @override
  State<MerchantReceiptQRPage> createState() => _MerchantReceiptQRPageState();
}

class _MerchantReceiptQRPageState extends State<MerchantReceiptQRPage> {
  var conn;
  int receiptId = -100;
  int checkCount = 0;

  void initState() {
    super.initState();
    getConnection();
    MerchantReceiptQRPage.allowQueries = true;
    Future.delayed(const Duration(seconds: 5), isPaymentComplete);
  }

  // this function will periodically check the database to see if the QR code receipt was scanned and payment was provided
  dynamic isPaymentComplete() async {
    // if the page has been popped then queries won't be allowed from pending future calls of this function
    if (MerchantReceiptQRPage.allowQueries == false) {
      return;
    }

    try {
      var result = await Queries.isPaymentComplete(conn, receiptId);
      print("merchant_receipt_qr_page: attemping to verify payment: result: " +
          result.toString() +
          ". Check count: " +
          checkCount.toString());
      // if payment is complete, tell the merchant and exit
      if (result == true) {
        Utility.displayAlertMessage(context, "Payment Complete!", "");
        MerchantReceiptQRPage.allowQueries = false;
        return;
      }
    } catch (e) {
      print("merchant_receipt_qr_page: " + e.toString());
      Utility.displayAlertMessage(
          context, "Connection Error", "Failed to verify payment.");
    }

    ++checkCount;

    // try again soon to verify payment
    Future.delayed(const Duration(seconds: 5), isPaymentComplete);
  }

  void getConnection() async {
    conn = await Queries.getConnection();
  }

  @override
  Widget build(BuildContext context) {
    String qrData =
        (ModalRoute.of(context)!.settings.arguments! as Map)["qrData"];
    Map extractID = jsonDecode(qrData);
    receiptId = int.parse(extractID["receiptId"]);
    print("receipt id: " + receiptId.toString());

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
