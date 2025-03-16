import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:flutter/material.dart';

class DashboardBox extends StatelessWidget {
  final Function onTap;
  final String text;

  const DashboardBox({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: CenteredContainer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
          ],
        ),
      ),
    );
  }
}
