import 'package:residency_desktop/features/students/data/students_model.dart';

abstract class StudentRepository {
  Future<List<StudentModel>> getStudents(String academicYear);
  Future<(bool, String)> addStudent(StudentModel student);
  Future<(bool, String)> updateStudent(Map<String, dynamic> map);
  //get student by id
  Future<StudentModel?> getStudent(String id);
  Future<List<StudentModel>> getStudentsByRoom(String room, String academicYear);
  Future<(bool, String)> deleteStudent(String id, String academicYear);
  //mark student deleted
  
}