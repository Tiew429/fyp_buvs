import 'package:blockchain_university_voting_system/data/voting_event_status.dart';
import 'package:flutter/material.dart';

class ConverterUtil {

  static BigInt dateTimeToBigInt(DateTime x) {
    return intToBigInt(x.millisecondsSinceEpoch ~/ 1000);
  }

  static BigInt timeOfDayToBigInt(TimeOfDay x) {
    return intToBigInt(x.hour * 3600 + x.minute * 60);
  }

  static DateTime bigIntToDateTime(BigInt x) {
    return DateTime.fromMillisecondsSinceEpoch(ConverterUtil.bigIntToInt(x) * 1000);
  }

  static TimeOfDay bigIntToTimeOfDay(BigInt x) {
    int totalSeconds = ConverterUtil.bigIntToInt(x);
    return TimeOfDay(
      hour: totalSeconds ~/ 3600,
      minute: (totalSeconds % 3600) ~/ 60
    );
  }

  static BigInt intToBigInt(int x) {
    return BigInt.from(x);
  }

  static int bigIntToInt(BigInt x) {
    return x.toInt();
  }

  static VotingEventStatus intToVotingEventStatus(int x) {
    switch (x) {
      case 0:
        return VotingEventStatus.pending;
      case 1:
        return VotingEventStatus.approved;
      case 2:
        return VotingEventStatus.ongoing;
      case 3:
        return VotingEventStatus.completed;
      case 4:
        return VotingEventStatus.deprecated;
      default:
        return VotingEventStatus.deprecated; // if the status is missing, assume it will be deprecated
    }
  }

  static int votingEventStatusToInt(VotingEventStatus x) {
    switch (x) {
      case VotingEventStatus.pending:
        return 0;
      case VotingEventStatus.approved:
        return 1;
      case VotingEventStatus.ongoing:
        return 2;
      case VotingEventStatus.completed:
        return 3;
      case VotingEventStatus.deprecated:
        return 4;
    }
  }
  
}
