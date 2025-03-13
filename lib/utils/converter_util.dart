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

  static TimeOfDay bigIntToTimeOfDay(dynamic x) {
    // Ensure it's parsed to BigInt first
    final intValue = (x is BigInt) ? x.toInt() : int.parse(x.toString());
    
    return TimeOfDay(
      hour: (intValue ~/ 3600), // Convert seconds to hours
      minute: (intValue % 3600) ~/ 60, // Convert remaining seconds to minutes
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
        return VotingEventStatus.available;
      case 1:
        return VotingEventStatus.deprecated;
      default:
        return VotingEventStatus.deprecated; // if the status is missing, assume it will be deprecated
    }
  }

  static int votingEventStatusToInt(VotingEventStatus x) {
    switch (x) {
      case VotingEventStatus.available:
        return 0;
      case VotingEventStatus.deprecated:
        return 1;
    }
  }
  
}
