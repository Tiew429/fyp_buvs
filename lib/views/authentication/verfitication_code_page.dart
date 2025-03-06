import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/utils/validator_util.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class VerificationCodePage extends StatefulWidget {
  final String _email;
  final RouterPath _navigationDestination;
  
  const VerificationCodePage({
    super.key,
    required String email,
    required RouterPath navigationDestination,
  }) :_email = email,
      _navigationDestination = navigationDestination;

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final TextEditingController _codeController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  void _verifyCode() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      // return early if form is invalid
      return;
    }

    final code = _codeController.text.trim();

    _authService.verifyCode(context, code, widget._email, widget._navigationDestination);
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
              Image.asset('assets/images/otp.png',
                width: 200,
                height: 200,
              ),
              Text(AppLocale.verification.getString(context), 
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40,),
              Form(
                key: _formKey,
                child: CustomTextFormField(
                  controller: _codeController,
                  labelText: AppLocale.verificationCode.getString(context),
                  validator: (value) => ValidatorUtil.validateEmpty(context, _codeController.text),
                  leadingIcon: const Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 40,),
              CustomConfirmButton(
                text: AppLocale.verify.getString(context), 
                onPressed: () => _verifyCode(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
