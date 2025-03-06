import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/utils/toast_util.dart';
import 'package:blockchain_university_voting_system/utils/validator_util.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class SetNewPassPage extends StatefulWidget {
  final String _email;
  
  const SetNewPassPage({
    super.key,
    required String email,
  }) :_email = email;

  @override
  State<SetNewPassPage> createState() => _SetNewPassPageState();
}

class _SetNewPassPageState extends State<SetNewPassPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  void _resetPass() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      // return early if form is invalid
      return;
    }

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmNewPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ToastUtil.showToast(context, AppLocale.passwordsDoNotMatch.getString(context));
      return;
    }

    _authService.resetPassword(context, widget._email, newPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: ScrollableWidget(
        child: CenteredContainer(
          canNavigateBack: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocale.setNewPassword.getString(context), 
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: _newPasswordController,
                      labelText: AppLocale.newPassword.getString(context),
                      validator: (value) => ValidatorUtil.validatePassword(context, _newPasswordController.text),
                      leadingIcon: const Icon(Icons.lock),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20,),
                    CustomTextFormField(
                      controller: _confirmNewPasswordController,
                      labelText: AppLocale.confirmNewPassword,
                      validator: (value) => ValidatorUtil.validatePassword(context, _confirmNewPasswordController.text),
                      leadingIcon: const Icon(Icons.lock),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40,),
              CustomConfirmButton(
                text: AppLocale.reset.getString(context),
                onPressed: () => _resetPass(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
