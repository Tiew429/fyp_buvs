import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/utils/validator_util.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:reown_appkit/reown_appkit.dart';

class LoginPage extends StatefulWidget {
  final ReownAppKitModal _appKitModal;

  const LoginPage({
    super.key,
    required ReownAppKitModal appKitModal,
  }) : _appKitModal = appKitModal;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameOrEmailController.dispose();
    _passwordController.dispose();
  }

  void _loginWithCredentials() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      // return early if form is invalid
      return;
    }
    final emailOrUsername = _usernameOrEmailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    _authService.loginWithCredentials(
      context,
      emailOrUsername,
      password,
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.tertiary,
      body: ScrollableWidget(
        child: CenteredContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png'),
              const SizedBox(height: 40,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: _usernameOrEmailController,
                      labelText: '${AppLocale.username.getString(context)} / ${AppLocale.email.getString(context)}',
                      validator: (value) => ValidatorUtil.validateEmpty(context, _usernameOrEmailController.text),
                      leadingIcon: const Icon(Icons.person),
                    ),
                    const SizedBox(height: 20,),
                    CustomTextFormField(
                      controller: _passwordController,
                      labelText: AppLocale.password.getString(context),
                      validator: (value) => ValidatorUtil.validateEmpty(context, _passwordController.text),
                      leadingIcon: const Icon(Icons.lock),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => NavigationHelper.navigateToResetPassPage(context), // navigate to reset password page
                    child: Text('${AppLocale.forgotPassword.getString(context)}?', 
                      style: const TextStyle(
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              CustomConfirmButton(
                text: AppLocale.login.getString(context),
                onPressed: () {
                  _loginWithCredentials();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${AppLocale.doesNotHaveAccount.getString(context)}? '),
                  GestureDetector(
                    onTap: () => NavigationHelper.navigateToRegisterPage(context), // navigate to register page
                    child: Text(AppLocale.registerHere.getString(context),
                      style: const TextStyle(
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Text('${AppLocale.otherLoginMethods.getString(context)}:'),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AppKitModalConnectButton(
                    appKit: widget._appKitModal,
                    context: context,
                    custom: GestureDetector(
                      onTap: () {
                        widget._appKitModal.openModalView();
                      },
                      child: Image.asset('assets/images/fox.png',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset('assets/images/security.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
