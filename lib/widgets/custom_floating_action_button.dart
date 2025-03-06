import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final Color? backgroundColor;
  final Color? fontColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomFloatingActionButton({
    super.key,
    required this.onTap,
    required this.text,
    this.backgroundColor,
    this.fontColor,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  });

  @override
  State<CustomFloatingActionButton> createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.onPrimary),
            borderRadius: BorderRadius.circular(widget.borderRadius?? 12.0),
            color: widget.backgroundColor ?? colorScheme.primary,
          ),
          padding: widget.padding,
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
