import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:mobile_scanner/mobile_scanner.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/ui/widgets/round_outlined_button.dart";

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key, required Color iconBackGroundColor}) : _iconBackGroundColor = iconBackGroundColor;

  final Color _iconBackGroundColor;

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
    super.initState();
    
    _mobileScannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Stack(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(width: 15),
                  RoundOutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: widget._iconBackGroundColor,
                    child: Icon(Icons.arrow_back, size: 36, color: colorScheme.primary),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  SizedBox(width: 15),
                  RoundOutlinedButton(
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ["jpg", "jpeg", "png"]);

                      if (result != null) {
                        BarcodeCapture? barcodeCapture = await _mobileScannerController.analyzeImage(result.files.single.path!);
                        if (barcodeCapture != null) {
                          Navigator.pop(AppGlobal.navigatorKey.currentContext!, barcodeCapture.barcodes.first.rawValue);
                        }
                      }
                    },
                    backgroundColor: widget._iconBackGroundColor,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.folder, size: 38, color: colorScheme.primary),
                    ),
                  ),
                  Spacer(),
                  RoundOutlinedButton(
                    onPressed: () {
                      _mobileScannerController.toggleTorch();

                      setState(() {
                        _flashOn = !_flashOn;
                      });
                    },
                    backgroundColor: widget._iconBackGroundColor,
                    child: Padding(
                      padding: EdgeInsets.all(5.0),
                      child: _flashOn
                          ? Icon(Icons.flash_off, size: 38, color: colorScheme.primary)
                          : Icon(Icons.flash_on, size: 38, color: colorScheme.primary),
                    ),
                  ),
                  SizedBox(width: 15),
                ],
              ),
              SizedBox(height: 15),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mobileScannerController.dispose();
    
    super.dispose();
  }
}
