import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/voting_event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class VotingEventBox extends StatelessWidget {
  final Function onTap;
  final VotingEvent votingEvent;
  final bool showStatusIndicator;

  const VotingEventBox({
    super.key,
    required this.onTap,
    required this.votingEvent,
    this.showStatusIndicator = true,
  });

  String _getEventStatus(BuildContext context) {
    if (votingEvent.status.name == 'deprecated') {
      return AppLocale.deprecated.getString(context);
    }
    
    DateTime now = DateTime.now();
    TimeOfDay nowTime = TimeOfDay.now();
    
    // event hasn't started yet
    if (now.isBefore(votingEvent.startDate!) || 
        (now.isAtSameMomentAs(votingEvent.startDate!) && 
         (nowTime.hour < votingEvent.startTime!.hour || 
          (nowTime.hour == votingEvent.startTime!.hour && 
           nowTime.minute < votingEvent.startTime!.minute)))) {
      return AppLocale.waitingToStart.getString(context);
    }
    
    // event has ended
    if (now.isAfter(votingEvent.endDate!) || 
        (now.isAtSameMomentAs(votingEvent.endDate!) && 
         (nowTime.hour > votingEvent.endTime!.hour || 
          (nowTime.hour == votingEvent.endTime!.hour && 
           nowTime.minute > votingEvent.endTime!.minute)))) {
      return AppLocale.ended.getString(context);
    }
    
    // event is ongoing
    return AppLocale.ongoing.getString(context);
  }

  Color _getStatusColor(BuildContext context) {
    final status = _getEventStatus(context);
    
    if (status == AppLocale.deprecated.getString(context)) {
      return Colors.grey.withOpacity(0.7); // deprecated events are grey
    } else if (status == AppLocale.waitingToStart.getString(context)) {
      return Colors.blue.withOpacity(0.7); // waiting events are blue
    } else if (status == AppLocale.ongoing.getString(context)) {
      return Colors.green.withOpacity(0.7); // ongoing events are green
    } else { // ended
      return Colors.orange.withOpacity(0.7); // ended events are orange
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String eventStatus = _getEventStatus(context);
    final Color statusColor = _getStatusColor(context);
    
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: showStatusIndicator ? statusColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                colorScheme.surface,
                showStatusIndicator 
                  ? statusColor.withOpacity(0.1) 
                  : colorScheme.surface,
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      votingEvent.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showStatusIndicator)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        eventStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                votingEvent.description,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onPrimary.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${votingEvent.startDate!.day}/${votingEvent.startDate!.month}/${votingEvent.startDate!.year} - ${votingEvent.endDate!.day}/${votingEvent.endDate!.month}/${votingEvent.endDate!.year}",
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimary.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${votingEvent.startTime!.format(context)} - ${votingEvent.endTime!.format(context)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimary.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${AppLocale.candidateParticipated.getString(context)}: ${votingEvent.candidates.length}",
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    "ID: ${votingEvent.votingEventID}",
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
