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
import 'package:residency_desktop/features/staffs/usecase/staff_usecases.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:residency_desktop/utils/application_utils.dart';
import '../data/staff_model.dart';

final staffFutureProvider = FutureProvider<List<StaffModel>>((ref) async {
  var db = ref.watch(dbProvider);
  var data = await StaffUsecase(db: db!).getStaffs();

  data.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  return data;
});

final newStaffProvider =
    StateNotifierProvider<NewStaffNotifier, StaffModel>((ref) {
  return NewStaffNotifier();
});

class NewStaffNotifier extends StateNotifier<StaffModel> {
  NewStaffNotifier() : super(StaffModel());

  void setStaffId(String s) {
    state = state.copyWith(id: () => s);
  }

  void setGender(String gender) {
    state = state.copyWith(
      gender: () => gender,
    );
  }

  void setFirstName(String s) {
    state = state.copyWith(
      firstname: () => s,
    );
  }

  void setSurname(String s) {
    state = state.copyWith(
      surname: () => s,
    );
  }

  void setRole(role) {
    state = state.copyWith(role: () => role);
  }

  void setEmail(String s) {
    state = state.copyWith(
      email: () => s,
    );
  }

  void setPhone(String s) {
    state = state.copyWith(
      phone: () => s,
    );
  }

  void createStaff({
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey<FormState> form,
  }) async {
    CustomDialog.showLoading(
      message: 'Creating Staff.......',
    );
    var db = ref.watch(dbProvider);
    // var settings = ref.watch(settingsProvider);
    // check id does not already exist
    var exists = await StaffUsecase(db: db!).staffExists(state.id!);
    if (exists != null) {
      if (exists.isDeleted == false) {
        CustomDialog.dismiss();
        CustomDialog.showError(
            message:
                'Staff with id ${state.id} already exists in the system. Please use a different id');
        return;
      } else {
        CustomDialog.dismiss();
        CustomDialog.showInfo(
            message:
                'Staff with id ${state.id} already exists but deleted. Do you want to update the staff with this information?',
            onPressed: () {
              updateStaff(ref: ref, form: form);
            },
            buttonText: 'Yes|Update');
      }
    } else {
      //save user image
      var image = ref.watch(imageProvider).image;
      if (image != null) {
        var folder = await AppUtils.createFolderInAppDocDir('staff');
        var filename = state.id!.replaceAll(' ', '_');
        var path = '$folder/$filename.jpg';
        var file = File(image.path);

        try {
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
        password: () => AppUtils.hashPassword(state.id!),
      );
      var (exception, message) = await StaffUsecase(db: db).saveStaff(state);
      if (exception != null) {
        CustomDialog.dismiss();
        CustomDialog.showError(message: exception.toString());
      } else {
        ref.invalidate(staffFutureProvider);
        ref.invalidate(imageProvider);
        form.currentState!.reset();
        CustomDialog.dismiss();

        CustomDialog.showSuccess(message: message!);
      }
    }
  }

  void updateStaff(
      {required WidgetRef ref, required GlobalKey<FormState> form}) async {
    CustomDialog.dismiss();
    CustomDialog.showLoading(
      message: 'Updating Staff.......',
    );
    var db = ref.watch(dbProvider);
    //save user image if it has changed
    var image = ref.watch(imageProvider).image;
    if (image != null && image.path != state.image) {
      var folder = await AppUtils.createFolderInAppDocDir('staff');
      var filename = state.id!.replaceAll(' ', '_');
      var path = '$folder/$filename.jpg';
      var file = File(image.path);

      try {
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
      isDeleted: false,
      password: () => AppUtils.hashPassword(state.id!),
    );
    var (exception, message) =
        await StaffUsecase(db: db!).updateStaff(state.toMap());
    if (exception != null) {
      CustomDialog.dismiss();
      CustomDialog.showError(message: exception.toString());
    } else {
      ref.invalidate(staffFutureProvider);
      ref.invalidate(imageProvider);
      form.currentState!.reset();
      CustomDialog.dismiss();
      CustomDialog.showSuccess(message: message!);
    }
  }
}

final selectedAssistantProvider =
    StateNotifierProvider<SelectedAssistantNotifier, StaffModel>((ref) {
  return SelectedAssistantNotifier();
});

class SelectedAssistantNotifier extends StateNotifier<StaffModel> {
  SelectedAssistantNotifier() : super(StaffModel());

  void setSelectedStaff(StaffModel staff) {
    state = staff;
  }

  void setGender(String gender) {
    state = state.copyWith(gender: () => gender);
  }

  void setFirstName(String s) {
    state = state.copyWith(firstname: () => s);
  }

  void setSurname(String s) {
    state = state.copyWith(surname: () => s);
  }

  void setEmail(String s) {
    state = state.copyWith(email: () => s);
  }

  void setPhone(String s) {
    state = state.copyWith(phone: () => s);
  }

  void setRole(role) {
    state = state.copyWith(role: () => role);
  }

  void updateStaff({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    CustomDialog.showLoading(
      message: 'Updating Staff.......',
    );
    var db = ref.watch(dbProvider);
    //save user image if it has changed
    var image = ref.watch(imageProvider).image;
    if (image != null && image.path != state.image) {
      var folder = await AppUtils.createFolderInAppDocDir('staff');
      var filename = state.id!.replaceAll(' ', '_');
      var path = '$folder/$filename.jpg';
      var file = File(image.path);

      try {
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

    //update assistant
    var (exception, message) =
        await StaffUsecase(db: db!).updateStaff(state.toMap());
    if (exception != null) {
      CustomDialog.dismiss();
      CustomDialog.showError(message: exception.toString());
    } else {
      ref.invalidate(staffFutureProvider);
      ref.invalidate(imageProvider);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(message: message!);
      if (!mounted) return;
      context.go(RouterInfo.assistantsRoute.path);
    }
  }

  void deleteStaff(StaffModel assistant, WidgetRef ref) async {
    CustomDialog.dismiss();
    CustomDialog.showLoading(message: 'Deleting Staff.......');
    //delete assistant image if it exists
    if (assistant.image != null) {
      var file = File(assistant.image!);
      if (file.existsSync()) {
        await file.delete();
      }
    }
    var db = ref.watch(dbProvider);
    var (exception, message) =
        await StaffUsecase(db: db!).markStaffDeleted(assistant.id!);
    if (exception != null) {
      CustomDialog.dismiss();
      CustomDialog.showError(message: exception.toString());
    } else {
      ref.invalidate(staffFutureProvider);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(message: message!);
    }
  }
}

final staffProvider = StateNotifierProvider.family<StaffNotifier,
    TableModel<StaffModel>, List<StaffModel>>((ref, data) {
  return StaffNotifier(data);
});

class StaffNotifier extends StateNotifier<TableModel<StaffModel>> {
  StaffNotifier(this.items)
      : super(TableModel(
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
  final List<StaffModel> items;

  void init() {
    List<List<StaffModel>> pages = [];
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

  void selectRow(StaffModel row) {
    state = state
        .copyWith(selectedRows: [...state.selectedRows, row], items: items);
  }

  void unselectRow(StaffModel row) {
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

  void searchStaff(String query) {
    if (query.isEmpty) {
      init();
    } else {
      var data = items
          .where((element) =>
              element.firstname!.toLowerCase().contains(query.toLowerCase()) ||
              element.surname!.toLowerCase().contains(query.toLowerCase()) ||
              element.email!.toLowerCase().contains(query.toLowerCase()) ||
              element.id!.toLowerCase().contains(query.toLowerCase()) ||
              element.phone!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      List<List<StaffModel>> pages = [];
      state = state.copyWith(
          items: data,
          selectedRows: [],
          currentPage: 0,
          pages: pages,
          currentPageItems: [],
          hasNextPage: false,
          hasPreviousPage: false);
      if (data.isNotEmpty) {
        var pagesCount = (data.length / state.pageSize).ceil();
        for (var i = 0; i < pagesCount; i++) {
          var page =
              data.skip(i * state.pageSize).take(state.pageSize).toList();

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
  }

  void exportStaff({required String dataLength, required String format}) async {
    CustomDialog.showLoading(message: 'Exporting data to excel.......');

    var data = ExportData<StaffModel>(
        fileName: dataLength == 'all'
            ? 'all_staffs.$format'
            : 'selected_staffs.$format',
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

Future<String> importAssistant(
    {required WidgetRef ref, required String year}) async {
  // get db
  var db = ref.watch(dbProvider);
  // get settings
  var response = await StaffUsecase(db: db!).importAssistants(year);
  if (response) {
    ref.invalidate(staffFutureProvider);
    return 'Staff imported successfully';
  } else {
    return 'Error importing assistants';
  }
}
