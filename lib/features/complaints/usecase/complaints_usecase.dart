import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/features/complaints/data/complaints.model.dart';
import 'package:residency_desktop/features/complaints/repo/complaints_repo.dart';

class ComplaintsUsecase extends ComplaintsRepository {
  final Db db;

  ComplaintsUsecase({required this.db});
  @override
  Future<(bool, String?)> addComplaint(ComplaintsModel complaint) {
    // TODO: implement addComplaint
    throw UnimplementedError();
  }

  @override
  Future<List<ComplaintsModel>> getComplaints(String academicYear) async {
    try {
      var data = await db
          .collection('complaints')
          .find(where.eq('academicYear', academicYear))
          .toList();
      return data.map((e) => ComplaintsModel.fromMap(e)).toList();
    } catch (_) {

      return [];
    }
  }

  @override
  Future<(bool, String)> updateComplaint(Map<String, dynamic> data) {
    // TODO: implement updateComplaint
    throw UnimplementedError();
  }
}
