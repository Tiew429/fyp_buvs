import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class VotingEventBox extends StatelessWidget {
  final Function onTap;
  final VotingEvent votingEvent;

  const VotingEventBox({
    super.key,
    required this.onTap,
    required this.votingEvent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: CenteredContainer(
        containerPaddingVertical: 10.0,
        child: Text("${AppLocale.title.getString(context)}: ${votingEvent.title}\n${AppLocale.date.getString(context)}: ${
          votingEvent.startDate!.day}/${votingEvent.startDate!.month}/${votingEvent.startDate!.year
        } - ${
          votingEvent.endDate!.day}/${votingEvent.endDate!.month}/${votingEvent.endDate!.year
        }"),
      ),
    );
  }
}
