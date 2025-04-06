import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';

class ResponseWidget extends StatelessWidget {
  final Widget phone;
  final Widget tablet;

  const ResponseWidget({
    super.key,
    required this.phone,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 800;

    return isTablet ? tablet : phone;
  }
}

class ScrollableResponsiveWidget extends StatelessWidget {
  final Widget phone;
  final Widget tablet;
  final bool hasBottomNavigationBar;

  const ScrollableResponsiveWidget ({
    super.key,
    required this.phone,
    required this.tablet,
    this.hasBottomNavigationBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollableWidget(
      hasBottomNavigationBar: hasBottomNavigationBar,
      child: ResponseWidget(
        phone: phone, 
        tablet: tablet,
      ),
    );
  }
}
