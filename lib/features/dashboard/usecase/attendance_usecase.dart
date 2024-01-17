import 'package:dio/dio.dart';
import 'package:residency_desktop/features/dashboard/data/attendance_model.dart';
import 'package:residency_desktop/features/dashboard/repo/attendance_repo.dart';

class AttendanceUseCase extends AttendanceRepo{
  final Dio dio;

  AttendanceUseCase({required this.dio});
  @override
  Future<List<AttendanceModel>> getAttendance(String academicYear )async {
    try{
     // attendance here academicYear

      return [];
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