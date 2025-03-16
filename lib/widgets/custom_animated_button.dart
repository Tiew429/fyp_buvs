import 'package:flutter/material.dart';

class CustomAnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Function(bool)? onLongPress;
  final Color? backgroundColor;
  final Color? fontColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const CustomAnimatedButton({
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
    this.width,
  });

  @override
  State<CustomAnimatedButton> createState() => _CustomAnimatedButtonState();
}

class _CustomAnimatedButtonState extends State<CustomAnimatedButton> {
  double _rippleRadius = 0.0;
  double _darkenFactor = 0.0;
  bool _isPressed = false;

  void _animateButton() {
    setState(() {
      _isPressed = true;
      _rippleRadius = 100.0;
      _darkenFactor = 0.5;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onPressed?.call();
      setState(() {
        _isPressed = false;
        _rippleRadius = 0.0;
        _darkenFactor = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: _animateButton,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: widget.width ?? 200,
              height: 60,
              decoration: BoxDecoration(
                color: widget.backgroundColor?.withOpacity(1 - _darkenFactor) ?? colorScheme.secondary.withOpacity(1 - _darkenFactor),
                border: Border.all(
                  color: colorScheme.onPrimary,
                  width: Theme.of(context).brightness == Brightness.dark ? 3.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.text,
                style: TextStyle(
                  color: widget.fontColor ?? colorScheme.onPrimary, 
                  fontSize: 16.0, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
                child: _isPressed
                    ? TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: _rippleRadius),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, radius, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
                              color: Colors.white.withOpacity(0.2 * (1 - _darkenFactor)), // 波纹颜色变淡
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              )
            )
          ],
        ),
      ),
    );
  }
}
