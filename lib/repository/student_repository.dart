import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRepository {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Student>> getStudents() async {
    // get the students from firestore
    final students = await getStudentPath().get();
    return students.docs.map((doc) => Student.fromJson(doc.data())).toList();
  }

  CollectionReference<Map<String, dynamic>> getStudentPath() {
    return _firestore.collection("users").doc("student").collection("student");
  }

}
