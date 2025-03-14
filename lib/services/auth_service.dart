import 'package:blockchain_university_voting_system/data/router_path.dart';
import 'package:blockchain_university_voting_system/database/shared_preferences.dart';
import 'package:blockchain_university_voting_system/localization/app_locale.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart' as model_user;
import 'package:blockchain_university_voting_system/provider/wallet_provider.dart';
import 'package:blockchain_university_voting_system/repository/user_repository.dart';
import 'package:blockchain_university_voting_system/routes/navigation_helper.dart';
import 'package:blockchain_university_voting_system/utils/snackbar_util.dart';
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_user;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
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
      final usernameQuery = await _firestore
          .collection('users')
          .doc(role.name)
          .collection(role.name)
          .where('username', isEqualTo: username)
          .get();

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
      final usernameQuery = await _firestore
          .collection('users')
          .doc(role.name)
          .collection(role.name)
          .where('username', isEqualTo: username)
          .get();
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
      final emailQuery = await _firestore
          .collection('users')
          .doc(role.name)
          .collection(role.name)
          .where('email', isEqualTo: email)
          .get();
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

    if (walletAddress == null) return;
    
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
    } catch (e) {
      print("Error during Metamask login: $e");
      SnackbarUtil.showSnackBar(context, 'Login failed: $e');
    }
  }

  // call after success accessed with Biometrics (fingerprint)
  Future<void> loginWithBiometrics() async {}

  // save login status
  Future<void> setUserAndLoginAndNavigate(context, model_user.User user) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.setUser(user);
    userProvider.setInitialRoute('/${RouterPath.homepage.path}');
    await saveLoginStatus(true, user);
    NavigationHelper.navigateToHomePage(context);
  }

  // method to verify user in firestore
  Future<void> _verifyUserInFirestore(context, String userId) async {
    bool userFound = false;
    model_user.User? user;

    List<model_user.UserRole> roles = model_user.UserRoleExtension.getAllUserRoles();

    for (model_user.UserRole role in roles) {
      DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(role.name)
        .collection(role.name)
        .doc(userId)
        .get();

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
        );
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
  ]) async {
    try {
      // Check if username or email is already taken
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

      // Create user in Firestore + FirebaseAuth
      await userRepo.createUser(
        // Basically, the user will be a student. Admin and staff will be added earlier while deploying the app (admin) and added while inviting (staff).
        Student(
          userID: '', // Will be assigned internally in createUser method
          name: username,
          email: email,
          role: role,
          walletAddress: walletAddress,
          isEligibleForVoting: false,
        ),
        password,
      );

      // If user does not have a wallet address, just navigate to login page
      if (walletAddress.isEmpty) {
        NavigationHelper.navigateToLoginPage(context);
      } else {
        // If the user has a wallet address, you might directly log them in with Metamask
        await loginWithMetamask(context);
      }
    } on auth_user.FirebaseAuthException catch (e) {
      SnackbarUtil.showSnackBar(context, 'Registration failed: ${e.message}');
    } catch (e) {
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
        final emailQuery = await _firestore
          .collection('users')
          .doc(role.name)
          .collection(role.name)
          .where('email', isEqualTo: emailReset)
          .get();
          
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
      // Generate a random 6-digit code
      String verificationCode = (100000 + DateTime.now().microsecond % 900000).toString();

      // Store the verification code in Firestore
      await _firestore.collection('verificationCodes').doc(emailReset).set({
        'code': verificationCode,
        'createdAt': FieldValue.serverTimestamp(),
        'isUsed': false
      });

      // Check if environment variables are available
      final senderEmail = dotenv.env['GMAIL_MAIL'];
      final senderPassword = dotenv.env['GMAIL_PASSWORD'];
      
      if (senderEmail == null || senderPassword == null) {
        throw Exception('Email credentials not configured. Please check .env file.');
      }

      // Create smtp server for gmail
      final smtpServer = gmail(senderEmail, senderPassword);

      // Create message with HTML formatting
      final message = Message()
        ..from = Address(senderEmail, 'Blockchain University Voting System')
        ..recipients.add(emailReset)
        ..subject = 'Verification Code'
        ..html = '''
          <h2>Blockchain University Voting System</h2>
          <p>Your verification code is: <strong>$verificationCode</strong></p>
          <p>This code will expire in 10 minutes.</p>
          <p>If you didn't request this code, please ignore this email.</p>
        ''';

      // Send email with verification code
      await send(message, smtpServer);

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
