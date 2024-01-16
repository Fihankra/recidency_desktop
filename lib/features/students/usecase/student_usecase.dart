import 'package:dio/dio.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/features/students/repo/student_repo.dart';

class StudentUsecase extends StudentRepository {
  final Dio dio;

  StudentUsecase({required this.dio});

  @override
  Future<(bool, StudentModel?, String?)> addStudent(
      StudentModel student) async {
    try {
      var responds = await dio.post('students', data: student.toMap());
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var user = UserModel.fromMap(responds.data['data']);
          return Future.value((true, StudentModel.fromUsers(user), null));
        } else {
          return Future.value(
              (false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (error) {
      return Future.value((false, null, error.toString()));
    }
  }

  @override
  Future<List<StudentModel>> getStudents(String academicYear) async {
    try {
      var responds = await dio
          .get('students', queryParameters: {"academicYear": academicYear});
      if (responds.statusCode == 200) {
        if (responds.data['success'] == false) {
          return Future.value([]);
        } else {
          var data = responds.data['data'];
          final students = <StudentModel>[];
          for (var item in data) {
            var user = UserModel.fromMap(item);
            students.add(StudentModel.fromUsers(user));
          }

          return Future.value(students);
        }
      } else {
        return Future.value([]);
      }
    } catch (_) {
      return [];
    }
  }

  @override
  Future<(bool, StudentModel?, String?)> updateStudent(
      Map<String, dynamic> map) async {
    try {
      var responds = await dio.put('students/${map['id']}', data: map);
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var user = UserModel.fromMap(responds.data['data']);
          return Future.value((true, StudentModel.fromUsers(user), null));
        } else {
          return Future.value(
              (false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (_) {
      return Future.value((false, null, _.toString()));
    }
  }

  @override
  Future<(bool, StudentModel?, String?)> deleteStudent(
      String id, String academicYear) async {
    try {
      var map = {"isDeleted": true, "academicYear": academicYear};
      var responds = await dio.put('students/${map['id']}', data: map);
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var user = UserModel.fromMap(responds.data['data']);
          return Future.value((true, StudentModel.fromUsers(user), null));
        } else {
          return Future.value(
              (false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (error) {
      return Future.value((false, null, error.toString()));
    }
  }

  @override
  Future<StudentModel?> getStudent(String id) async {
    try {
      var responds = await dio.get('students/$id');
      if (responds.statusCode == 200) {
        if (responds.data['success'] == false) {
          return Future.value(null);
        } else {
          var data = responds.data['data'];
          var user = UserModel.fromMap(data);
          return Future.value(StudentModel.fromUsers(user));
        }
      } else {
        return Future.value(null);
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Future<(bool, StudentModel?, String?)> forceCreateStudent(
      StudentModel state) async {
    try {
      var responds = await dio.post('students/force', data: state.toMap());
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var user = UserModel.fromMap(responds.data['data']);
          return Future.value((true, StudentModel.fromUsers(user), null));
        } else {
          return Future.value(
              (false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (_) {
      return Future.value((false, null, _.toString()));
    }
  }

  @override
  Future<(bool, StudentModel?, String?)> forceUpdateStudent(
      Map<String, dynamic> map) async {
    try {
      var responds = await dio.put('students/force/${map['id']}', data: map);
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var user = UserModel.fromMap(responds.data['data']);
          return Future.value((true, StudentModel.fromUsers(user), null));
        } else {
          return Future.value(
              (false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (_) {
      return Future.value((false, null, _.toString()));
    }
  }
}
