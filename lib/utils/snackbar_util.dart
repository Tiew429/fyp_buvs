import 'package:flutter/material.dart';

class SnackbarUtil {
  static void showSnackBar(BuildContext context, String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }
}
