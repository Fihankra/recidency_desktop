import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/data/table_model.dart';
import 'package:residency_desktop/core/functions/export/export_data.dart';
import 'package:residency_desktop/core/provider/image_provider.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/container/provider/main_provider.dart';
import 'package:residency_desktop/features/staffs/usecase/staff_usecases.dart';
import 'package:residency_desktop/utils/application_utils.dart';
import '../data/staff_model.dart';

final newStaffProvider =
    StateNotifierProvider<NewStaffNotifier, StaffModel>((ref) {
  return NewStaffNotifier();
});

class NewStaffNotifier extends StateNotifier<StaffModel> {
  NewStaffNotifier() : super(StaffModel());

  void setStaffId(String s) {
    state = state.copyWith(id: () => s.toUpperCase());
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
    var dio = ref.watch(serverProvider);
    //save user image
    var image = ref.watch(staffImageProvider).image;
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
      if (ref.watch(staffImageProvider).isCaptured) {
        await file.delete();
      }
    }
    state = state.copyWith(
      createdAt: () => DateTime.now().millisecondsSinceEpoch,
      password: () => state.id!,
    );
    var (success, data, message) =
        await StaffUsecase(dio: dio!).saveStaff(state);
    if (!success) {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message!);
    } else {
      // add data staff to staff provider
      if (data != null) {
        ref.read(staffDataProvider.notifier).addStaff(data);
      }
      //ref.invalidate(staffFutureProvider);
      ref.invalidate(staffImageProvider);
      form.currentState!.reset();
      CustomDialog.dismiss();
      CustomDialog.showSuccess(
          message: message ?? 'Staff created successfully');
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
    var dio = ref.watch(serverProvider);
    //save user image if it has changed
    var image = ref.watch(staffImageProvider).image;
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
      if (ref.watch(staffImageProvider).isCaptured) {
        await file.delete();
      }
    }

    //update assistant
    var (success, data, message) =
        await StaffUsecase(dio: dio!).updateStaff(state.toMap());
    if (!success) {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message!);
    } else {
      // update staff provider
      if (data != null) {
        ref.read(staffDataProvider.notifier).updateStaff(data);
      }
      ref.invalidate(staffImageProvider);
      CustomDialog.dismiss();
      CustomDialog.showSuccess(
          message: message ?? 'Staff updated successfully');
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
    var dio = ref.watch(serverProvider);
    var (success, data, message) =
        await StaffUsecase(dio: dio!).markStaffDeleted(assistant.id!);
    if (!success) {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message!);
    } else {
      if (data != null) {
        ref.read(staffDataProvider.notifier).deleteStaff(data.id!);
      }
      CustomDialog.dismiss();
      CustomDialog.showSuccess(
          message: message ?? 'Staff deleted successfully');
    }
  }
}

final staffProvider =
    StateNotifierProvider<StaffNotifier, TableModel<StaffModel>>((ref) {
  return StaffNotifier(ref.watch(staffDataProvider));
});

class StaffNotifier extends StateNotifier<TableModel<StaffModel>> {
  StaffNotifier(this.staffs)
      : super(TableModel(
          currentPage: 0,
          pageSize: 10,
          selectedRows: [],
          pages: [],
          currentPageItems: [],
          items: staffs,
          hasNextPage: false,
          hasPreviousPage: false,
        )) {
    init();
  }

  final List<StaffModel> staffs;

  void init() {
    List<List<StaffModel>> pages = [];
    state = state.copyWith(
        items: staffs,
        selectedRows: [],
        currentPage: 0,
        pages: pages,
        currentPageItems: [],
        hasNextPage: false,
        hasPreviousPage: false);
    if (state.items.isNotEmpty) {
      var pagesCount = (state.items.length / state.pageSize).ceil();
      for (var i = 0; i < pagesCount; i++) {
        var page =
            state.items.skip(i * state.pageSize).take(state.pageSize).toList();

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
    state = state.copyWith(selectedRows: [...state.selectedRows, row]);
  }

  void unselectRow(StaffModel row) {
    state = state.copyWith(selectedRows: [...state.selectedRows..remove(row)]);
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
      var data = state.items
          .where((element) =>
              element.firstname!.toLowerCase().contains(query.toLowerCase()) ||
              element.surname!.toLowerCase().contains(query.toLowerCase()) ||
              element.id!.toLowerCase().contains(query.toLowerCase()) ||
              element.role!.toLowerCase().contains(query.toLowerCase()))
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
    if (state.items.isEmpty) {
      CustomDialog.showError(message: 'No data to export');
      return;
    }
    CustomDialog.showLoading(message: 'Exporting data to excel.......');

    var data = ExportData<StaffModel>(
        fileName: dataLength == 'all'
            ? 'all_staffs.$format'
            : 'selected_staffs.$format',
        data: dataLength != 'all' ? state.currentPageItems : state.items,
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

final staffImageProvider =
    StateNotifierProvider.autoDispose<ImageProvider, ImagePicked>(
        (ref) => ImageProvider());

class ImageProvider extends StateNotifier<ImagePicked> {
  ImageProvider() : super(ImagePicked());

  void setImage({XFile? image, bool isCaptured = false}) {
    state = state.copyWith(image: image, isCaptured: isCaptured);
  }
}
