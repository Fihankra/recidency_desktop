import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residency_desktop/features/container/provider/main_provider.dart';
import 'package:residency_desktop/features/home/data/key_flow_model.dart';
import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';

final keyflowProvider = StateNotifierProvider.autoDispose<KeyFlowProvider, KeyFlowModel>(
    (ref) => KeyFlowProvider(
        (ref.watch(studentDataProvider), ref.watch(keyLogDataProvider))));

class KeyFlowProvider extends StateNotifier<KeyFlowModel> {
  KeyFlowProvider(this.data)
      : super(KeyFlowModel(students: [], lastKeyLog: null));

  final (List<StudentModel>, List<KeyLogModel>) data;

  void searchStudent(String value) {
    List<StudentModel> students = data.$1;
    List<KeyLogModel> keyLogs = data.$2;
    if (value.isNotEmpty) {
      var filteredStudents = students
          .where(
              (element) => element.room!.toLowerCase() == value.toLowerCase())
          .toList();
      //limit to onlu 4 students
      // if (filteredStudents.length > 4) {
      //   filteredStudents = filteredStudents.sublist(0, 4);
      // }
      state = state.copyWith(students: filteredStudents);

      var filteredKeyLogs = keyLogs
          .where((element) =>
              element.roomNumber!.toLowerCase() == value.toLowerCase())
          .toList();
      //get the most recent key log
      if (filteredKeyLogs.isNotEmpty) {
        filteredKeyLogs.sort((a, b) => b.createdAt!.compareTo((a.createdAt!)));
        state = state.copyWith(lastKeyLog: filteredKeyLogs.first);
      } else {
        state = state.copyWith(lastKeyLog: KeyLogModel());
      }
    } else {
      state = state.copyWith(students: [], lastKeyLog: KeyLogModel());
    }
  }
}
