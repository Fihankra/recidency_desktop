import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:residency_desktop/core/data/table_model.dart';
import 'package:residency_desktop/core/functions/export/export_data.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/complaints/data/complaints.model.dart';
import 'package:residency_desktop/features/complaints/usecase/complaints_usecase.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';

final complaintsFutureProvider =
    FutureProvider.autoDispose<List<ComplaintsModel>>((ref) async {
  var db = ref.read(dbProvider);
  var settings = ref.watch(settingsProvider);
  final data =
      await ComplaintsUsecase(db: db!).getComplaints(settings.academicYear!);

  data.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  return data;
});

final complaintsProvider = StateNotifierProvider.family.autoDispose<
    ComplaintsProvider,
    TableModel<ComplaintsModel>,
    List<ComplaintsModel>>((ref, complaints) {
  return ComplaintsProvider(complaints);
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
              element.severity!.toLowerCase().contains(query.toLowerCase()) ||
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
      {required BuildContext context,
      required ComplaintsModel complaint,
      required String status}) {}


      
  void exportComplaints(
      {required String dataLength, required String format}) async {
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

