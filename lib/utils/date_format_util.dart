import 'package:intl/intl.dart';

class DateFormatUtil {
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    // If less than a day ago, show relative time
    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        } else {
          return '${difference.inMinutes} min ago';
        }
      } else {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      }
    } 
    // If within the last week, show day and time
    else if (difference.inDays < 7) {
      final formatter = DateFormat('E, HH:mm');
      return formatter.format(dateTime);
    } 
    // If it's the same year, show month and day
    else if (dateTime.year == now.year) {
      final formatter = DateFormat('MMM d');
      return formatter.format(dateTime);
    } 
    // Otherwise show full date
    else {
      final formatter = DateFormat('MMM d, yyyy');
      return formatter.format(dateTime);
    }
  }
  
  static String formatFullDateTime(DateTime dateTime) {
    final formatter = DateFormat('MMM d, yyyy HH:mm');
    return formatter.format(dateTime);
  }
  
  static String formatDate(DateTime dateTime) {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(dateTime);
  }
  
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }
} 