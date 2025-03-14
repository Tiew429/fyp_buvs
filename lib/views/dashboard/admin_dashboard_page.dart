import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/dashboard_box.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({
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
            DashboardBox(
              onTap: () => NavigationHelper.navigateToVotingListPage(context), 
              text: AppLocale.votingEvent.getString(context),
            ),
            const SizedBox(height: 16,),
            DashboardBox(
              onTap: () => NavigationHelper.navigateToPendingVotingEventListPage(context), 
              text: AppLocale.pendingVotingEvent.getString(context),
            ),
            const SizedBox(height: 16,),
            DashboardBox(
              onTap: () => NavigationHelper.navigateToNotificationsPage(context),
              text: "Notifications",
            ),
            const SizedBox(height: 16,),
            DashboardBox(
              onTap: () => NavigationHelper.navigateToReportPage(context),
              text: "Report",
            ),
            const SizedBox(height: 16,),
            DashboardBox(
              onTap: () => NavigationHelper.navigateToAuditListPage(context),
              text: "Audit",
            ),
          ],
        ), 
        tablet: Container(),
      ),
    );
  }
}
