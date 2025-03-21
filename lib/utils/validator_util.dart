import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ValidatorUtil {
  static String? validateEmpty(context, String? text,) {
    if (text == null || text.trim().isEmpty) {
      return '${AppLocale.dontLeaveBlank.getString(context)}!';
    }
    return null;
  }

  static String? validateEmail(context, String? email) {
    // basic email regex pattern
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(emailPattern);

    if (email == null || email.trim().isEmpty) {
      return '${AppLocale.emailCantBeBlank.getString(context)}!';
    } else if (!regExp.hasMatch(email)) {
      return '${AppLocale.enterValidEmail.getString(context)}!';
    }
    return null;
  }

  static String? validatePassword(context, String? password) {
    if (password == null || password.trim().isEmpty) {
      return '${AppLocale.passwordCantBeBlank.getString(context)}!';
    } else if (password.length < 6) {
      return '${AppLocale.passwordMustAtLeast6Char.getString(context)}!';
    }
    return null;
  }
  
  static String? validateConfirmPassword(context, String password, String confirmPassword) {
    if (confirmPassword.trim().isEmpty) {
      return '${AppLocale.passwordCantBeBlank.getString(context)}!';
    } else if (password != confirmPassword) {
      return 'Passwords do not match!';
    }
    return null;
  }
}
