import 'package:flutter/material.dart';

class CustomConfirmButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Function(bool)? onLongPress;
  final Color? backgroundColor;
  final Color? fontColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomConfirmButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.onLongPress,
    this.backgroundColor,
    this.fontColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 6.0,
    ),
  });

  @override
  State<CustomConfirmButton> createState() => _CustomConfirmButtonState();
}

class _CustomConfirmButtonState extends State<CustomConfirmButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onPressed, // Regular tap
      onLongPress: () {
        setState(() {
          isPressed = true;
        });

        if (widget.onLongPress != null) {
          widget.onLongPress!(false); // Trigger the onLongPress callback
        }
      },
      onLongPressUp: () {
        setState(() {
          isPressed = false; // Reset state when long press is released
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isPressed
              ? (widget.backgroundColor ?? 
                colorScheme.tertiary).withOpacity(1.0) // Change background on long press
              : widget.backgroundColor ??
                colorScheme.primary,
          // border: Border.all(color: colorScheme.onPrimary),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        ),
        padding: widget.padding,
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 16.0,
            color: widget.fontColor ?? colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
