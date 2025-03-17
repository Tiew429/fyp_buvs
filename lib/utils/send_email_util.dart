import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SendEmailUtil {

  static Future<void> sendEmail(String to, String subject, String body) async {
    final senderEmail = dotenv.env['GMAIL_MAIL'];
    final senderPassword = dotenv.env['GMAIL_PASSWORD'];

    if (senderEmail == null || senderPassword == null) {
      throw Exception('Email credentials not configured. Please check .env file.');
    }

    final smtpServer = gmail(senderEmail, senderPassword);
    final message = Message()
      ..from = Address(senderEmail, 'Blockchain University Voting System')
      ..recipients.add(to)
      ..subject = subject
      ..html = body;

    await send(message, smtpServer);
  }

}
