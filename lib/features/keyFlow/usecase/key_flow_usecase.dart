import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/keyFlow/repo/key_flow_repo.dart';

class KeyFlowUseCase extends KeyFlowRepository{
  final Db db;

  KeyFlowUseCase({required this.db});

  @override
  Future<(bool, String)> addKeyFlow(KeyLogModel keyFlow) {
    try{
      var coll = db.collection('keyLogs');
      return coll.insert(keyFlow.toMap()).then((value) => (true, 'Log added successfully'));
      }catch(_){
       
        return Future.value((false, 'Unable to add key to log'));
      }
  }

  @override
  Future<List<KeyLogModel>> getKeyFlows(String academicYear)async {
    try{
      var coll = db.collection('keyLogs');
      var data = await coll.find(where.eq('academicYear', academicYear)).toList();
      var keyFlows = data.map((e) => KeyLogModel.fromMap(e)).toList();
      return keyFlows;
    }catch(_){
      return [];
    }
    
  }
}