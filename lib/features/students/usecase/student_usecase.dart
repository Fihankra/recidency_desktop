import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/features/students/repo/student_repo.dart';

class StudentUsecase extends StudentRepository {
  final Db db;

  StudentUsecase({required this.db});

  @override
  Future<(bool, String)> addStudent(StudentModel student) async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      await coll.insert(UserModel.fromStudent(student).toMap());
      return Future.value((true, 'Student added successfully'));
    } catch (_) {
      return Future.value((false, 'Error adding student'));
    }
  }

  @override
  Future<List<StudentModel>> getStudents(String academicYear) async {
    try {
      var coll = db.collection('users');
      //find where academicYear == academicYear and role == student
      var data = await coll
          .find(where.eq('academicYear', academicYear).eq('role', 'student').eq('isDeleted', false))
          .toList();
      var students = data
          .map((e) => StudentModel.fromUsers(UserModel.fromMap(e)))
          .toList();
      return students;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<(bool, String)> updateStudent(Map<String, dynamic> map) async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      await coll.update(where.eq('id', map['id']), map);
      return Future.value((true, 'Student updated successfully'));
    } catch (_) {
      return Future.value((false, 'Error updating student'));
    }
  }

  @override
  Future<(bool, String)> deleteStudent(String id, String academicYear) {
    try {
      if (db.state != State.open) {
        db.open();
      }
      var coll = db.collection('users');
      coll.update(
          where.eq('id', id), modify.set('isDeleted', true).set('image', null));
      return Future.value((true, 'Student deleted successfully'));
    } catch (_) {
      return Future.value((false, 'Error deleting student'));
    }
  }

  @override
  Future<StudentModel?> getStudent(String id) async {
    try {
       if (db.state != State.open) {
        db.open();
      }
      var coll = db.collection('users');
      var data = await coll.findOne(where.eq('id', id));
      return data != null
          ? StudentModel.fromUsers(UserModel.fromMap(data))
          : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> dummyDelete(String academicYear) async {
    try {
       if (db.state != State.open) {
        db.open();
      }
      var coll = db.collection('users');
      coll.deleteMany({'role': 'student', 'academicYear': academicYear});
    } catch (_) {}
  }
  
  @override
  Future<List<StudentModel>> getStudentsByRoom(String room, String academicYear) {
    try{
       if (db.state != State.open) {
        db.open();
      }
      var coll = db.collection('users');
      var data = coll.find(where.eq('room', room).eq('role', 'student').eq('isDeleted', false).eq('academicYear', academicYear)).toList();
      return data.then((value) => value.map((e) => StudentModel.fromUsers(UserModel.fromMap(e))).toList());
    }catch(_){
      return Future.value([]);
    }
    
  }


}
