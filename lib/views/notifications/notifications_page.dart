import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/notification_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/notification_provider.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/services/firebase_service.dart';
import 'package:blockchain_university_voting_system/utils/date_format_util.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/widgets/empty_state_widget.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatefulWidget {
  final UserProvider userProvider;
  final NotificationProvider notificationProvider;

  const NotificationsPage({
    super.key, 
    required this.userProvider,
    required this.notificationProvider,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  late TextEditingController _searchController;
  String _searchQuery = '';
  String? _selectedType;
  
  final List<String> _allTypes = ['All', ...FirebaseService.getAvailableNotificationTypes()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    
    // Don't call _loadNotifications() directly in initState
    // Instead, schedule it for after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = widget.userProvider.user?.userID;
      if (userId != null) {
        await widget.notificationProvider.loadNotifications(userId);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error loading notifications: $e');
        SnackbarUtil.showSnackBar(context, 'Failed to load notifications: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final userId = widget.userProvider.user?.userID;
    if (userId != null) {
      bool success = await widget.notificationProvider.deleteNotification(
        notification.notificationID, 
        userId,
      );
      
      if (mounted) {
        if (success) {
          SnackbarUtil.showSnackBar(
            context, 
            AppLocale.notificationDeleted.getString(context),
          );
        } else {
          SnackbarUtil.showSnackBar(
            context, 
            AppLocale.failedToDeleteNotification.getString(context),
          );
        }
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    final userId = widget.userProvider.user?.userID;
    if (userId != null) {
      await widget.notificationProvider.markNotificationAsRead(
        notification.notificationID, 
        userId,
      );
    }
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
    if (_searchQuery.isEmpty && _selectedType == null || _selectedType == 'All') {
      return notifications;
    }
    
    return notifications.where((notification) {
      // Filter by search query
      bool matchesSearch = _searchQuery.isEmpty ||
          notification.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          notification.message.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filter by type/topic
      bool matchesType = _selectedType == null || 
                         _selectedType == 'All' || 
                         notification.type == _selectedType;
      
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        centerTitle: true,
        title: Text(AppLocale.notifications.getString(context)),
        actions: [
          if (widget.userProvider.user?.role == UserRole.admin ||
              widget.userProvider.user?.role == UserRole.staff)
            IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => NavigationHelper.navigateToSendNotificationPage(context),
          ),
        ],
        bottom: widget.userProvider.user?.role == UserRole.admin ||
              widget.userProvider.user?.role == UserRole.staff
          ? TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: AppLocale.received.getString(context)),
                Tab(text: AppLocale.sent.getString(context)),
              ],
              indicatorColor: colorScheme.onPrimary,
              labelColor: colorScheme.onPrimary,
            ) 
          : null,
      ),
      backgroundColor: colorScheme.tertiary,
      body: Column(
        children: [
          // search and Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: [
                // search Box
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppLocale.searchNotifications.getString(context),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: colorScheme.inversePrimary,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // topic Filter Dropdown
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedType ?? 'All',
                        icon: const Icon(Icons.filter_list),
                        isExpanded: true,
                        hint: Text(AppLocale.filterByType.getString(context)),
                        items: _allTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value == 'All' 
                                  ? AppLocale.allNotificationTypes.getString(context)
                                  : AppLocale.formatTypeDisplay(value, context),
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedType = newValue == 'All' ? null : newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // filter Chips
          if (_selectedType != null && _selectedType != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  Chip(
                    label: Text(_selectedType != null 
                      ? AppLocale.formatTypeDisplay(_selectedType!, context)
                      : ''),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedType = null;
                      });
                    },
                    backgroundColor: colorScheme.primary.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          
          // notification Content
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    return RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: widget.userProvider.user?.role == UserRole.admin ||
                            widget.userProvider.user?.role == UserRole.staff
                        ? TabBarView(
                          controller: _tabController,
                          children: [
                            // received notifications tab
                            _buildNotificationsList(
                              _filterNotifications(provider.receivedNotifications),
                              _onTapReceivedNotification,
                              AppLocale.noNotificationsReceived.getString(context),
                            ),
                            
                            // sent notifications tab
                            _buildNotificationsList(
                              _filterNotifications(provider.sentNotifications),
                              _onTapSentNotification,
                              AppLocale.noNotificationsSent.getString(context),
                            ),
                          ],
                        ) : _buildNotificationsList(
                            _filterNotifications(provider.receivedNotifications), 
                            _onTapReceivedNotification, 
                            AppLocale.noNotificationsReceived.getString(context),
                          ),
                    );
                  }
                ),
          ),
        ],
      ),
      floatingActionButton: widget.userProvider.user?.role == UserRole.admin ||
              widget.userProvider.user?.role == UserRole.staff
          ? FloatingActionButton(
              onPressed: () => NavigationHelper.navigateToSendNotificationPage(context),
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildNotificationsList(
    List<NotificationModel> notifications,
    Function(NotificationModel) onTap,
    String emptyMessage,
  ) {
    if (notifications.isEmpty) {
      return EmptyStateWidget(
        message: emptyMessage,
        icon: Icons.notifications_none,
      );
    }

    return ScrollableResponsiveWidget(
      phone: Column(
        children: notifications.map((notification) => _buildNotificationItem(notification, onTap)).toList(),
      ),
        tablet: Container(),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
    Function(NotificationModel) onTap,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // add a small delay based on index for staggered effect
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Hero(
        tag: 'notification-${notification.notificationID}',
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: InkWell(
            onTap: () => onTap(notification),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.inversePrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        child: const Icon(Icons.notifications, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.onPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormatUtil.formatDateTime(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onPrimary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteNotification(notification);
                          } else if (value == 'mark_read') {
                            _markAsRead(notification);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'mark_read',
                            child: Row(
                              children: [
                                const Icon(Icons.check),
                                const SizedBox(width: 8),
                                Text(AppLocale.markAsRead.getString(context)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete),
                                const SizedBox(width: 8),
                                Text(AppLocale.delete.getString(context)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Show image preview if available
                  if (notification.imageURLs != null && notification.imageURLs!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: notification.imageURLs!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(notification.imageURLs![index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapReceivedNotification(NotificationModel notification) {
    // show notification detail dialog
    _markAsRead(notification);
    _showNotificationDetailDialog(notification);
  }

  void _onTapSentNotification(NotificationModel notification) {
    // show notification detail dialog
    _showNotificationDetailDialog(notification);
  }

  void _showNotificationDetailDialog(NotificationModel notification) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormatUtil.formatDateTime(notification.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onPrimary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(notification.message),
              if (notification.imageURLs != null && notification.imageURLs!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(notification.imageURLs![0]),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (notification.imageURLs!.length > 1) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: notification.imageURLs!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Show full image dialog
                            _showFullImageDialog(notification.imageURLs![index]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(notification.imageURLs![index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocale.close.getString(context), 
              style: TextStyle(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(imageUrl),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
