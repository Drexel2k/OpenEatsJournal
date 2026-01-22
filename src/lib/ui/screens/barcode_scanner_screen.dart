import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";
import "package:openeatsjournal/app_global.dart";

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  //onDetect triggers fast and may pop multiple times...
  bool _barcodeReturned = false;
  bool _flashOn = false;
  final MobileScannerController _mobileScannerController = MobileScannerController(autoStart: false);

  @override
  void initState() {
    _mobileScannerController.start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentGeometry.bottomCenter,
      children: [
        MobileScanner(
          controller: _mobileScannerController,
          onDetect: (result) {
            if (!_barcodeReturned) {
              setState(() {
                _barcodeReturned = true;
              });

              Navigator.pop(context, result.barcodes.first.rawValue);
            }
          },
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(width: 15),
                IconButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["jpg", "jpeg", "png"]);

                    if (result != null) {
                      BarcodeCapture? barcodeCapture = await _mobileScannerController.analyzeImage(result.files.single.path!);
                      if (barcodeCapture != null) {
                        Navigator.pop(AppGlobal.navigatorKey.currentContext!, barcodeCapture.barcodes.first.rawValue);
                      }
                    }
                  },
                  icon: Icon(Icons.folder, size: 48),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    _mobileScannerController.toggleTorch();

                    setState(() {
                      _flashOn = !_flashOn;
                    });
                  },
                  icon: _flashOn ? Icon(Icons.flash_off, size: 48) : Icon(Icons.flash_on, size: 48),
                ),
                SizedBox(width: 15),
              ],
            ),
            SizedBox(height: 15),
          ],
        ),
      ],
    );
  }
}
