import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/widgets/custom_search_box.dart';
import 'package:blockchain_university_voting_system/widgets/empty_state_widget.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:blockchain_university_voting_system/widgets/voting_event_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class VotingListPage extends StatefulWidget {
  final UserProvider userProvider;
  final VotingEventProvider votingEventProvider;
  final WalletProvider walletProvider;

  const VotingListPage({
    super.key, 
    required this.userProvider,
    required this.votingEventProvider,
    required this.walletProvider,
  });


  @override
  State<VotingListPage> createState() => _VotingListPageState();
}

class _VotingListPageState extends State<VotingListPage> {
  bool _isLoading = false;
  late List<VotingEvent> _votingEventList = [];
  late TextEditingController _searchController;
  List<VotingEvent> _filteredVotingEventList = [];
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _votingEventList = [];
    _filteredVotingEventList = [];
    
    // set up a listener to update when the provider changes
    widget.votingEventProvider.addListener(_updateEventList);
    
    // delay loading data until build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadVotingEvents();
        _isFirstLoad = false;
      }
    });
  }
  
  @override
  void dispose() {
    widget.votingEventProvider.removeListener(_updateEventList);
    _searchController.dispose();
    super.dispose();
  }
  
  // update the local event list when the provider's data changes
  void _updateEventList() {
    if (!mounted) return;
    
    // 获取所有非弃用事件
    List<VotingEvent> events = widget.votingEventProvider.votingEventList
        .where((event) => event.status.name != 'deprecated')
        .toList();
    
    setState(() {
      _votingEventList = events;
      if (events.isNotEmpty) {
        _sortVotingEvents(_votingEventList);
        _applySearchFilter();
      } else {
        _filteredVotingEventList = [];
      }
    });
  }

  Future<void> _loadVotingEvents() async {
    print("Loading voting events, current state: $_isLoading");
    if (widget.votingEventProvider.votingEventList.isEmpty) {
      setState(() => _isLoading = true);
    }
    print("Set loading state to: $_isLoading");
    
    try {
      await widget.votingEventProvider.loadVotingEvents();
      print("Voting events loaded from provider");
    } catch (e) {
      print("Error loading voting events: $e");
    } finally {
      _updateEventList();
      setState(() => _isLoading = false);
    }
  }

  // apply search filter based on current search query
  void _applySearchFilter() {
    String searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      _filteredVotingEventList = _votingEventList;
      return;
    }

    _filteredVotingEventList = _votingEventList
        .where((event) => 
          event.title.toLowerCase().contains(searchText) ||
          event.description.toLowerCase().contains(searchText) ||
          event.votingEventID.toLowerCase().contains(searchText)
        )
        .toList();
    // sort the filtered results
    _sortVotingEvents(_filteredVotingEventList);
  }

  // sort events by status: 1. ongoing, 2. waiting to start, 3. ended
  void _sortVotingEvents(List<VotingEvent> events) {
    events.sort((a, b) {
      String statusA = _getEventStatus(a);
      String statusB = _getEventStatus(b);
      
      // priority order: ongoing > waiting > ended
      final statusPriority = {
        AppLocale.ongoing.getString(context): 0,
        AppLocale.waitingToStart.getString(context): 1,
        AppLocale.ended.getString(context): 2,
      };
      
      return statusPriority[statusA]!.compareTo(statusPriority[statusB]!);
    });
  }
  
  // determine event status for sorting
  String _getEventStatus(VotingEvent event) {
    // 使用马来西亚时区 (UTC+8)
    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 8));
    
    // 创建完整的开始和结束DateTime
    DateTime startDateTime = DateTime(
      event.startDate!.year,
      event.startDate!.month,
      event.startDate!.day,
      event.startTime!.hour,
      event.startTime!.minute,
    );
    
    DateTime endDateTime = DateTime(
      event.endDate!.year,
      event.endDate!.month,
      event.endDate!.day,
      event.endTime!.hour,
      event.endTime!.minute,
    );
    
    // 活动未开始
    if (now.isBefore(startDateTime)) {
      return AppLocale.waitingToStart.getString(context);
    }
    
    // 活动已结束
    if (now.isAfter(endDateTime)) {
      return AppLocale.ended.getString(context);
    }
    
    // 活动进行中
    return AppLocale.ongoing.getString(context);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // refresh data every time the page is shown/navigated to, but avoid double-loading during initialization
    if (!_isFirstLoad) {
      _loadVotingEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    print("Building UI, isLoading: $_isLoading");

    // 钱包未连接的UI
    if (widget.walletProvider.walletAddress == null || 
        widget.walletProvider.walletAddress!.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(colorScheme),
        backgroundColor: colorScheme.tertiary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: colorScheme.onTertiary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocale.pleaseConnectYourWallet.getString(context),
                style: TextStyle(
                  color: colorScheme.onTertiary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 主UI（包含加载状态和内容）
    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      backgroundColor: colorScheme.tertiary,
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocale.loading.getString(context),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadVotingEvents,
            child: Column(
              children: [
                _buildSearchBox(),
                Expanded(
                  child: _filteredVotingEventList.isEmpty
                    ? EmptyStateWidget(
                        message: AppLocale.noVotingEventAvailable.getString(context),
                        icon: Icons.how_to_vote,
                      )
                    : _buildEventsList(),
                ),
              ],
            ),
          ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  // 创建AppBar
  AppBar _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      title: Text(AppLocale.votingList.getString(context)),
      centerTitle: true,
      backgroundColor: colorScheme.secondary,
      actions: [
        if (widget.userProvider.user!.role == UserRole.admin || widget.userProvider.user!.role == UserRole.staff)
          IconButton(
            icon: const Icon(Icons.pending_actions),
            tooltip: AppLocale.pendingVotingEvent.getString(context),
            onPressed: () => NavigationHelper.navigateToPendingVotingEventListPage(context),
          ),
      ],
    );
  }

  // 创建搜索框
  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CustomSearchBox(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _applySearchFilter();
          });
        },
        hintText: AppLocale.searchVotingEventTitle.getString(context)
      ),
    );
  }

  // 创建事件列表
  Widget _buildEventsList() {
    return ScrollableResponsiveWidget(
      phone: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            ..._filteredVotingEventList.map((votingEvent) => VotingEventBox(
              onTap: () {
                widget.votingEventProvider.selectVotingEvent(votingEvent);
                NavigationHelper.navigateToVotingEventPage(context);
              },
              votingEvent: votingEvent,
            )),
          ],
        ),
      ),
      tablet: Container(),
    );
  }

  // 创建浮动按钮
  Widget? _buildFloatingActionButton(ColorScheme colorScheme) {
    if ((widget.userProvider.user!.role == UserRole.admin ||
        widget.userProvider.user!.role == UserRole.staff) &&
        (widget.walletProvider.walletAddress != null &&
        widget.walletProvider.walletAddress!.isNotEmpty)) {
      return FloatingActionButton.extended(
        onPressed: () async {
          // navigate to create page and wait for result
          final result = await NavigationHelper.navigateToVotingEventCreatePage(context);
          
          // refresh the list if we got a true result (new event created)
          if (result == true) {
            await _loadVotingEvents();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocale.createNew.getString(context)),
        backgroundColor: colorScheme.primary,
      );
    }
    return null;
  }
}
