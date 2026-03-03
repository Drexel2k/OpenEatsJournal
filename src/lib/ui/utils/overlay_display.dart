import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:openeatsjournal/app_global.dart';
import 'package:openeatsjournal/ui/utils/overlay_info.dart';

class OverlayDisplay {
  OverlayDisplay({required AnimationController animationController}) : _animationController = animationController, _messageQueue = Queue<OverlayInfo>();

  final AnimationController _animationController;
  final Queue _messageQueue;
  OverlayEntry? _currentOverlayEntry;

  void enqueue({required OverlayInfo overlayInfo}) {
    _messageQueue.add(overlayInfo);
    _display();
  }

  void _display() {
    if (_currentOverlayEntry == null) {
      OverlayInfo message = _messageQueue.removeFirst();

      _currentOverlayEntry = OverlayEntry(
        builder: (context) => FadeTransition(
          opacity: _animationController,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
                    alignment: AlignmentGeometry.center,
                    decoration: BoxDecoration(
                      color: message.backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.from(red: message.shadowColorBase.r, green: message.shadowColorBase.g, blue: message.shadowColorBase.r, alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: Offset(0, 7),
                        ),
                        BoxShadow(
                          color: Color.from(red: message.shadowColorBase.r, green: message.shadowColorBase.g, blue: message.shadowColorBase.r, alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(message.displayText, style: message.textStyle),
                    ),
                  ),
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      );

      Overlay.of(AppGlobal.navigatorKey.currentContext!).insert(_currentOverlayEntry!);

      _animationController.forward();
      Timer(Duration(milliseconds: 5150), () {
        _animationController.reverse();
        Timer(Duration(milliseconds: 150), () {
          _currentOverlayEntry!.remove();
          _currentOverlayEntry = null;

          if (_messageQueue.isNotEmpty) {
            _display();
          }
        });
      });
    }
  }
}
