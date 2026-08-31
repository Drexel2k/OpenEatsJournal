import "package:flutter/material.dart";
import "package:flutter_zxing/flutter_zxing.dart";
import "package:image_picker/image_picker.dart";
import "package:openeatsjournal/app_global.dart";
import "package:openeatsjournal/l10n/app_localizations.dart";
import "package:openeatsjournal/ui/utils/overlay_display.dart";
import "package:openeatsjournal/ui/utils/overlay_info.dart";
import "package:provider/provider.dart";

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key, String? scanResult});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _barcodeReturned = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        ReaderWidget(
          showToggleCamera: false,
          showGallery: false,
          cropPercent: 0.9,
          actionButtonsBackgroundColor: colorScheme.surface,
          flashOnIcon: Icon(Icons.flash_on, color: colorScheme.primary),
          flashOffIcon: Icon(Icons.flash_off, color: colorScheme.primary),

          onScan: (result) {
            if (result.isValid && !_barcodeReturned) {
              _barcodeReturned = true;
              Navigator.pop(context, result.text);
            }
          },
        ),

        Positioned(
          bottom: 34,
          right: 9,
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);

                if (file != null) {
                  final Code result = await zx.readBarcodeImagePath(file, DecodeParams(format: Format.any, tryHarder: true, tryInverted: true));

                  if (result.isValid && !_barcodeReturned) {
                    _barcodeReturned = true;
                    Navigator.pop(AppGlobal.navigatorKey.currentContext!, result.text);
                    return;
                  }

                  final OverlayDisplay overlayDisplay = Provider.of<OverlayDisplay>(AppGlobal.navigatorKey.currentContext!, listen: false);

                  overlayDisplay.enqueue(
                    overlayInfo: OverlayInfo(message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.no_barcode_found_on_picture, spacer: 170),
                  );
                }
              },
              child: SizedBox(width: 48, height: 48, child: Icon(Icons.photo_library, color: colorScheme.primary, size: 26)),
            ),
          ),
        ),
      ],
    );
  }
}
