import 'package:dio/dio.dart';
import 'package:residency_desktop/features/dashboard/data/attendance_model.dart';
import 'package:residency_desktop/features/dashboard/repo/attendance_repo.dart';

class AttendanceUseCase extends AttendanceRepo {
  final Dio dio;

  AttendanceUseCase({required this.dio});
  @override
  Future<List<AttendanceModel>> getAttendance(String academicYear) async {
    try {
      var responds = await dio
          .get('attendance', queryParameters: {"academicYear": academicYear});
      if (responds.statusCode == 200) {
        if (responds.data['success'] == false) {
          return Future.value([]);
        } else {
          var data = responds.data['data'];
          final attendance = <AttendanceModel>[];
          for (var item in data) {
            attendance.add(AttendanceModel.fromMap(item));
          }
          return Future.value(attendance);
        }
      } else {
        return Future.value([]);
      }
    } catch (_) {
      return [];
    }
  }

  @override
  Future<AttendanceModel?> saveAttendance(AttendanceModel model)async {
    try {
      var responds =await dio.post('attendance', data: model.toMap());
       if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var data= responds.data['data'];
          if(data==null) return Future.value(null);
          return Future.value(AttendanceModel.fromMap(data));
        } else {
          return Future.value(null);
        }
      } else {
        return Future.value(null);
      }
      
    } catch (_) {
      return Future.value(null);
    }
   
  }
}
