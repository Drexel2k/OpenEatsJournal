import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:openeatsjournal/app_global.dart';
import 'package:openeatsjournal/ui/utils/overlay_info.dart';

class OverlayDisplay {
  OverlayDisplay({
    required AnimationController animationController,
    required Color backgroundColor,
    required Color shadowColorBase,
    required TextStyle textStyle,
  }) : _animationController = animationController,
       _backgroundColor = backgroundColor,
       _shadowColorBase = shadowColorBase,
       _textStyle = textStyle,
       _messageQueue = Queue<OverlayInfo>();

  final AnimationController _animationController;
  late Color _backgroundColor;
  late Color _shadowColorBase;
  late TextStyle _textStyle;
  final Queue<OverlayInfo> _messageQueue;
  OverlayEntry? _currentOverlayEntry;

  void updateStyle({required Color backgroundColor, required Color shadowColorBase, required TextStyle textStyle}) {
    _backgroundColor = backgroundColor;
    _shadowColorBase = shadowColorBase;
    _textStyle = textStyle;
  }

  void enqueue({required OverlayInfo overlayInfo}) {
    _messageQueue.add(overlayInfo);
    _display();
  }

  void _display() {
    if (_currentOverlayEntry == null) {
      OverlayInfo overlayInfo = _messageQueue.removeFirst();

      _currentOverlayEntry = OverlayEntry(
        builder: (context) => FadeTransition(
          opacity: _animationController,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: overlayInfo.spacer),
                Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: Container(
                    alignment: AlignmentGeometry.center,
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Color.from(red: _shadowColorBase.r, green: _shadowColorBase.g, blue: _shadowColorBase.r, alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: Offset(0, 7),
                        ),
                        BoxShadow(
                          color: Color.from(red: _shadowColorBase.r, green: _shadowColorBase.g, blue: _shadowColorBase.r, alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(overlayInfo.message, style: _textStyle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      Overlay.of(AppGlobal.navigatorKey.currentContext!).insert(_currentOverlayEntry!);

      _animationController.forward();
      Timer(Duration(milliseconds: 3150), () {
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
