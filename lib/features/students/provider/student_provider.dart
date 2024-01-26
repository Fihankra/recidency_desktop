import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/constants/role_enum.dart';
import 'package:residency_desktop/core/data/table_model.dart';
import 'package:residency_desktop/core/functions/export/export_data.dart';
import 'package:residency_desktop/core/provider/image_provider.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/container/provider/main_provider.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:residency_desktop/features/students/usecase/student_usecase.dart';
import 'package:residency_desktop/utils/application_utils.dart';
import '../../auth/provider/mysefl_provider.dart';
import '../data/students_model.dart';

final studentProvider =
    StateNotifierProvider<StudentNotifier, TableModel<StudentModel>>((
  ref,
) {
  return StudentNotifier(ref.watch(studentDataProvider));
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
                element.block!.toLowerCase().contains(query.toLowerCase()) ||
                element.room!.toLowerCase().contains(query.toLowerCase()) ||
                element.id!.toLowerCase().contains(query.toLowerCase());
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
    if (state.items.isEmpty) {
      CustomDialog.showError(message: 'No data to export');
      return;
    }
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

  void setLevel(param0) {
    state = state.copyWith(level: () => param0.toString());
  }

  void createStudent(
      {required BuildContext context,
      required WidgetRef ref,
      required GlobalKey<FormState> form}) async {
    CustomDialog.showLoading(message: 'Creating student........');
    var dio = ref.watch(serverProvider);
    var settings = ref.watch(settingsProvider);
    var me = ref.watch(myselfProvider);
    // check students with same room numbers
    var prefix = state.block!.toLowerCase() == 'annex'
        ? 'AA'
        : state.block!
            .toUpperCase()
            .trim()
            .substring(state.block!.toUpperCase().trim().length - 1);
    state = state.copyWith(
        room: () => '${prefix.toUpperCase()}${state.room!.trim()}');

    var image = ref.watch(studentImageProvider).image;
    if (image != null) {
      var file = File(image.path);
      var (status, data) = await AppUtils.endCodeimage(
        image: file,
      );
      if (status) {
        state = state.copyWith(
          image: () => data,
        );
      }
      // delete image if it was captured
      if (ref.watch(studentImageProvider).isCaptured) {
        await file.delete();
      }
    }
    state = state.copyWith(
      createdAt: () => DateTime.now().millisecondsSinceEpoch,
      academicYear: () => settings.academicYear,
      password: () => state.id!,
    );
    var (status, data, message) =
        await StudentUsecase(dio: dio!).addStudent(state);
    if (!status) {
      if (me.id!.toLowerCase().contains('admin') && me.role == Role.hallAdmin) {
        if (message != null && message.toLowerCase().contains('full')) {
          CustomDialog.dismiss();
          CustomDialog.showInfo(
              message:
                  'Room already Full. Click "Force Add" if room takes more than 4 students.',
              buttonText: 'Force Add',
              onPressed: () {
                forceAppendStudent(
                    context: context, ref: ref, form: form, dio: dio);
              });
        } else {
          CustomDialog.dismiss();
          CustomDialog.showError(message: message ?? 'Error creating student');
        }
      } else {
        CustomDialog.dismiss();
        CustomDialog.showError(message: message ?? 'Error creating student');
      }
    } else {
      if (data == null) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: message ?? 'Error creating student');
        return;
      }
      state = StudentModel();
      form.currentState!.reset();
      ref.read(studentDataProvider.notifier).addStudent(data);
      ref.invalidate(studentImageProvider);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(
          message: message ?? 'Student created successfully');
    }
  }

  void forceAppendStudent(
      {required BuildContext context,
      required WidgetRef ref,
      required GlobalKey<FormState> form,
      required Dio dio}) async {
    CustomDialog.dismiss();
    CustomDialog.showLoading(message: 'Creating student........');
    var (status, data, message) =
        await StudentUsecase(dio: dio).forceCreateStudent(state);
    if (!status) {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message ?? 'Error creating student');
    } else {
      if (data == null) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: message ?? 'Error creating student');
        return;
      }
      state = StudentModel();
      form.currentState!.reset();
      ref.read(studentDataProvider.notifier).addStudent(data);
      ref.invalidate(studentImageProvider);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(
          message: message ?? 'Student created successfully');
    }
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
    var dio = ref.watch(serverProvider);
    var me = ref.watch(myselfProvider);
    //get only digits from room
    var prefix = state.block!.toLowerCase() == 'annex'
        ? 'AA'
        : state.block!
            .toUpperCase()
            .trim()
            .substring(state.block!.toUpperCase().trim().length - 1);
    var roomNumbers = state.room!.replaceAll(RegExp(r'[^0-9]'), '');
    state = state.copyWith(room: () => '${prefix.toUpperCase()}$roomNumbers');
    //save user image if it has changed
    var image = ref.watch(studentImageProvider).image;
    if (image != null) {
      var file = File(image.path);
      var (status, data) = await AppUtils.endCodeimage(
        image: file,
      );
      if (status) {
        state = state.copyWith(
          image: () => data,
        );
      }
      // delete image if it was captured
      if (ref.watch(studentImageProvider).isCaptured) {
        await file.delete();
      }
    }
    var (status, data, message) =
        await StudentUsecase(dio: dio!).updateStudent(state.toMap());
    if (status) {
      if (data == null) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: message ?? 'Error updating student');
        return;
      }
      state = StudentModel();
      ref.read(studentDataProvider.notifier).updateStudent(data);
      ref.invalidate(studentImageProvider);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(
          message: message ?? 'Student updated successfully');
      if (!mounted) return;
      context.go(RouterInfo.studentsRoute.path);
    } else {
      //force update
      if (me.id!.toLowerCase().contains('admin') && me.role == Role.hallAdmin) {
        if (message != null &&
            message.contains(
                'Room is already full (Already has 4 ocupant).', 0)) {
          CustomDialog.dismiss();
          CustomDialog.showInfo(
              message:
                  'Room already Full. Click "Force Update" if room takes more than 4 students.',
              buttonText: 'Force Update',
              onPressed: () {
                forceUpdateStudent(context: context, ref: ref, dio: dio);
              });
        } else {
          CustomDialog.dismiss();
          CustomDialog.showError(message: message ?? 'Error updating student');
        }
      } else {
        CustomDialog.dismiss();
        CustomDialog.showError(message: message ?? 'Error updating student');
      }
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
    var dio = ref.watch(serverProvider);
    var (status, data, message) = await StudentUsecase(dio: dio!)
        .deleteStudent(student.id!, student.academicYear!);
    if (status) {
      if (data == null) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: message ?? 'Error deleting student');
        return;
      }
      ref.read(studentDataProvider.notifier).deleteStudent(data.id!);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(
          message: message ?? 'Student deleted successfully');
    } else {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message ?? 'Error deleting student');
    }
  }

  void forceUpdateStudent(
      {required BuildContext context,
      required WidgetRef ref,
      required Dio dio}) async {
    CustomDialog.dismiss();
    CustomDialog.showLoading(message: 'Updating student........');
    var (status, data, message) =
        await StudentUsecase(dio: dio).forceUpdateStudent(state.toMap());
    if (status) {
      if (data == null) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: message ?? 'Error updating student');
        return;
      }
      state = StudentModel();
      ref.read(studentDataProvider.notifier).updateStudent(data);
      ref.invalidate(studentImageProvider);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(
          message: message ?? 'Student updated successfully');
      if (!mounted) return;
      context.go(RouterInfo.studentsRoute.path);
    } else {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message ?? 'Error updating student');
    }
  }
}

final studentImageProvider =
    StateNotifierProvider.autoDispose<ImageProvider, ImagePicked>(
        (ref) => ImageProvider());

class ImageProvider extends StateNotifier<ImagePicked> {
  ImageProvider() : super(ImagePicked());

  void setImage({XFile? image, bool isCaptured = false}) {
    state = state.copyWith(image: image, isCaptured: isCaptured);
  }
}
