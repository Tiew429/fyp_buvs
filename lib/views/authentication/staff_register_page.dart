import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:blockchain_university_voting_system/services/auth_service.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/utils/validator_util.dart';
import 'package:blockchain_university_voting_system/widgets/centered_container.dart';
import 'package:blockchain_university_voting_system/widgets/custom_confirm_button.dart';
import 'package:blockchain_university_voting_system/widgets/custom_text_form_field.dart';
import 'package:blockchain_university_voting_system/widgets/progress_circular.dart';
import 'package:blockchain_university_voting_system/widgets/scrollable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class StaffRegisterPage extends StatefulWidget {
  final bool _registerWithMetamask;

  const StaffRegisterPage({
    super.key,
    bool registerWithMetamask = false,
  }) : _registerWithMetamask = registerWithMetamask;

  @override
  State<StaffRegisterPage> createState() => _StaffRegisterPageState();
}

class _StaffRegisterPageState extends State<StaffRegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final walletProvider = Provider.of<WalletProvider>(rootNavigatorKey.currentContext!, listen: false);
  bool _isLoading = false;

  // selection for staff registration type
  int _selectedRegistrationType = 0; // 0 = Academic, 1 = Administrative
  
  // department options based on selection
  final List<String> _academicDepartments = [
    'Computer Science',
    'Information Technology',
    'Software Engineering',
    'Artificial Intelligence',
    'Data Science',
    'Cybersecurity',
  ];
  
  final List<String> _administrativeDepartments = [
    'Student Affairs',
    'Finance',
    'Human Resources',
    'Campus Services',
    'Alumni Relations',
    'Admissions',
  ];

  List<String> get _currentDepartmentOptions => 
    _selectedRegistrationType == 0 ? _academicDepartments : _administrativeDepartments;

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
    _departmentController.dispose();
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
    final department = _departmentController.text.isEmpty 
        ? _currentDepartmentOptions.first 
        : _departmentController.text.trim();

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
          UserRole.staff, // register as staff
          department, // pass department
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
        _authService.registerWithCredentials(
          context, 
          username, 
          email, 
          password, 
          '', // empty wallet address
          UserRole.staff, // register as staff
          department, // pass department
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
      }
    });
  }

  Widget _buildRegistrationTypeSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocale.staffType.getString(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRegistrationType = 0;
                    _departmentController.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedRegistrationType == 0
                        ? colorScheme.secondary
                        : colorScheme.primary.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: colorScheme.onPrimary,
                      width: Theme.of(context).brightness == Brightness.dark ? 3.0 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppLocale.academic.getString(context),
                      style: TextStyle(
                        color: _selectedRegistrationType == 0
                            ? colorScheme.onSecondary
                            : colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRegistrationType = 1;
                    _departmentController.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedRegistrationType == 1
                        ? colorScheme.secondary
                        : colorScheme.primary.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    border: Border.all(
                      color: colorScheme.onPrimary,
                      width: Theme.of(context).brightness == Brightness.dark ? 3.0 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppLocale.administrative.getString(context),
                      style: TextStyle(
                        color: _selectedRegistrationType == 1
                            ? colorScheme.onSecondary
                            : colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedRegistrationType == 0 
              ? AppLocale.academicDepartment.getString(context)
              : AppLocale.administrativeDepartment.getString(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(AppLocale.selectDepartment.getString(context)),
              value: _departmentController.text.isEmpty 
                  ? null 
                  : _departmentController.text,
              items: _currentDepartmentOptions
                  .map((department) => DropdownMenuItem(
                        value: department,
                        child: Text(department),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _departmentController.text = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
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
                  const SizedBox(height: 20),
                  Text(
                    AppLocale.staffRegistration.getString(context),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // staff type selector
                  _buildRegistrationTypeSelector(),
                  const SizedBox(height: 20),
                  
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
                        const SizedBox(height: 20),
                        CustomTextFormField(
                            controller: _emailController,
                            labelText: AppLocale.email.getString(context),
                            validator: (value) => ValidatorUtil.validateEmail(context, _emailController.text),
                            leadingIcon: const Icon(Icons.email),
                        ),
                        const SizedBox(height: 20),
                        
                        // department selector
                        _buildDepartmentSelector(),
                        const SizedBox(height: 20),
                        
                        CustomTextFormField(
                          controller: _passwordController,
                          labelText: AppLocale.password.getString(context),
                          validator: (value) => ValidatorUtil.validatePassword(context, _passwordController.text),
                          leadingIcon: const Icon(Icons.lock),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          controller: _confirmPasswordController,
                          labelText: AppLocale.confirmPassword.getString(context),
                          validator: (value) => ValidatorUtil.validateConfirmPassword(
                            context, 
                            _passwordController.text, 
                            _confirmPasswordController.text
                          ),
                          leadingIcon: const Icon(Icons.lock),
                          obscureText: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  CustomConfirmButton(
                    text: '${AppLocale.register.getString(context)} ${AppLocale.as.getString(context)} ${_selectedRegistrationType == 0 ? AppLocale.academic.getString(context) : AppLocale.administrative.getString(context)} ${AppLocale.staff.getString(context)}',
                    onPressed: () async {
                      await _register();
                    },
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${AppLocale.alreadyHaveAnAccount.getString(context)}? '),
                      GestureDetector(
                        onTap: () => NavigationHelper.navigateToLoginPage(context),
                        child: Text(AppLocale.loginHere.getString(context),
                          style: const TextStyle(
                            color: Colors.lightBlue,
                          ),
                        ),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 20),
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