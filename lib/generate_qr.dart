import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQR extends StatefulWidget {
  const GenerateQR({Key? key}) : super(key: key);

  @override
  State<GenerateQR> createState() => _GenerateQRState();
}

class _GenerateQRState extends State<GenerateQR> {
  String qrData = "";
  String tfValue = "No message"; // stores the input field's string

  // gets the qr data input string on button press
  void getInputText() {
    setState(() {
      qrData = tfValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate QR Code"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'QR Data Input'),
              onChanged: (value) => tfValue = value,
            ),
            TextButton(
              onPressed: getInputText,
              child: const Text("Submit"),
            ),
            QrImage(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ],
        ),
      ),
    );
  }
}
