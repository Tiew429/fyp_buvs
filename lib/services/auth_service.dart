import 'dart:math';

import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart' as model_user;
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/repository/user_repository.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/services/firebase_service.dart';
import 'package:blockchain_university_voting_system/utils/firebase_path_util.dart';
import 'package:blockchain_university_voting_system/utils/send_email_util.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_user;
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth_user.FirebaseAuth _auth = auth_user.FirebaseAuth.instance;
  final UserRepository userRepo = UserRepository();

  // check is user in database by username
  // Helper to find an email associated with a given username across all roles
  Future<String?> _getEmailByUsername(String username) async {
    final roles = model_user.UserRoleExtension.getAllUserRoles();

    for (var role in roles) {
      final usernameQuery = await FirebasePathUtil.getUserCollection(role).where('username', isEqualTo: username).get();

      if (usernameQuery.docs.isNotEmpty) {
        return usernameQuery.docs.first['email'] as String;
      }
    }
    return null;
  }

  // check is user in database by email
  Future<void> checkUserByEmail(String email) async {}

  // check is user in database by wallet address
  Future<void> checkUserByWalletAddress(String walletAddress) async {}

  // check is user in database by biometrics
  Future<void> checkUserByBiometrics(String hahaha, String soHard) async {}

  /// Check if the given username already exists across all roles
  Future<bool> _isUsernameTaken(String username) async {
    final roles = model_user.UserRoleExtension.getAllUserRoles();
    for (var role in roles) {
      final usernameQuery = await FirebasePathUtil.getUserCollection(role).where('username', isEqualTo: username).get();
      if (usernameQuery.docs.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  /// Check if the given email already exists across all roles
  Future<bool> _isEmailTaken(String email) async {
    final roles = model_user.UserRoleExtension.getAllUserRoles();
    for (var role in roles) {
      final emailQuery = await FirebasePathUtil.getUserCollection(role).where('email', isEqualTo: email).get();
      if (emailQuery.docs.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  // ---------------
  // LOGIN FUNCTIONS
  // ---------------
  Future<void> loginWithCredentials(
    context,
    String emailOrUsername,
    String password,
  ) async {
    try {
      // check the input is email or username
      final bool isEmail = emailOrUsername.contains('@');

      // 1. verify with firebase authentication
      if (isEmail) {
        auth_user.UserCredential userCredential = await _auth
        .signInWithEmailAndPassword(
          email: emailOrUsername,
          password: password,
        );
        if (userCredential.user != null) {
          await _verifyUserInFirestore(context, userCredential.user!.uid);
        }
      } else {
        // 2. login with username
        final String? foundEmail = await _getEmailByUsername(emailOrUsername);
        if (foundEmail == null) {
          // username not found in any role
          SnackbarUtil.showSnackBar(context, AppLocale.userNotFound.getString(context));
          return;
        }

        // If found, sign in using the discovered email
        auth_user.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: foundEmail,
          password: password,
        );

        if (userCredential.user != null) {
          await _verifyUserInFirestore(context, userCredential.user!.uid);
        }
      }
    } on auth_user.FirebaseAuthException catch (e) {
      SnackbarUtil.showSnackBar(context, 'Login failed: ${e.message}');
    } catch (e) {
      // Add error handling to show user feedback
      SnackbarUtil.showSnackBar(context, 'Login failed: $e');
    }
  }

  // call after success connected with Metamask
  Future<void> loginWithMetamask(context) async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    String? walletAddress = walletProvider.walletAddress;

    if (walletAddress == null) {
      print("AuthService: Wallet address is null");
      return;
    }
    
    try {
      model_user.User? userRetrieved = await userRepo.retrieveUser(walletAddress);

      // if user found set userviewmodel and save login status
      print("User email: ${userRetrieved?.email}");
      print("User address: ${userRetrieved?.walletAddress}");
      if (userRetrieved != null) {
        setUserAndLoginAndNavigate(context, userRetrieved);
        return;
      }

      // if user not found, navigate to register page
      NavigationHelper.navigateToRegisterPage(context, true);
      SnackbarUtil.showSnackBar(context, AppLocale.pleaseRegister.getString(context));
    } catch (e) {
      print("Error during Metamask login: $e");
      SnackbarUtil.showSnackBar(context, 'Login failed: $e');
    }
  }

  // call after success accessed with Biometrics (fingerprint)
  Future<void> loginWithBiometrics() async {}

  // save login status
  Future<void> setUserAndLoginAndNavigate(context, model_user.User user) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(user);
      userProvider.setInitialRoute('/${RouterPath.homepage.path}');
      await saveLoginStatus(true, user);
      
      // save FCM token
      try {
        await FirebaseService.saveUserFCMToken(user.userID);
      } catch (e) {
        print("FCM token saving failed, but continuing login: $e");
      }
      SnackbarUtil.showSnackBar(context, AppLocale.loginSuccess.getString(context));
      NavigationHelper.navigateToHomePage(context);
    } catch (e) {
      print("Error during login and navigation: $e");
      SnackbarUtil.showSnackBar(context, 'Login process error: $e');
    }
  }

  // method to verify user in firestore
  Future<void> _verifyUserInFirestore(context, String userId) async {
    bool userFound = false;
    model_user.User? user;

    List<model_user.UserRole> roles = model_user.UserRoleExtension.getAllUserRoles();

    for (model_user.UserRole role in roles) {
      DocumentSnapshot userDoc = await FirebasePathUtil.getUserCollection(role).doc(userId).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        
        user = model_user.User(
          userID: userData['userID'],
          name: userData['username'],
          email: userData['email'],
          role: role,
          walletAddress: userData['walletAddress'],
          bio: userData['bio'],
          isVerified: userData['isVerified'],
          avatarUrl: userData['avatarUrl'],
          freezed: userData['freezed'],
        );

        final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

        if (role == model_user.UserRole.staff) {
            print("user is staff");
            userProvider.setDepartment(userData['department']);
          } else if (role == model_user.UserRole.student) {
            print("user is student");
            print("isEligibleForVoting: ${userData['isEligibleForVoting']}");
            userProvider.setIsEligibleForVoting(userData['isEligibleForVoting']);
          } else {
            print("user is admin");
          }

        setUserAndLoginAndNavigate(context, user);
        userFound = true;
        break;
      }
    }

    if (!userFound) {
      SnackbarUtil.showSnackBar(context, AppLocale.userNotFound.getString(context));
    }
  }

  // register methods
  Future<void> registerWithCredentials(
    BuildContext context,
    String username,
    String email,
    String password, [
    String walletAddress = '',
    model_user.UserRole role = model_user.UserRole.student,
    String department = 'General',
  ]) async {
    try {
      bool registerSuccess = false;
      // check if username or email is already taken
      final bool usernameExists = await _isUsernameTaken(username);
      if (usernameExists) {
        SnackbarUtil.showSnackBar(context, 'Username is already taken');
        return;
      }

      final bool emailExists = await _isEmailTaken(email);
      if (emailExists) {
        SnackbarUtil.showSnackBar(context, 'Email is already taken');
        return;
      }

      // create user in firestore + firebase authentication
      if (role == model_user.UserRole.staff) {
        print('Creating staff user with department: $department');
        registerSuccess = await userRepo.createUser(
          Staff(
            userID: '', // will be assigned internally in createUser method
            name: username,
            email: email,
            role: role,
            walletAddress: walletAddress,
            department: department,
            freezed: false,
          ),
          password,
        );
        print('Staff user created successfully');
      } else {
        registerSuccess = await userRepo.createUser(
          Student(
            userID: '', // will be assigned internally in createUser method
            name: username,
            email: email,
            role: role,
            walletAddress: walletAddress,
            isEligibleForVoting: false,
            freezed: false,
          ),
          password,
        );
        print('Student user created successfully');
      }

      if (!registerSuccess) {
        return;
      }

      // success message
      SnackbarUtil.showSnackBar(context, AppLocale.registrationSuccess.getString(context));

      // if user does not have a wallet address, just navigate to login page
      if (walletAddress.isEmpty) {
        NavigationHelper.navigateToLoginPage(context);
      } else {
        // if the user has a wallet address, you might directly log them in with Metamask
        await loginWithMetamask(context);
        SnackbarUtil.showSnackBar(context, '${AppLocale.walletConnectionSuccessful.getString(context)}!');
      }
    } on auth_user.FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      SnackbarUtil.showSnackBar(context, 'Registration failed: ${e.message}');
    } catch (e) {
      print('Registration Error: $e');
      SnackbarUtil.showSnackBar(context, 'Registration failed: $e');
    }
  }

  // reset password methods
  Future<void> sendResetCode(context, String emailReset, RouterPath navigationDestination) async {
    // 1. check is the email exist in database
    try {
      bool emailExists = false;
      
      // check email exists in each role collection
      List<model_user.UserRole> roles = model_user.UserRoleExtension.getAllUserRoles();
      for (model_user.UserRole role in roles) {
        final emailQuery = await FirebasePathUtil.getUserCollection(role).where('email', isEqualTo: emailReset).get();
          
        if (emailQuery.docs.isNotEmpty) {
          emailExists = true;
          break;
        }
      }

      if (!emailExists) {
        SnackbarUtil.showSnackBar(context, 'Email not found');
        return;
      }
    } catch (e) {
      SnackbarUtil.showSnackBar(context, 'An error occurred');
      return;
    }

    // 2. send verification code to email
    try {
      // generate a random 6-digit code
      var rnd = Random();
      var next = rnd.nextInt(900000);
      while (next < 100000) {
        next *= 10;
      }
      String verificationCode = next.toString();

      // store the verification code in Firestore
      await _firestore.collection('verificationCodes').doc(emailReset).set({
        'code': verificationCode,
        'createdAt': FieldValue.serverTimestamp(),
        'isUsed': false
      });

      await SendEmailUtil.sendEmail(
        emailReset,
        'Verification Code',
        '<h2>Blockchain University Voting System</h2> <p>Your verification code is $verificationCode</p> <p>This code will expire in 10 minutes.</p> <p>If you didn\'t request this code, please ignore this email.</p>',
      );

      SnackbarUtil.showSnackBar(context, 'Verification code sent to your email');
    } catch (e) {
      SnackbarUtil.showSnackBar(context, 'Error sending verification code: ${e.toString()}');
      return;
    }
    
    // 3. navigate to verification code page
    NavigationHelper.navigateToVerificationCodePage(context, emailReset, navigationDestination);
  }

  // verify the verification code is correct or not
  Future<void> verifyCode(context, String code, String emailReset, RouterPath navigationDestination) async {
    // 1. compare the code is same or not
    final verificationCode = await _firestore.collection('verificationCodes').doc(emailReset).get();
    if (verificationCode.data()?['code'] != code) {
      SnackbarUtil.showSnackBar(context, 'Invalid verification code');
      return;
    }

    // 2. send reset password email
    await _auth.sendPasswordResetEmail(email: emailReset);
    SnackbarUtil.showSnackBar(context, 'Reset password email sent');

    // 3. if yes, navigate to reset password page, else toast error
    NavigationHelper.navigateToLoginPage(context);
  }

  // when the verification code input is correct
  // used this method to reset the account password
  Future<void> resetPassword(context, String email, String newPassword) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);

      SnackbarUtil.showSnackBar(context, 'Password reset successfully');
    } catch (e) {
      print(e);
    }
  }

  // logout method
  Future<void> logout(context) async {
    // 1. navigate to login page
    NavigationHelper.navigateToLoginPage(context);

    // 2. clear 'isLoggedIn' shared preferences
    await clearLoginStatus();
    
    // 3. clear user in userviewmodel and set initial route
    final userViewModel = Provider.of<UserProvider>(context, listen: false);
    userViewModel.clearUser();
    userViewModel.setInitialRoute('/${RouterPath.loginpage.path}');
  }
}
