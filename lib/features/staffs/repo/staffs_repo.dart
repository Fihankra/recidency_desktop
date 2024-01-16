import 'package:residency_desktop/features/staffs/data/staff_model.dart';

abstract class StaffRepository {
  Future<List<StaffModel>> getStaffs();
  Future<(bool, StaffModel?, String?)> saveStaff(StaffModel assistant);
  Future<(bool, StaffModel?, String?)> updateStaff(Map<String, dynamic> map);
  Future<(bool, StaffModel?, String?)> markStaffDeleted(String id);
  // Future<StaffModel?> staffExists(String id);
  // Future<bool> importAssistants(String sourceYear);
}
