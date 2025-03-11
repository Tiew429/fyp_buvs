import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/provider/voting_event_provider.dart';
import 'package:blockchain_university_voting_system/views/voting/confirmed_candidate_page.dart';
import 'package:blockchain_university_voting_system/views/voting/pending_candidate_page.dart';
import 'package:blockchain_university_voting_system/widgets/custom_animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ManageCandidatePage extends StatefulWidget {
  final VotingEventProvider _votingEventViewModel;

  const ManageCandidatePage({
    super.key,
    required VotingEventProvider votingEventViewModel,
  }) :_votingEventViewModel = votingEventViewModel;

  @override
  State<ManageCandidatePage> createState() => _ManageCandidatePageState();
}

class _ManageCandidatePageState extends State<ManageCandidatePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocale.manageCandidate.getString(context)),
        backgroundColor: colorScheme.secondary,
      ),
      backgroundColor: colorScheme.tertiary,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: colorScheme.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 0;
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocale.confirmedCandidate.getString(context)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 2,
                        width: 150,
                        color: _currentIndex == 0 
                          ? colorScheme.onPrimary
                          : Colors.transparent,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: colorScheme.onPrimary,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 1;
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppLocale.pendingCandidate.getString(context)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 2,
                        width: 150,
                        color: _currentIndex == 1
                          ? colorScheme.onPrimary
                          : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height - 106,
            child: PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                ConfirmedCandidatePage(votingEventViewModel: widget._votingEventViewModel),
                PendingCandidatePage(votingEventViewModel: widget._votingEventViewModel),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: CustomAnimatedButton(
        text: AppLocale.addCandidate.getString(context),
        onPressed: () => NavigationHelper.navigateToAddCandidatePage(context),
      ),
    );
  }
}
