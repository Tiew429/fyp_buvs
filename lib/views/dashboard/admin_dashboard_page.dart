import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/widgets/custom_search_box.dart';
import 'package:blockchain_university_voting_system/widgets/dashboard_box.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  
  // define dashboard items with their texts and navigation functions
  List<Map<String, dynamic>> _dashboardItems = [];
  List<Map<String, dynamic>> _filteredDashboardItems = [];
  bool _initialized = false;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeDashboardItems();
      _filteredDashboardItems = List.from(_dashboardItems);
      _initialized = true;
    }
  }
  
  void _initializeDashboardItems() {
    _dashboardItems = [
      {
        'text': AppLocale.votingEvent.getString(context),
        'icon': Icons.how_to_vote,
        'description': AppLocale.manageCandidate.getString(context),
        'onTap': () => NavigationHelper.navigateToVotingListPage(context),
        'searchTerms': {
          'en': ['voting event', 'elections', 'vote', 'ballot'],
          'ms': ['acara pengundian', 'pilihan raya', 'undi', 'undian'],
          'zh': ['投票活动', '选举', '投票', '表决']
        }
      },
      {
        'text': AppLocale.pendingVotingEvent.getString(context),
        'icon': Icons.pending_actions,
        'description': AppLocale.approve.getString(context),
        'onTap': () => NavigationHelper.navigateToPendingVotingEventListPage(context),
        'searchTerms': {
          'en': ['pending voting', 'upcoming elections', 'scheduled votes'],
          'ms': ['pengundian tertunda', 'pilihan raya akan datang', 'undi berjadual'],
          'zh': ['待定投票', '即将举行的选举', '计划投票']
        }
      },
      {
        'text': AppLocale.userManagement.getString(context),
        'icon': Icons.people_alt,
        'description': AppLocale.verifyUserInformation.getString(context),
        'onTap': () => NavigationHelper.navigateToUserManagementPage(context),
        'searchTerms': {
          'en': ['user management', 'manage users', 'accounts', 'students'],
          'ms': ['pengurusan pengguna', 'urus pengguna', 'akaun', 'pelajar'],
          'zh': ['用户管理', '管理用户', '账户', '学生']
        }
      },
      {
        'text': AppLocale.notifications.getString(context),
        'icon': Icons.notifications_active,
        'description': AppLocale.sendNotification.getString(context),
        'onTap': () => NavigationHelper.navigateToNotificationsPage(context),
        'searchTerms': {
          'en': ['notifications', 'alerts', 'messages'],
          'ms': ['pemberitahuan', 'makluman', 'pesanan'],
          'zh': ['通知', '提醒', '消息']
        }
      },
      {
        'text': AppLocale.report.getString(context),
        'icon': Icons.assessment,
        'description': AppLocale.statistics.getString(context),
        'onTap': () => NavigationHelper.navigateToReportPage(context),
        'searchTerms': {
          'en': ['report', 'analytics', 'statistics', 'results'],
          'ms': ['laporan', 'analitik', 'statistik', 'keputusan'],
          'zh': ['报告', '分析', '统计', '结果']
        }
      },
    ];
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase().trim();
      
      if (_searchQuery.isEmpty) {
        _filteredDashboardItems = List.from(_dashboardItems);
      } else {
        _filteredDashboardItems = _dashboardItems.where((item) {
          // check if search query matches the display text
          if (item['text'].toLowerCase().contains(_searchQuery)) {
            return true;
          }
          
          // check if search query matches any search term in any language
          Map<String, List<String>> searchTerms = item['searchTerms'];
          
          for (var language in searchTerms.keys) {
            for (var term in searchTerms[language]!) {
              if (term.toLowerCase().contains(_searchQuery)) {
                return true;
              }
            }
          }
          
          return false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: ScrollableResponsiveWidget(
        hasBottomNavigationBar: true,
        phone: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomSearchBox(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: AppLocale.searcModule.getString(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // message when no results found
            if (_searchQuery.isNotEmpty && _filteredDashboardItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocale.noMatchingOptionsFound.getString(context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: _filteredDashboardItems.map((item) => DashboardBox(
                    onTap: item['onTap'],
                    text: item['text'],
                    icon: item['icon'],
                    description: item['description'],
                  )).toList(),
                ),
              ),
          ],
        ), 
        tablet: Container(),
      ),
    );
  }
}
