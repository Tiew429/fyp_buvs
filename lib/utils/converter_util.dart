import 'package:blockchain_university_voting_system/data/voting_event_status.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ConverterUtil {

  /// Returns the current date and time in Malaysia timezone (UTC+8)
  static DateTime getMalaysiaDateTime() {
    tz.initializeTimeZones();
    final malaysia = tz.getLocation('Asia/Kuala_Lumpur');
    final now = tz.TZDateTime.now(malaysia);
    return now;
  }

  /// Returns TimeOfDay representing current Malaysia time (UTC+8)
  static TimeOfDay getMalaysiaTimeOfDay() {
    final now = getMalaysiaDateTime();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

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

  /// Converts any DateTime to Malaysia time (UTC+8)
  static DateTime toMalaysiaTime(DateTime dateTime) {
    return dateTime.toUtc().add(const Duration(hours: 8));
  }

  /// Creates a Malaysia timezone DateTime with both date and time components
  static DateTime createMalaysiaDateTime(DateTime date, TimeOfDay time) {
    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    ).add(const Duration(hours: 8));
  }

  /// Formats a date for display in Malaysia timezone (dd/mm/yyyy)
  static String formatMalaysiaDate(DateTime date) {
    final malaysiaTime = toMalaysiaTime(date);
    return "${malaysiaTime.day}/${malaysiaTime.month}/${malaysiaTime.year}";
  }

  /// Formats a time for display (hh:mm)
  static String formatTime(TimeOfDay time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  /// Formats a date range for display in Malaysia timezone
  static String formatMalaysiaDateRange(DateTime startDate, DateTime endDate) {
    return "${formatMalaysiaDate(startDate)} - ${formatMalaysiaDate(endDate)}";
  }

  /// Formats a time range for display
  static String formatTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    return "${formatTime(startTime)} - ${formatTime(endTime)}";
  }
}
