import 'dart:convert';

import 'package:http/http.dart' as http;

class FCMFunctions {

  static Future<void> sendNotification(String token, String title, String body) async {
    const String functionUrl = 'https://us-central1-blockchain-voting-system-f1dfe.cloudfunctions.net/sendNotification';

    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'token': token,
          'title': title,
          'body': body,
        }),
      );
      
      print("Notification sent to token: $token, Response: ${response.statusCode}");
      if (response.statusCode != 200) {
        print("Error response: ${response.body}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  static Future<void> sendTopicNotification(String topic, String title, String body) async {
    const String functionUrl = 'https://us-central1-blockchain-voting-system-f1dfe.cloudfunctions.net/sendTopicNotification';

    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'topic': topic,
          'title': title,
          'body': body,
        }),
      );
      
      print("Notification sent to topic: $topic, Response: ${response.statusCode}");
      if (response.statusCode != 200) {
        print("Error response: ${response.body}");
      }
    } catch (e) {
      print("Error sending topic notification: $e");
    }
  }

  static Future<void> sendMulticastNotification(List<String> tokens, String title, String body) async {
    const String functionUrl = 'https://us-central1-blockchain-voting-system-f1dfe.cloudfunctions.net/sendMulticastNotification';

    try {
      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'tokens': tokens,
          'title': title,
          'body': body,
        }),
      );
      
      print("Notification sent to ${tokens.length} tokens, Response: ${response.statusCode}");
      if (response.statusCode != 200) {
        print("Error response: ${response.body}");
      }
    } catch (e) {
      print("Error sending multicast notification: $e");
    }
  }
}
