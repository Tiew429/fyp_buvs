import 'package:flutter/material.dart';

class ProgressCircular extends StatelessWidget {
  final bool isLoading;
  final Color? backgroundColor;
  final Color? progressColor;
  final double size;
  final double strokeWidth;
  final String? message;
  final TextStyle? messageStyle;
  final double opacity;

  const ProgressCircular({
    super.key,
    this.isLoading = true,
    this.backgroundColor,
    this.progressColor,
    this.size = 50.0,
    this.strokeWidth = 4.0,
    this.message,
    this.messageStyle,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!isLoading) return const SizedBox.shrink();

    return Visibility(
      visible: isLoading,
      // first container to avoid user press background features
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: backgroundColor?.withOpacity(opacity) ?? colorScheme.onPrimary.withOpacity(opacity),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: backgroundColor?.withOpacity(opacity) ?? colorScheme.inversePrimary.withOpacity(opacity),
            ),
            // both width and height are the half length of the screen's shortest side
            width: MediaQuery.of(context).size.shortestSide / 2,
            height: MediaQuery.of(context).size.shortestSide / 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor ?? colorScheme.onPrimary),
                    strokeWidth: strokeWidth,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: messageStyle ?? 
                      TextStyle(color: progressColor, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// shows a loading overlay on the entire screen
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressCircular(
          message: message,
        );
      },
    );
  }

  /// hides the loading overlay
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// shows a loading overlay with a stack
  static Widget wrapWithLoading({
    required Widget child,
    required bool isLoading,
    String? message,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          ProgressCircular(
            isLoading: isLoading,
            message: message,
          ),
      ],
    );
  }
}
