import 'package:flutter/material.dart';

class RoundOutlinedButton extends StatelessWidget {
  const RoundOutlinedButton({super.key, VoidCallback? onPressed, required Widget child})
    : _onPressed = onPressed,
      _child = child;

  final VoidCallback? _onPressed;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _onPressed,
      style: OutlinedButton.styleFrom(
        shape: CircleBorder(),
        minimumSize: Size(40, 40),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: _child,
    );
  }
}
