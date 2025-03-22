import 'package:blockchain_university_voting_system/models/admin_model.dart';
import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart' as model_user;
import 'package:blockchain_university_voting_system/provider/user_provider.dart';
import 'package:blockchain_university_voting_system/routes/navigation_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as auth_user;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class UserRepository {
  final _firestore = auth_user.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser<T> (dynamic newUser, String password) async {
    try {
      // 1. create user in firebase authentication
      final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(
          email: newUser.email, 
          password: password,
        );

      // 2. store user data in firestore
      final String userId = userCredential.user!.uid;
      final model_user.UserRole role = newUser.role;
      final String roleString = role.stringValue;
      
      print("Role string value: $roleString");
      
      // create user document in the role-specific subcollection
      final auth_user.CollectionReference roleCollection = _firestore
        .collection('users')
        .doc(roleString)
        .collection(roleString);

      final Map<String, dynamic> userData = {
        'userID': userId,
        'username': newUser.name,
        'email': newUser.email,
        'role': roleString,
        'walletAddress': newUser.walletAddress ?? '',
        'bio': '',
        'isVerified': false,
      };

      await roleCollection.doc(userId).set(userData);

      // 3. store role-specific data in separate collections
      if (role == model_user.UserRole.student) {
        // add student-specific data
        await _firestore.collection("users")
          .doc(roleString)
          .collection(roleString)
          .doc(userId)
          .update({
            'isEligibleForVoting': false,
          });
      } else if (role == model_user.UserRole.staff) {
        // add staff-specific data with department
        await _firestore.collection("users")
          .doc(roleString)
          .collection(roleString)
          .doc(userId)
          .update({
            'department': newUser.department ?? 'General',
          });
        
        // log to verify the department is being saved
        print('Creating staff user with department: ${newUser.department}');
      }
      
      print('User created successfully with ID: $userId and role: ${role.stringValue}');
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  Future<void> updateUser<T> (model_user.User updatedUser) async {
    try {
      // get authenticated user
      final User? firebaseUser = _auth.currentUser;

      if (firebaseUser == null || firebaseUser.uid != updatedUser.userID) {
        throw Exception("User not authenticated or invalid user ID.");
      }

      // update user's email in firebase authentication if it has changed
      if (firebaseUser.email != updatedUser.email) {
        await firebaseUser.updateEmail(updatedUser.email);
      }

      // update firestore doc
      final model_user.UserRole role = updatedUser.role;
      final auth_user.CollectionReference roleCollection = _firestore
        .collection('users')
        .doc(role.stringValue)
        .collection(role.stringValue);
      
      await roleCollection.doc(updatedUser.userID).update({
        'username': updatedUser.name,
        'email': updatedUser.email,
        'walletAddress': updatedUser.walletAddress,
        'bio': updatedUser.bio,
        'isVerified': updatedUser.isVerified,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<model_user.User?> retrieveUser(String data) async {
    try {
      // detect the type of data (userID? email? walletAddress?)
      String fieldToSearch;
      if (data.contains('@')) {
        fieldToSearch = 'email';
      } else if (data.startsWith('0x') && data.length == 42) {
        fieldToSearch = 'walletAddress';
      } else {
        fieldToSearch = 'userID';
      }

      // iterate over all user role collection to find user
      for (final role in model_user.UserRole.values) {
        final auth_user.QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(role.stringValue)
          .collection(role.stringValue)
          .where(fieldToSearch, isEqualTo: data)
          .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final userData = doc.data() as Map<String, dynamic>;
          final UserProvider userProvider = Provider.of(rootNavigatorKey.currentContext!, listen: false);

          if (role == model_user.UserRole.staff) {
            userProvider.setDepartment(userData['department']);
            return Staff.fromJson(userData);
          } else if (role == model_user.UserRole.student) {
            userProvider.setIsEligibleForVoting(userData['isEligibleForVoting']);
            return Student.fromJson(userData);
          } else {
            return Admin.fromJson(userData);
          }
        }
      }
      
      // if user not found in any role collection
      print("User not found with the provided $fieldToSearch: $data");
    } catch (e) {
      print(e);
    }
    return null;
  }
}
