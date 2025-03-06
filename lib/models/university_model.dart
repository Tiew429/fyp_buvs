import 'package:blockchain_university_voting_system/models/staff_model.dart';
import 'package:blockchain_university_voting_system/models/student_model.dart';

class University {
  final String _universityID;
  String _name;
  String _address;
  List<Staff> _staffs;
  List<Student> _students;

  University({
    required String universityID,
    required String name,
    required String address,
    List<Staff> staffs = const [],
    List<Student> students = const [],
  }) : _universityID = universityID,
       _name = name,
       _address = address,
       _staffs = staffs,
       _students = students;
  
  // getter
  String get universityID => _universityID;
  String get name => _name;
  String get address => _address;
  List<Staff> get staffs => _staffs;
  List<Student> get students => _students;

  // setter
  void setName(String name) => _name = name;
  void setAddress(String address) => _address = address;
  void addStaffToList(Staff staff) => _staffs.add(staff);
  void removeStaffFromList(Staff staff) => _staffs.remove(staff);
  void addStudentToList(Student student) => _students.add(student);
  void removeStudentFromList(Student student) => _students.remove(student);

}
