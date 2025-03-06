import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/viewmodels/voting_event_viewmodel.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:blockchain_university_voting_system/widgets/response_widget.dart';
import 'package:blockchain_university_voting_system/widgets/voting_event_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class VotingListPage extends StatefulWidget {
  final User _user;
  final VotingEventViewModel _votingEventViewModel;
  final WalletProvider _walletProvider;

  const VotingListPage({
    super.key, 
    required User user,
    required VotingEventViewModel votingEventViewModel,
    required WalletProvider walletProvider,
  }) :_user = user,
      _votingEventViewModel = votingEventViewModel,
      _walletProvider = walletProvider;

  @override
  State<VotingListPage> createState() => _VotingListPageState();
}

class _VotingListPageState extends State<VotingListPage> {
  bool _isLoading = true;
  late List<VotingEvent> _votingEventList;

  @override
  void initState() {
    super.initState();
    _loadVotingEvents();
  }

  Future<void> _loadVotingEvents() async {
    setState(() => _isLoading = true);
    await widget._votingEventViewModel.loadVotingEvents();
    setState(() {
      _votingEventList = widget._votingEventViewModel.votingEventList;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.votingList.getString(context)),
        backgroundColor: colorScheme.secondary,
      ),
      backgroundColor: colorScheme.tertiary,
      body: ScrollableResponsiveWidget(
        phone: widget._walletProvider.walletAddress == null || 
              widget._walletProvider.walletAddress!.isEmpty
          ? Center(
              child: Text(
                AppLocale.pleaseConnectYourWallet.getString(context),
                style: TextStyle(
                  color: colorScheme.onTertiary,
                  fontSize: 16,
                ),
              ),
            )
          : _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: _votingEventList.isEmpty
                    ? [
                        Center(
                          child: Text(AppLocale.noVotingEventAvailable.getString(context)),
                        ),
                      ]
                    : _votingEventList.map((event) => VotingEventBox(
                        onTap: () {
                          widget._votingEventViewModel.selectVotingEvent(event);
                          NavigationHelper.navigateToVotingEventPage(context);
                        },
                        votingEvent: event,
                      )).toList(),
                ), 
        tablet: Container(),
      ),
      floatingActionButton: (
        (widget._user.role == UserRole.admin ||
        widget._user.role == UserRole.staff) &&
        (widget._walletProvider.walletAddress != null &&
        widget._walletProvider.walletAddress!.isNotEmpty)
      ) ? CustomAnimatedButton(
        onPressed: () => NavigationHelper.navigateToVotingEventCreatePage(context), 
        text: AppLocale.createNew.getString(context),
      ) : null,
    );
  }
}
