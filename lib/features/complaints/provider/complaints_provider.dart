import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:residency_desktop/config/router/router_info.dart';
import 'package:residency_desktop/core/data/table_model.dart';
import 'package:residency_desktop/core/functions/export/export_data.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/complaints/data/complaints.model.dart';
import 'package:residency_desktop/features/complaints/usecase/complaints_usecase.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/utils/application_utils.dart';

import '../../container/provider/main_provider.dart';

final complaintsProvider =
    StateNotifierProvider<ComplaintsProvider, TableModel<ComplaintsModel>>(
        (ref) {
  return ComplaintsProvider(ref.watch(complaintDataProvider));
});

class ComplaintsProvider extends StateNotifier<TableModel<ComplaintsModel>> {
  ComplaintsProvider(this.items)
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
  final List<ComplaintsModel> items;
  void init() {
    List<List<ComplaintsModel>> pages = [];
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

  void selectRow(ComplaintsModel row) {
    state = state
        .copyWith(selectedRows: [...state.selectedRows, row], items: items);
  }

  void unselectRow(ComplaintsModel row) {
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
    if (query.isEmpty) {
      init();
    } else {
      var data = items
          .where((element) =>
              element.title!.toLowerCase().contains(query.toLowerCase()) ||
              element.description!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              element.studentName!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              element.roomNumber!.toLowerCase().contains(query.toLowerCase()) ||
              element.type!.toLowerCase().contains(query.toLowerCase()) ||
              element.status!.toLowerCase().contains(query.toLowerCase()) ||
              element.studentPhone!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      List<List<ComplaintsModel>> pages = [];
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

  void updateStatus(
      {required WidgetRef ref,
      required ComplaintsModel complaint,
      required String newState}) async {
    CustomDialog.showLoading(message: 'Updating status....');
    var dio = ref.watch(serverProvider);
    complaint = complaint.copyWith(status: () => newState);
    var (status, data, message) =
        await ComplaintsUsecase(dio: dio!).updateComplaint(complaint.toMap());
    CustomDialog.dismiss();
    if (status) {
      if (data != null) {
        if (data.status!.toLowerCase() == 'deleted') {
          ref.read(complaintDataProvider.notifier).deleteComplaint(data.id!);
        } else {
          ref.read(complaintDataProvider.notifier).updateComplaint(data);
        }
      }
      CustomDialog.showSuccess(message: message);
      //clear form
    } else {
      CustomDialog.showError(message: message);
    }
  }

  void exportComplaints(
      {required String dataLength, required String format}) async {
    if (state.items.isEmpty) {
      CustomDialog.showError(message: 'No data to export');
      return;
    }
    CustomDialog.showLoading(message: 'Exporting data to excel.......');

    var data = ExportData<ComplaintsModel>(
        fileName: dataLength == 'all'
            ? 'all_complaints.$format'
            : 'selected_complaints.$format',
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

final newComplaintsProvider =
    StateNotifierProvider<NewComplaintsController, ComplaintsModel>((ref) {
  return NewComplaintsController();
});

class NewComplaintsController extends StateNotifier<ComplaintsModel> {
  NewComplaintsController() : super(ComplaintsModel());

  void setStudent(StudentModel value) {
    state = state.copyWith(
        studentId: () => value.id!,
        studentName: () => '${value.firstname} ${value.surname}',
        studentPhone: () => value.phone,
        roomNumber: () => value.room,
        studentImage: () => value.image);
  }

  void setTitle(String? title) {
    state = state.copyWith(title: () => title);
  }

  void setDescription(String? desc) {
    state = state.copyWith(description: () => desc);
  }

  void setType(String string) {
    state = state.copyWith(type: () => string);
  }

  void setSeverity(string) {
    state = state.copyWith(severity: () => string);
  }

  void setLocation(String? value) {
    state = state.copyWith(location: () => value);
  }

  void submitComplaint(
      {required WidgetRef ref,
      required GlobalKey<FormState> form,
      required BuildContext context}) async {
    CustomDialog.showLoading(message: 'Submitting Complaint....');
    var dio = ref.watch(serverProvider);
    var settings = ref.watch(settingsProvider);
    var me = ref.watch(myselfProvider);
    state = state.copyWith(
        id: () => AppUtils.getId(),
        assistantId: () => me.id,
        assistantName: () => '${me.firstname} ${me.surname}',
        academicYear: () => settings.academicYear,
        status: () => 'Pending',
        createdAt: () => DateTime.now().millisecondsSinceEpoch);
    var (status, data, message) =
        await ComplaintsUsecase(dio: dio!).addComplaint(state);
    CustomDialog.dismiss();
    if (status) {
      if (data != null) {
        ref.read(complaintDataProvider.notifier).addComplaint(data);
        CustomDialog.showSuccess(
            message: message ?? 'Complaint submitted successfully');
        //clear form
        state = ComplaintsModel();
        form.currentState!.reset();
        context.go(RouterInfo.complaintsRoute.path);
      } else {
        CustomDialog.showError(
            message: message ?? 'Failed to submit complaint');
      }
    } else {
      CustomDialog.showError(message: message ?? 'Failed to submit complaint');
    }
  }
}
