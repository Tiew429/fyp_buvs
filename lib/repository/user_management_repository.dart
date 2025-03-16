import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/models/user_model.dart';
import 'package:blockchain_university_voting_system/utils/firebase_path_util.dart';

class UserManagementRepository {
  
  Future<List<Staff>> getAllStaff() async {
    try {
      final staffCollection = FirebasePathUtil.getUserCollection(UserRole.staff);
      final staffSnapshot = await staffCollection.get();
      return staffSnapshot.docs.map((doc) => Staff.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching staff: $e');
      return [];
    }
  }

  Future<List<Student>> getAllStudent() async {
    try {
      final studentCollection = FirebasePathUtil.getUserCollection(UserRole.student);
      final studentSnapshot = await studentCollection.get();
      return studentSnapshot.docs.map((doc) => Student.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }
}
