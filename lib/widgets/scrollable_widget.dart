import 'package:flutter/material.dart';

class ScrollableWidget extends StatelessWidget {
  final Widget child;
  final bool hasBottomNavigationBar;

  const ScrollableWidget({
    super.key,
    required this.child,
    this.hasBottomNavigationBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: hasBottomNavigationBar? 
            (MediaQuery.of(context).size.height - kBottomNavigationBarHeight - 30) 
            : MediaQuery.of(context).size.height - 60, // ensures minimum height matches screen size
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
        // child: IntrinsicHeight( // makes column height dynamic based on content
        //   child: child,
        // ),
      ),
    );
  }
}
