import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  //onDetect triggers fast and may pop multiple times...
  bool _barcodeReturned = false;
  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (result) {
        if (!_barcodeReturned){
          setState(() {
            _barcodeReturned = true;
          });

          Navigator.pop(context, result.barcodes.first.rawValue);
        }
      },
    );
  }
}
