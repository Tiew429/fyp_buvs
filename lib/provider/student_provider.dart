import 'package:blockchain_university_voting_system/models/student_model.dart';
import 'package:blockchain_university_voting_system/repository/student_repository.dart';
import 'package:flutter/widgets.dart';

class StudentProvider extends ChangeNotifier{

  final StudentRepository _studentRepository = StudentRepository();

  List<Student> _students = [];
  late Student? _selectedStudent;

  // getter
  List<Student> get students => _students;
  Student? get selectedStudent => _selectedStudent;

  // setter
  void addStudent(Student student) {
    students.add(student);
  }

  void removeStudent(Student student) {
    students.remove(student);
  }

  void clearStudents() {
    students.clear();
  }

  void setSelectedStudent(Student student) {
    _selectedStudent = student;
    notifyListeners();
  }

  void clearSelectedStudent() {
    _selectedStudent = null;
    notifyListeners();
  }

  // methods
  
  Future<void> fetchStudents() async {
    _students = await _studentRepository.getStudents();
    notifyListeners();
  }
  
}
