import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/utils/validator_util.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({super.key});

  @override
  State<ResetPassPage> createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendResetCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      // return early if form is invalid
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim().toLowerCase();

    await _authService.sendResetCode(context, email, RouterPath.setnewpasspage);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      body: Stack(
        children: [
          ScrollableWidget(
            child: CenteredContainer(
              canNavigateBack: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocale.resetPassword.getString(context), 
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40,),
                  Form(
                    key: _formKey,
                    child: CustomTextFormField(
                      controller: _emailController,
                      labelText: AppLocale.email.getString(context),
                      validator: (value) => ValidatorUtil.validateEmail(context, _emailController.text),
                      leadingIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 40,),
                  CustomConfirmButton(
                    text: AppLocale.requestVerificationCode.getString(context), 
                    onPressed: () => _sendResetCode(),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            ProgressCircular(
              isLoading: _isLoading,
            ),
        ],
      ),
    );
  }
}
