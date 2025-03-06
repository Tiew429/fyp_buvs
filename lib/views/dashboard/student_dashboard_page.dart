import 'package:blockchain_university_voting_system/data/dashboard_content.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {

  const StudentDashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: ScrollableResponsiveWidget(
        hasBottomNavigationBar: true,
        phone: Column(
          children: [
            const CenteredContainer(
              child: Text('Upcoming Voting Event'),
            ),
            const SizedBox(height: 16),
            const CenteredContainer(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search),
                  Text('Search module'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...StudentDashboardContent.values.map((content) {
              void Function()? navigation;
              IconData icon;
              switch (content) {
                case StudentDashboardContent.votingEvent:
                  navigation = () => NavigationHelper.navigateToVotingListPage(context);
                  icon = Icons.how_to_vote;
                  break;
                case StudentDashboardContent.notifications:
                  navigation = () => NavigationHelper.navigateToNotificationsPage(context);
                  icon = Icons.notifications;
                  break;
              }

              return Column(
                children: [
                  CenteredContainer(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: navigation,
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            content.studentDashboardContent.toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
        tablet: Container(),
      ),
    );
  }
}
