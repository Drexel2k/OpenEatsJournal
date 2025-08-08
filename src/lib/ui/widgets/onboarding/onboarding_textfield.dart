import "package:flutter/material.dart";
import "package:flutter/services.dart";

class OnboardingTextField extends StatefulWidget {
  final GestureTapCallback? onTap;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const OnboardingTextField({ 
      super.key, 
      this.onTap, 
      this.controller, 
      this.keyboardType, 
      this.inputFormatters,
      this.onChanged,
      this.readOnly = false,
      }
    );

  @override
  State<OnboardingTextField> createState() => _OnboardingTextField();
}

class _OnboardingTextField extends State<OnboardingTextField> {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140.0,
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          isDense: true,
        ),
        readOnly: widget.readOnly,
        controller: widget.controller,
        onTap: widget.onTap,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged
      ),
    );
  }
}