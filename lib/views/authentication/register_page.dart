import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/utils/validator_util.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final bool _registerWithMetamask;

  const RegisterPage({
    super.key,
    bool registerWithMetamask = false,
  }) :_registerWithMetamask = registerWithMetamask;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final walletProvider = Provider.of<WalletProvider>(rootNavigatorKey.currentContext!, listen: false);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  Future<void> _register() async {
    // close keyboard
    FocusScope.of(context).unfocus();

    // set loading to true
    setState(() {
      _isLoading = true;
    });
    if (!(_formKey.currentState?.validate() ?? false)) {
      // return early if form is invalid
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    // use Future.delayed to ensure the loading indicator has time to appear
    Future.delayed(Duration.zero, () {
      if (widget._registerWithMetamask) {
        // register with metamask
        _authService.registerWithCredentials(
          context, 
          username, 
          email, 
          password, 
          walletProvider.walletAddress ?? '',
        ).then((_) {
          // set loading to false after the registration completes
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }).catchError((error) {
          // handle any errors and set loading to false
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      } else {
        _authService.registerWithCredentials(context, username, email, password)
        .then((_) {
          // set loading to false after the registration completes
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }).catchError((error) {
          // handle any errors and set loading to false
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.tertiary,
      body: Stack(
        children: [
          ScrollableWidget(
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
                          controller: _usernameController,
                          labelText: AppLocale.username.getString(context),
                          validator: (value) => ValidatorUtil.validateEmpty(context, _usernameController.text),
                          leadingIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(height: 20,),
                        CustomTextFormField(
                            controller: _emailController,
                            labelText: AppLocale.email.getString(context),
                            validator: (value) => ValidatorUtil.validateEmail(context, _emailController.text),
                            leadingIcon: const Icon(Icons.email),
                        ),
                        const SizedBox(height: 20,),
                        CustomTextFormField(
                          controller: _passwordController,
                          labelText: AppLocale.password.getString(context),
                          validator: (value) => ValidatorUtil.validatePassword(context, _passwordController.text),
                          leadingIcon: const Icon(Icons.lock),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20,),
                        CustomTextFormField(
                          controller: _confirmPasswordController,
                          labelText: AppLocale.confirmPassword.getString(context),
                          validator: (value) => ValidatorUtil.validatePassword(context, _confirmPasswordController.text),
                          leadingIcon: const Icon(Icons.lock),
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  CustomConfirmButton(
                    text: AppLocale.register.getString(context),
                    onPressed: () async {
                      await _register();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${AppLocale.alreadyHaveAnAccount.getString(context)}? '),
                      GestureDetector(
                        onTap: () => NavigationHelper.navigateToLoginPage(context), // navigate to register page
                        child: Text(AppLocale.loginHere.getString(context),
                          style: const TextStyle(
                            color: Colors.lightBlue,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                ],
              ),
            ),
          ),
          if (_isLoading)
            ProgressCircular(
              isLoading: true,
              message: AppLocale.registering.getString(context),
            ),
        ],
      ),
    );
  }
}
