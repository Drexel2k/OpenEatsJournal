import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (result) {
        Navigator.pop(context, result.barcodes.first.rawValue);
      },
    );
  }
}
