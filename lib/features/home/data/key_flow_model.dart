import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';

class KeyFlowModel {
  List<StudentModel> students;
  KeyLogModel? lastKeyLog;
  KeyFlowModel({
    required this.students,
     this.lastKeyLog,
  });

  KeyFlowModel copyWith({
    List<StudentModel>? students,
    KeyLogModel? lastKeyLog,
  }) {
    return KeyFlowModel(
      students: students ?? this.students,
      lastKeyLog: lastKeyLog ?? this.lastKeyLog,
    );
  }
}
