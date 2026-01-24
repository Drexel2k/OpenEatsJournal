import "package:flutter/material.dart";

class RoundOutlinedButton extends StatelessWidget {
  const RoundOutlinedButton({super.key, VoidCallback? onPressed, required Widget child, Color? backgroundColor})
    : _onPressed = onPressed,
      _child = child,
      _backgroundColor = backgroundColor;

  final VoidCallback? _onPressed;
  final Widget _child;
  final Color? _backgroundColor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _onPressed,
      style: OutlinedButton.styleFrom(
        shape: CircleBorder(),
        minimumSize: Size(40, 40),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: _backgroundColor,
      ),
      child: _child,
    );
  }
}
