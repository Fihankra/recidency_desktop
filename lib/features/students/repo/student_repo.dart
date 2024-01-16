import 'package:residency_desktop/features/students/data/students_model.dart';

abstract class StudentRepository {
  Future<List<StudentModel?>> getStudents(String academicYear);
  Future<(bool, StudentModel?, String?)> addStudent(StudentModel student);
  Future<(bool, StudentModel?, String?)> updateStudent(
      Map<String, dynamic> map);
  //get student by id
  Future<StudentModel?> getStudent(String id);
  Future<(bool, StudentModel?, String?)> deleteStudent(
      String id, String academicYear);
  //mark student deleted
  Future<(bool, StudentModel?, String?)> forceCreateStudent(StudentModel state);
  Future<(bool, StudentModel?, String?)> forceUpdateStudent(
      Map<String, dynamic> map);
}
