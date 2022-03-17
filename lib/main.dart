import 'package:flutter/material.dart';
import 'generate_qr.dart';
import 'scan_qr.dart';

void main() {
  runApp(const HomePageRoute());
}

// serves as a wrapper class for rendering the actual home page
class HomePageRoute extends StatelessWidget {
  const HomePageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void goToGenerateQR() {}

  void goToScanQR() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GenerateQR(),
                  ),
                );
              },
              child: const Text("Generate QR Code"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScanQR(),
                  ),
                );
              },
              child: const Text("Scan QR Code"),
            ),
          ],
        ),
      ),
    );
  }
}
