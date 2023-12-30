import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/features/staffs/data/staff_model.dart';
import 'package:residency_desktop/features/staffs/repo/staffs_repo.dart';
import 'package:residency_desktop/features/core/data/user_model.dart';

class StaffUsecase extends StaffRepository {
  final Db db;

  StaffUsecase({required this.db});
  @override
  Future<List<StaffModel>> getStaffs() async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      List<Map<String, dynamic>> data =
          await coll.find({'role': 'assistant', 'isDeleted': false}).toList();
      return Future.value(
          data.map((e) => StaffModel.fromUsers(UserModel.fromMap(e))).toList());
    } catch (e) {
      return Future.value([]);
    }
  }

  @override
  Future<(Exception?, String?)> markStaffDeleted(
    String id,
  ) async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      await coll.update({'id': id}, {'isDeleted': true});
      return Future.value((null, 'Staff deleted successfully'));
    } catch (e) {
      return Future.value((Exception(e.toString()), null));
    }
  }

  @override
  Future<(Exception?, String?)> saveStaff(StaffModel assistant) async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      await coll.insert(UserModel.fromAssistant(assistant).toMap());
      return Future.value((null, 'Staff created successfully'));
    } catch (e) {
      return Future.value((Exception(e.toString()), null));
    }
  }

  @override
  Future<(Exception?, String?)> updateStaff(Map<String, dynamic> map) async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      await coll.update({'id': map['id']}, map);

      return Future.value((null, 'Staff updated successfully'));
    } catch (e) {
      return Future.value((Exception(e.toString()), null));
    }
  }

  @override
  Future<StaffModel?> staffExists(String id) async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var data = await db.collection('users').findOne({'id': id});
      if (data != null) {
        return Future.value(StaffModel.fromUsers(UserModel.fromMap(data)));
      } else {
        return Future.value(null);
      }
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> importAssistants(String sourceYear) async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('users');
      await coll.updateMany({'role': "assistant", 'academicYear': sourceYear},
          modify.set('academicYear', ''));
      return Future.value(true);
    } catch (_) {
      return Future.value(false);
    }
  }
}
