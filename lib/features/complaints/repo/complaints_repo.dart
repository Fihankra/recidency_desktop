import 'package:residency_desktop/features/complaints/data/complaints.model.dart';

abstract class ComplaintsRepository{
  Future<List<ComplaintsModel>> getComplaints(String academicYear);
  Future<(bool,String?)> addComplaint(ComplaintsModel complaint);
  Future<(bool,String)> updateComplaint(Map<String, dynamic> data);

}