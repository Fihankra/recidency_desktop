import 'package:dio/dio.dart';
import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/keyFlow/repo/key_flow_repo.dart';

class KeyFlowUseCase extends KeyFlowRepository {
  final Dio dio;

  KeyFlowUseCase({required this.dio});

  @override
  Future<(bool, KeyLogModel?, String?)> addKeyFlow(KeyLogModel keyFlow)async {
    try {
      var responds =await dio.post('key-logs', data: keyFlow.toMap());
       if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var data= responds.data['data'];
          if(data==null) return Future.value((false, null, 'data is null'));
          return Future.value((true, KeyLogModel.fromMap(data), null));
        } else {
          return Future.value(
              (false, null, responds.data['message'].toString()));
        }
      } else {
        return Future.value((false, null, responds.data['message'].toString()));
      }
      
    } catch (_) {
      return Future.value((false, null, _.toString()));
    }
  }

  @override
  Future<List<KeyLogModel>> getKeyFlows(String academicYear) async {
    try {
      var responds = await dio
          .get('key-logs', queryParameters: {"academicYear": academicYear});
      if (responds.statusCode == 200) {
        if (responds.data['success'] == false) {
          return Future.value([]);
        } else {
          var data = responds.data['data'];
          final keyFlows = <KeyLogModel>[];
          for (var item in data) {
            keyFlows.add(KeyLogModel.fromMap(item));
          }

          return Future.value(keyFlows);
        }
      } else {
        return Future.value([]);
      }
     
    } catch (_) {
      return [];
    }
  }
}
