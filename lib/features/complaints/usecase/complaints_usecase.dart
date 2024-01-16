import 'package:dio/dio.dart';
import 'package:residency_desktop/features/complaints/data/complaints.model.dart';
import 'package:residency_desktop/features/complaints/repo/complaints_repo.dart';

class ComplaintsUsecase extends ComplaintsRepository {
  final Dio dio;

  ComplaintsUsecase({required this.dio});
  @override
  Future<(bool, ComplaintsModel?, String?)> addComplaint(
      ComplaintsModel complaint) async {
    try {
      var responds = await dio.post('/complaints', data: complaint.toMap());
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var data = ComplaintsModel.fromMap(responds.data['data']);
          return Future.value((true, data, null));
        } else {
          return Future.value(
              (false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (e) {
      return (false, null, e.toString());
    }
  }

  @override
  Future<List<ComplaintsModel>> getComplaints(String academicYear) async {
    try {
      var responds = await dio
          .get('/complaints', queryParameters: {"academicYear": academicYear});
      if (responds.statusCode == 200) {
        if (responds.data['success'] == false) {
          return Future.value([]);
        } else {
          var data = responds.data['data'];
          final complaints = <ComplaintsModel>[];
          for (var item in data) {
            complaints.add(ComplaintsModel.fromMap(item));
          }
          return Future.value(complaints);
        }
      } else {
        return Future.value([]);
      }
    } catch (_) {
      return [];
    }
  }

  @override
  Future<(bool, ComplaintsModel?, String)> updateComplaint(
      Map<String, dynamic> data) async {
    try {
      var responds = await dio.put('/complaints/${data['id']}', data: data);
      if (responds.statusCode == 200) {
        if (responds.data['success'] == false) {
          return Future.value(
              (false, null, responds.data['message'].toString()));
        } else {
          var data = responds.data['data'];
          return Future.value((
            true,
            ComplaintsModel.fromMap(data),
            'Complaint updated successfully'
          ));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
    } catch (e) {
      return (false, null, e.toString());
    }
  }
}
