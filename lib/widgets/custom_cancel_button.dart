import 'package:flutter/material.dart';

class CustomCancelButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Function(bool)? onLongPress;
  final Color? backgroundColor;
  final Color? fontColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomCancelButton({
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
  State<CustomCancelButton> createState() => _CustomCancelButtonState();
}

class _CustomCancelButtonState extends State<CustomCancelButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
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
              ? widget.backgroundColor ?? 
                Colors.red[900] // Dark red when pressed
              : widget.backgroundColor ??
                Colors.red, // Regular red when not pressed
          border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        ),
        padding: widget.padding,
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 16.0,
            color: widget.fontColor ?? Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
