import 'package:residency_desktop/features/dashboard/data/attendance_model.dart';

abstract class AttendanceRepo {
  Future<List<AttendanceModel>> getAttendance(String academicYear);
  // save attendance
  Future<AttendanceModel?> saveAttendance(AttendanceModel model);

}