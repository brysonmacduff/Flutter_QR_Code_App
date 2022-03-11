import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRInput(),
    );
  }
}

/*
// This widget is the root of your application.
class QRApp extends StatelessWidget {
  const QRApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const QRPage(),
    );
  }
}

class QRPage extends StatelessWidget {
  const QRPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: Center(
        child: QrImage(
          data: "hello there",
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
*/
class QRInput extends StatefulWidget {
  const QRInput({Key? key}) : super(key: key);

  @override
  State<QRInput> createState() => _QRInputState();
}

class _QRInputState extends State<QRInput> {
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
        title: const Text("QR Code App"),
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
