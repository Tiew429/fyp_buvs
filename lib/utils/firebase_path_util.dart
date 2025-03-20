import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePathUtil {

  static CollectionReference getUserCollection(UserRole role) {
    return FirebaseFirestore.instance.collection('users').doc(role.name).collection(role.name);
  }

  static CollectionReference getUserCollectionWithoutRole() {
    return FirebaseFirestore.instance.collection('users');
  }

}
