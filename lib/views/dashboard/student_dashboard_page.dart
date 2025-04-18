import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/provider/user_management_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/widgets/custom_search_box.dart';
import 'package:blockchain_university_voting_system/widgets/dashboard_box.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class StudentDashboard extends StatefulWidget {
  final UserProvider userProvider;
  final UserManagementProvider userManagementProvider;

  const StudentDashboard({
    super.key,
    required this.userProvider,
    required this.userManagementProvider,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
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
        'description': AppLocale.vote.getString(context),
        'onTap': () => NavigationHelper.navigateToVotingListPage(context),
        'searchTerms': {
          'en': ['voting event', 'elections', 'vote', 'ballot'],
          'ms': ['acara pengundian', 'pilihan raya', 'undi', 'undian'],
          'zh': ['投票活动', '选举', '投票', '表决']
        }
      },
      {
        'text': AppLocale.notifications.getString(context),
        'icon': Icons.notifications,
        'description': AppLocale.receivedNotifications.getString(context),
        'onTap': () => NavigationHelper.navigateToNotificationsPage(context),
        'searchTerms': {
          'en': ['notifications', 'alerts', 'messages', 'announcements'],
          'ms': ['pemberitahuan', 'makluman', 'pesanan', 'pengumuman'],
          'zh': ['通知', '提醒', '消息', '公告']
        }
      },
      {
        'text': AppLocale.profile.getString(context),
        'icon': Icons.person,
        'description': AppLocale.userInformation.getString(context),
        'onTap': () async {
          await widget.userManagementProvider.selectUser(widget.userProvider.user!.userID);
          NavigationHelper.navigateToProfilePageViewPage(context);
        },
        'searchTerms': {
          'en': ['profile', 'user info', 'account', 'personal'],
          'ms': ['profil', 'maklumat pengguna', 'akaun', 'peribadi'],
          'zh': ['个人资料', '用户信息', '账户', '个人']
        }
      },
      {
        'text': AppLocale.results.getString(context),
        'icon': Icons.bar_chart,
        'description': AppLocale.statistics.getString(context),
        'onTap': () => NavigationHelper.navigateToReportPage(context),
        'searchTerms': {
          'en': ['results', 'voting results', 'outcomes', 'winners'],
          'ms': ['keputusan', 'keputusan undi', 'hasil', 'pemenang'],
          'zh': ['结果', '投票结果', '成果', '获胜者']
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
