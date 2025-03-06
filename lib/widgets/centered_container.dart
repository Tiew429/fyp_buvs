import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:flutter/material.dart';

class CenteredContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsets padding;
  final bool canNavigateBack;
  final double containerPaddingHorizontal;
  final double containerPaddingVertical;

  const CenteredContainer({
    super.key,
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(32),
    this.canNavigateBack = false,
    this.containerPaddingHorizontal = 0.0,
    this.containerPaddingVertical = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: containerPaddingHorizontal, vertical: containerPaddingVertical),
                child: Container(
                  width: width ?? double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    border: Border.all(
                      color: colorScheme.onPrimary,
                      width: Theme.of(context).brightness == Brightness.dark ? 3.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        child: Padding(
                          padding: padding, 
                          child: child,
                        ),
                      ),
                      if (canNavigateBack)
                      Positioned(
                        top: 2,
                        left: 2,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () async {
                              NavigationHelper.navigateBack(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
