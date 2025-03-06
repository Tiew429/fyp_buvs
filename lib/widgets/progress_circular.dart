import 'package:flutter/material.dart';

class ProgressCircular extends StatelessWidget {
  final bool isLoading;
  final Color backgroundColor;
  final Color progressColor;
  final double size;
  final double strokeWidth;
  final String? message;
  final TextStyle? messageStyle;

  const ProgressCircular({
    super.key,
    this.isLoading = true,
    this.backgroundColor = Colors.black54,
    this.progressColor = Colors.white,
    this.size = 50.0,
    this.strokeWidth = 4.0,
    this.message,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
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
