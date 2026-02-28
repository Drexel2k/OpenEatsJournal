import 'dart:async';

import 'package:flutter/material.dart';
import 'package:openeatsjournal/app_global.dart';

//todo: this solution needs to be optimized with a central message queue, so that all messages are displayed one after another and display of message doesn't
//need to be cancelled when navigating to another screen.
class OverlayDisplay {
  late OverlayEntry _overlayEntry;
  late Timer _showTimer;
  Timer? _removeTimer;

  OverlayDisplay({required BuildContext context, required String displayText, required AnimationController animationController}) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    _overlayEntry = OverlayEntry(
      builder: (context) => FadeTransition(
        opacity: animationController,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(),
              Container(
                alignment: AlignmentGeometry.center,
                color: colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: EdgeInsetsGeometry.all(10),
                  child: Text(displayText, style: textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    AppGlobal.navigatorKey.currentState!.overlay!.insert(_overlayEntry);
    animationController.forward();
    _showTimer = Timer(Duration(milliseconds: 3150), () {
      animationController.reverse();
      _removeTimer = Timer(Duration(milliseconds: 150), () {
        _overlayEntry.remove();
      });
    });
  }

  void stop() {
    _showTimer.cancel();

    if (_removeTimer != null) {
      _removeTimer!.cancel();
    }

    _overlayEntry.remove();
  }
}
