import 'package:residency_desktop/features/staffs/data/staff_model.dart';

abstract class StaffRepository {
  Future<List<StaffModel>> getStaffs();
  Future<(Exception?, String?)> saveStaff(StaffModel assistant);
  Future<(Exception?, String?)> updateStaff(Map<String, dynamic> map);
  Future<(Exception?, String?)> markStaffDeleted(String id);
  Future<StaffModel?> staffExists(String id);
  Future<bool> importAssistants(String sourceYear);
}
