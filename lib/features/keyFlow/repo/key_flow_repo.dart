import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';

abstract class KeyFlowRepository {
  Future<List<KeyLogModel>> getKeyFlows(String academicYear);
  Future<(bool, KeyLogModel?, String?)> addKeyFlow(KeyLogModel keyFlow);

}