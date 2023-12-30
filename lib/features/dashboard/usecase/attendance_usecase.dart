import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/features/dashboard/data/attendance_model.dart';
import 'package:residency_desktop/features/dashboard/repo/attendance_repo.dart';

class AttendanceUseCase extends AttendanceRepo{
  final Db db;

  AttendanceUseCase({required this.db});
  @override
  Future<List<AttendanceModel>> getAttendance(String academicYear )async {
    try{
     // attendance here academicYear
      var data = await db.collection('attendance').find(where.eq('academicYear', academicYear)).toList();
      return data.map((e) => AttendanceModel.fromMap(e)).toList();
    }catch(_){
      return [];
    }
  }

  @override
  Future<void> saveAttendance(AttendanceModel model) {
    // TODO: implement saveAttendance
    throw UnimplementedError();
  }

}