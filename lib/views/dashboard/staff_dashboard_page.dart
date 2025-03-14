import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';

class StaffDashboard extends StatelessWidget {

  const StaffDashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: ScrollableResponsiveWidget(
        hasBottomNavigationBar: true,
        phone: const Text('Nothing here'),
        tablet: Container(),
      ),
    );
  }
}
