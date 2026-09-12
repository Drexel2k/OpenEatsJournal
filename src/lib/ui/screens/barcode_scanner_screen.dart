import "package:flutter/material.dart";
import "package:flutter_zxing/flutter_zxing.dart";
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

          onScanFailure: (result) {
            if (result.source != null && result.source == CodeSource.localImageFile) {
              final OverlayDisplay overlayDisplay = Provider.of<OverlayDisplay>(AppGlobal.navigatorKey.currentContext!, listen: false);

              overlayDisplay.enqueue(
                overlayInfo: OverlayInfo(message: AppLocalizations.of(AppGlobal.navigatorKey.currentContext!)!.no_barcode_found_on_picture, spacer: 170),
              );
            }
          },
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 28, left: 8),
            child: Container(
              decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12)),
              child: BackButton(
                color: colorScheme.primary,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
