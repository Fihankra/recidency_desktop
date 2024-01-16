import 'package:dio/dio.dart';
import 'package:residency_desktop/features/staffs/data/staff_model.dart';
import 'package:residency_desktop/features/staffs/repo/staffs_repo.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';

class StaffUsecase extends StaffRepository {
  final Dio dio;

  StaffUsecase({required this.dio});
  @override
  Future<List<StaffModel>> getStaffs() async {
    try {
      var responds = await dio.get('staffs/');
      if (responds.statusCode == 200) {
        if (responds.data['success'] == false) {
          return Future.value([]);
        } else {
          var data = responds.data['data'];
          final staffs = <StaffModel>[];
          for (var item in data) {
            var user = UserModel.fromMap(item);
            staffs.add(StaffModel.fromUsers(user));
          }

          return Future.value(staffs);
        }
      } else {
        return Future.value([]);
      }
    } catch (e) {
      return Future.value([]);
    }
  }

  @override
  Future<(bool, StaffModel?,String?)> markStaffDeleted(
    String id,
  ) async {
    try {
      var map = {"isDeleted": true};
      var responds = await dio.put('staffs/$id', data: map);
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          if (responds.data['data'] == null) {
            return Future.value((false, null, responds.data['message'].toString()));
          }
          var user = UserModel.fromMap(responds.data['data']);

          return Future.value((true, StaffModel.fromUsers(user), null));
        } else {
          return Future.value((false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (e) {
      return Future.value((false, null, e.toString()));
    }
  }

  @override
  Future<(bool, StaffModel?, String?)> saveStaff(StaffModel assistant) async {
    try {
      var responds = await dio.post('staffs', data: assistant.toMap());
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          if (responds.data['data'] == null) {
            return Future.value((false, null, responds.data['message'].toString()));
          }
          var user = UserModel.fromMap(responds.data['data']);
          return Future.value((true, StaffModel.fromUsers(user), null));
        } else {
          return Future.value((false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (e) {
      return Future.value((false, null, e.toString()));
    }
  }

  @override
  Future<(bool, StaffModel?, String?)> updateStaff(
      Map<String, dynamic> map) async {
    try {
      var id = map['id'];
      var responds = await dio.put('staffs/$id', data: map);
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          if (responds.data['data'] == null) {
            return Future.value((false, null, responds.data['message'].toString()));
          }
          var user = UserModel.fromMap(responds.data['data']);
          return Future.value((true, StaffModel.fromUsers(user), null));
        } else {
          return Future.value((false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (e) {
      return Future.value((false, null, e.toString()));
    }
  }

}
