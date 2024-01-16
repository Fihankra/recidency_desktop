import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/complaints/data/complaints.model.dart';
import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/messages/data/message_model.dart';
import 'package:residency_desktop/features/staffs/data/staff_model.dart';
import 'package:residency_desktop/features/staffs/usecase/staff_usecases.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import '../../auth/provider/mysefl_provider.dart';
import '../../complaints/usecase/complaints_usecase.dart';
import '../../keyFlow/usecase/key_flow_usecase.dart';
import '../../messages/usecases/message_usecase.dart';
import '../../settings/provider/settings_provider.dart';
import '../../students/usecase/student_usecase.dart';

final mainProvider = FutureProvider<void>((ref) async {
  var dio = ref.watch(serverProvider);
  var me = ref.watch(myselfProvider);
  var settings = ref.watch(settingsProvider);
  //? get all staffs============================================================
  // var staff = await StaffModel.dummyDtata();
  // for(var data in staff){
  //   await StaffUsecase(dio: dio!).saveStaff(data);
  // }
  var staffs = await StaffUsecase(dio: dio!).getStaffs();
  //remove the current user from the list
  staffs.removeWhere((element) => element.id == me.id);
  staffs.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  ref.read(staffDataProvider.notifier).setStaffs(staffs);
  //!===========================================================================
  //? get all students
  // var dummy = await StudentModel.dummyDtata();
  // for (var student in dummy) {
  //   await StudentUsecase(dio: dio).addStudent(student);
  // }
  // print('done');
  var students =
      await StudentUsecase(dio: dio).getStudents(settings.academicYear!);
  students.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  ref.read(studentDataProvider.notifier).setStudents(students);
  //!===========================================================================

  //? get all complaints
  var complaints =
      await ComplaintsUsecase(dio: dio).getComplaints(settings.academicYear!);
  complaints.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  ref.read(complaintDataProvider.notifier).setComplaints(complaints);
  //? get all massages
  var messages = await MessageUsecase(dio: dio).getMessages(settings.academicYear!);
  messages.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  //? get all keyLogs
  var keyLogs =
      await KeyFlowUseCase(dio: dio).getKeyFlows(settings.academicYear!);
  keyLogs.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  ref.read(keyLogDataProvider.notifier).setLogs(keyLogs);
});

final staffDataProvider =
    StateNotifierProvider<StaffDataProvider, List<StaffModel>>(
        (ref) => StaffDataProvider());

final studentDataProvider =
    StateNotifierProvider<StudentDataProvider, List<StudentModel>>(
        (ref) => StudentDataProvider());

final complaintDataProvider =
    StateNotifierProvider<ComplaintsProvider, List<ComplaintsModel>>(
        (ref) => ComplaintsProvider());
final messageDataProvider= StateNotifierProvider<MessageProvider,List<MessageModel>>((ref) => MessageProvider());
final keyLogDataProvider =
    StateNotifierProvider<KeyLogsProvider, List<KeyLogModel>>(
        (ref) => KeyLogsProvider());

class StaffDataProvider extends StateNotifier<List<StaffModel>> {
  StaffDataProvider() : super([]);
  void setStaffs(List<StaffModel> staffs) {
    state = staffs;
  }

  void addStaff(StaffModel staff) {
    state = [...state, staff];
  }

  void updateStaff(StaffModel staff) {
    state = [
      for (var item in state)
        if (item.id == staff.id) staff else item
    ];
  }

  void deleteStaff(String id) {
    state = [
      for (var item in state)
        if (item.id != id) item
    ];
  }
}

class StudentDataProvider extends StateNotifier<List<StudentModel>> {
  StudentDataProvider() : super([]);
  void setStudents(List<StudentModel> students) {
    state = students;
  }

  void addStudent(StudentModel student) {
    state = [...state, student];
  }

  void updateStudent(StudentModel student) {
    state = [
      for (var item in state)
        if (item.id == student.id) student else item
    ];
  }

  void deleteStudent(String id) {
    state = [
      for (var item in state)
        if (item.id != id) item
    ];
  }
}

class KeyLogsProvider extends StateNotifier<List<KeyLogModel>> {
  KeyLogsProvider() : super([]);
  void setLogs(List<KeyLogModel> logs) {
    state = logs;
  }

  void addLog(KeyLogModel log) {
    state = [...state, log];
  }
}

class ComplaintsProvider extends StateNotifier<List<ComplaintsModel>> {
  ComplaintsProvider() : super([]);
  void setComplaints(List<ComplaintsModel> complaints) {
    state = complaints;
  }

  void addComplaint(ComplaintsModel complaint) {
    state = [...state, complaint];
  }

  void updateComplaint(ComplaintsModel complaint) {
    state = [
      for (var item in state)
        if (item.id == complaint.id) complaint else item
    ];
  }

  void deleteComplaint(String id) {
    state = [
      for (var item in state)
        if (item.id != id) item
    ];
  }
}


class MessageProvider extends StateNotifier<List<MessageModel>>{
  MessageProvider():super([]);
  void setMessages(List<MessageModel> messages){
    state = messages;
  }
  void addMessage(MessageModel message){
    state = [...state,message];
  }
  void updateMessage(MessageModel message){
    state = [
      for(var item in state)
      if(item.id == message.id) message else item
    ];
  }
  void deleteMessage(String id){
    state = [
      for(var item in state)
      if(item.id != id) item
    ];
  }

}