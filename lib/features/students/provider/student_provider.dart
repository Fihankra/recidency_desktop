import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/data/table_model.dart';
import 'package:residency_desktop/core/functions/export/export_data.dart';
import 'package:residency_desktop/core/provider/image_provider.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:residency_desktop/features/students/usecase/student_usecase.dart';
import 'package:residency_desktop/utils/application_utils.dart';
import '../data/students_model.dart';

final studentFutureProvider = FutureProvider<List<StudentModel>>((
  ref,
) async {
  var db = ref.watch(dbProvider);
  var settings = ref.watch(settingsProvider);
  // var students = await StudentModel.dummyDtata();
  // for (var student in students) {
  //   await StudentUsecase(db: db!).addStudent(student);
  // }

  var data = await StudentUsecase(db: db!).getStudents(settings.academicYear!);
  // //delete all images
  // data.forEach((element) async {
  //   var file = File(element.image!);
  //   if (file.existsSync()) {
  //     await file.delete();
  //   }
  // });
  // await StudentUsecase(db: db).dummyDelete(settings.academicYear!);
  // data = await StudentUsecase(db: db).getStudents(settings.academicYear!);
  data.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  return data;
});

final studentProvider = StateNotifierProvider.family<StudentNotifier,
    TableModel<StudentModel>, List<StudentModel>>((ref, data) {
  return StudentNotifier(data);
});

class StudentNotifier extends StateNotifier<TableModel<StudentModel>> {
  StudentNotifier(this.items)
      : super(TableModel<StudentModel>(
          currentPage: 0,
          pageSize: 10,
          selectedRows: [],
          pages: [],
          currentPageItems: [],
          items: items,
          hasNextPage: false,
          hasPreviousPage: false,
        )) {
    init();
  }
  final List<StudentModel> items;

  void init() {
    List<List<StudentModel>> pages = [];
    state = state.copyWith(
        items: items,
        selectedRows: [],
        currentPage: 0,
        pages: pages,
        currentPageItems: [],
        hasNextPage: false,
        hasPreviousPage: false);
    if (items.isNotEmpty) {
      var pagesCount = (items.length / state.pageSize).ceil();
      for (var i = 0; i < pagesCount; i++) {
        var page = items.skip(i * state.pageSize).take(state.pageSize).toList();

        pages.add(page);
        state = state.copyWith(pages: pages);
      }
    } else {
      pages.add([]);
      state = state.copyWith(pages: pages);
    }
    state = state.copyWith(
        currentPageItems: state.pages[state.currentPage],
        hasNextPage: state.currentPage < state.pages.length - 1,
        hasPreviousPage: state.currentPage > 0);
  }

  void onPageSizeChange(int newValue) {
    state = state.copyWith(pageSize: newValue);
    init();
  }

  void selectRow(StudentModel row) {
    state = state
        .copyWith(selectedRows: [...state.selectedRows, row], items: items);
  }

  void unselectRow(StudentModel row) {
    state = state.copyWith(
        selectedRows: [...state.selectedRows..remove(row)], items: items);
  }

  void nextPage() {
    if (state.hasNextPage && state.currentPage < state.pages.length - 1) {
      state = state.copyWith(currentPage: state.currentPage + 1);
      state = state.copyWith(currentPageItems: state.pages[state.currentPage]);
      state = state.copyWith(
        hasNextPage: state.currentPage < state.pages.length - 1,
      );
      state = state.copyWith(hasPreviousPage: state.currentPage > 0);
    }
  }

  void previousPage() {
    if (state.hasPreviousPage && state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
      state = state.copyWith(currentPageItems: state.pages[state.currentPage]);
      state = state.copyWith(hasPreviousPage: state.currentPage > 0);
      state = state.copyWith(
        hasNextPage: state.currentPage < state.pages.length - 1,
      );
    }
  }

  void search(String query) {
    var newItems = query.isNotEmpty
        ? items.where((element) {
            return element.firstname!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                element.surname!.toLowerCase().contains(query.toLowerCase()) ||
                element.department!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                element.block!.toLowerCase().contains(query.toLowerCase()) ||
                element.room!.toLowerCase().contains(query.toLowerCase()) ||
                element.level!.toLowerCase().contains(query.toLowerCase()) ||
                element.id!.toLowerCase().contains(query.toLowerCase()) ||
                element.phone!.toLowerCase().contains(query.toLowerCase());
          }).toList()
        : items;

    List<List<StudentModel>> pages = [];
    state = state.copyWith(
        items: newItems,
        selectedRows: [],
        currentPage: 0,
        pages: pages,
        currentPageItems: [],
        hasNextPage: false,
        hasPreviousPage: false);
    if (newItems.isNotEmpty) {
      var pagesCount = (newItems.length / state.pageSize).ceil();
      for (var i = 0; i < pagesCount; i++) {
        var page =
            newItems.skip(i * state.pageSize).take(state.pageSize).toList();

        pages.add(page);
        state = state.copyWith(pages: pages);
      }
    } else {
      pages.add([]);
      state = state.copyWith(pages: pages);
    }
    state = state.copyWith(
        currentPageItems: state.pages[state.currentPage],
        hasNextPage: state.currentPage < state.pages.length - 1,
        hasPreviousPage: state.currentPage > 0);
  }

  void exportStudent(
      {required String dataLength, required String format}) async {
    CustomDialog.showLoading(message: 'Exporting data to excel.......');

    var data = ExportData<StudentModel>(
        fileName: dataLength == 'all'
            ? 'all_students.$format'
            : 'selected_students.$format',
        data: dataLength != 'all' ? state.currentPageItems : items,
        headings: (item) => item.excelHeadings(),
        cellItems: (item) => item.excelData(item));
    if (format == 'pdf') {
      var (exception, path) = await data.toPdf();
      if (exception != null) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: exception.toString());
      } else {
        CustomDialog.dismiss();
        CustomDialog.showSuccess(message: 'Data exported successfully');
        OpenAppFile.open(path!);
      }
    } else {
      var (exception, path) = await data.toExcel();
      if (exception != null) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: exception.toString());
      } else {
        CustomDialog.dismiss();
        CustomDialog.showSuccess(message: 'Data exported successfully');
        OpenAppFile.open(path!);
      }
    }
  }
}

final newstudentProvider =
    StateNotifierProvider<NewStudentNotifier, StudentModel>(
        (ref) => NewStudentNotifier());

class NewStudentNotifier extends StateNotifier<StudentModel> {
  NewStudentNotifier() : super(StudentModel());

  void setStudentId(String s) {
    state = state.copyWith(id: () => s);
  }

  void setGender(param0) {
    state = state.copyWith(gender: () => param0.toString());
  }

  void setFirstName(String s) {
    state = state.copyWith(firstname: () => s);
  }

  void setSurname(String s) {
    state = state.copyWith(surname: () => s);
  }

  void setDepartment(param0) {
    state = state.copyWith(department: () => param0.toString());
  }

  void setPhone(String s) {
    state = state.copyWith(phone: () => s);
  }

  void setBlock(param0) {
    state = state.copyWith(block: () => param0.toString());
  }

  void setRoom(String s) {
    state = state.copyWith(room: () => s);
  }

  void createStudent(
      {required BuildContext context,
      required WidgetRef ref,
      required GlobalKey<FormState> form}) async {
    CustomDialog.showLoading(message: 'Creating student........');
    var db = ref.watch(dbProvider);
    var settings = ref.watch(settingsProvider);
    // check students with same room numbers
    var prefix = state.block!.toLowerCase()=='annex'?'AA':state.block!.toUpperCase().trim().substring(state.block!.toUpperCase().trim().length-1);
    state= state.copyWith(room: ()=>'${prefix.toUpperCase()}${state.room!.trim()}');
    var students = await StudentUsecase(db: db!).getStudentsByRoom(state.room!, settings.academicYear!);
    var withoutThis = students.where((element) => element.id != state.id).toList();
    if(withoutThis.length>=4){
      CustomDialog.dismiss();
      CustomDialog.showError(message: 'Room ${state.room} already has 4 students, please choose another room');
      return;
    }
    //check if student id already exist
    var existenStudent = await StudentUsecase(db: db!).getStudent(state.id!);
    if (existenStudent != null) {
      if (existenStudent.academicYear == settings.academicYear) {
        CustomDialog.dismiss();
        CustomDialog.showError(
            message:
                'Student with id ${state.id} already exist in ${settings.academicYear} academic year');
      } else {
        CustomDialog.dismiss();
        // ask to change academic year
        CustomDialog.showInfo(
            message:
                'Student with id ${state.id} already exist in ${existenStudent.academicYear} academic year. Do you want to update the student academic year to ${settings.academicYear}?',
            buttonText: 'Yes|Update',
            onPressed: () {
              updateAcademicYear(ref, form);
            });
      }
    } else {
     var image = ref.watch(imageProvider).image;
      if (image != null) {
        var folder = await AppUtils.createFolderInAppDocDir('students');
        var filename = state.id!.replaceAll(' ', '_');
        var path = '$folder/$filename.jpg';
        var file = File(image.path);

        try {
          //delete old image
          var oldImage = File(state.image!);
          if (oldImage.existsSync()) {
            await oldImage.delete();
          }
          await file.rename(path);
          state = state.copyWith(
            image: () => path,
          );
        } on FileSystemException catch (_) {
          // if rename fails, copy the source file and then delete it
          final newFile = await file.copy(path);
          state = state.copyWith(
            image: () => newFile.path,
          );
          if (ref.watch(imageProvider).isCaptured) {
            await file.delete();
          }
        }
      } 
      state = state.copyWith(
        createdAt: () => DateTime.now().millisecondsSinceEpoch,
        academicYear: () => settings.academicYear,
        password: () => AppUtils.hashPassword(state.id!),
      );
      var (status, message) = await StudentUsecase(db: db).addStudent(state);
      if (!status) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: message);
      } else {
        state = StudentModel();
        form.currentState!.reset();
        ref.invalidate(studentFutureProvider);
        ref.invalidate(imageProvider);
        CustomDialog.dismiss();
        CustomDialog.showSuccess(message: message);
      }
    }
  }

  void updateAcademicYear(WidgetRef ref, GlobalKey<FormState> form) async {
    CustomDialog.dismiss();
    CustomDialog.showLoading(message: 'Updating student .......');
    var db = ref.watch(dbProvider);
    var settings = ref.watch(settingsProvider);
   var image = ref.watch(imageProvider).image;
    if (image != null) {
      var folder = await AppUtils.createFolderInAppDocDir('students');
      var filename = state.id!.replaceAll(' ', '_');
      var path = '$folder/$filename.jpg';
      var file = File(image.path);

      try {
        //delete old image
        var oldImage = File(state.image!);
        if (oldImage.existsSync()) {
          await oldImage.delete();
        }
        await file.rename(path);
        state = state.copyWith(
          image: () => path,
        );
      } on FileSystemException catch (_) {
        // if rename fails, copy the source file and then delete it
        final newFile = await file.copy(path);
        state = state.copyWith(
          image: () => newFile.path,
        );
        if (ref.watch(imageProvider).isCaptured) {
          await file.delete();
        }
      }
    }
    state = state.copyWith(
      createdAt: () => DateTime.now().millisecondsSinceEpoch,
      academicYear: () => settings.academicYear,
      isDeleted: false,
      password: () => AppUtils.hashPassword(state.id!),
    );
    var (status, message) =
        await StudentUsecase(db: db!).updateStudent(state.toMap());
    if (status) {
      state = StudentModel();
      ref.invalidate(studentFutureProvider);
      ref.invalidate(imageProvider);
      form.currentState!.reset();
      CustomDialog.dismiss();
      CustomDialog.showSuccess(message: message);
    } else {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message);
    }
  }

  void setLevel(param0) {
    state = state.copyWith(level: () => param0.toString());
  }
}

final selectedStudentProvider =
    StateNotifierProvider<SelectedStudentNotifier, StudentModel>((
  ref,
) =>
        SelectedStudentNotifier());

class SelectedStudentNotifier extends StateNotifier<StudentModel> {
  SelectedStudentNotifier() : super(StudentModel());

  void setGender(param0) {
    state = state.copyWith(
      gender: () => param0.toString(),
    );
  }

  void setFirstName(String s) {
    state = state.copyWith(firstname: () => s);
  }

  void setSurname(String s) {
    state = state.copyWith(surname: () => s);
  }

  void setDepartment(param0) {
    state = state.copyWith(department: () => param0.toString());
  }

  void setPhone(String s) {
    state = state.copyWith(phone: () => s);
  }

  void setBlock(param0) {
    state = state.copyWith(block: () => param0.toString());
  }

  void setRoom(String s) {
    state = state.copyWith(room: () => s);
  }

  void updateStudent(
      {required BuildContext context, required WidgetRef ref}) async {
    CustomDialog.showLoading(message: 'Updating student........');
    var db = ref.watch(dbProvider);
    //get only digits from room
    var prefix = state.block!.toLowerCase()=='annex'?'AA':state.block!.toUpperCase().trim().substring(state.block!.toUpperCase().trim().length-1);
    var roomNumbers = state.room!.replaceAll(RegExp(r'[^0-9]'), '');
    state= state.copyWith(room: ()=>'${prefix.toUpperCase()}$roomNumbers');
    //check if room has 4 students
    var students = await StudentUsecase(db: db!).getStudentsByRoom(state.room!, state.academicYear!);
    var withoutThis = students.where((element) => element.id != state.id).toList();
    if(withoutThis.length>=4){
      CustomDialog.dismiss();
      CustomDialog.showError(message: 'Room ${state.room} already has 4 students, please choose another room');
      return;
    }
    //save user image if it has changed
    var image = ref.watch(imageProvider).image;
    if (image != null && image.path != state.image) {
      var folder = await AppUtils.createFolderInAppDocDir('students');
      var filename = state.id!.replaceAll(' ', '_');
      var path = '$folder/$filename.jpg';
      var file = File(image.path);

      try {
        //delete old image
        var oldImage = File(state.image!);
        if (oldImage.existsSync()) {
          await oldImage.delete();
        }
        await file.rename(path);
        state = state.copyWith(
          image: () => path,
        );
      } on FileSystemException catch (_) {
        // if rename fails, copy the source file and then delete it
        final newFile = await file.copy(path);
        state = state.copyWith(
          image: () => newFile.path,
        );
        if (ref.watch(imageProvider).isCaptured) {
          await file.delete();
        }
      }
    }
    var (status, message) =
        await StudentUsecase(db: db!).updateStudent(state.toMap());
    if (status) {
      state = StudentModel();
      ref.invalidate(studentFutureProvider);

      CustomDialog.dismiss();
      CustomDialog.showSuccess(message: message);
      if (!mounted) return;
      context.go(RouterInfo.studentsRoute.path);
    } else {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message);
    }
  }

  void setLevel(param0) {
    state = state.copyWith(level: () => param0.toString());
  }

  void setStudent(StudentModel student) {
    state = student;
  }

  void deleteStudent(StudentModel student, WidgetRef ref) async {
    CustomDialog.dismiss();
    CustomDialog.showLoading(message: 'Deleting student........');
    //delete student image
    var file = File(student.image!);
    if (file.existsSync()) {
      await file.delete();
    }
    var db = ref.watch(dbProvider);
    var (status, message) = await StudentUsecase(db: db!)
        .deleteStudent(student.id!, student.academicYear!);
    if (status) {
      ref.invalidate(studentFutureProvider);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(message: message);
    } else {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message);
    }
  }
}
