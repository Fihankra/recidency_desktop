import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:residency_desktop/core/data/table_model.dart';
import 'package:residency_desktop/core/functions/export/export_data.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/auth/provider/mysefl_provider.dart';
import 'package:residency_desktop/features/keyFlow/data/key_flow.model.dart';
import 'package:residency_desktop/features/keyFlow/usecase/key_flow_usecase.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/utils/application_utils.dart';

final keyLogFutureProvider = FutureProvider<List<KeyLogModel>>((ref) async {
  var db = ref.watch(dbProvider);
  var settings = ref.watch(settingsProvider);
  final data =
      await KeyFlowUseCase(db: db!).getKeyFlows(settings.academicYear!);
  data.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  return data;
});

final keyLogProvider = StateNotifierProvider.family<KeyLogNotifier,
    TableModel<KeyLogModel>, List<KeyLogModel>>((ref, data) {
  return KeyLogNotifier(data);
});

class KeyLogNotifier extends StateNotifier<TableModel<KeyLogModel>> {
  KeyLogNotifier(this.items)
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
  final List<KeyLogModel> items;
  void init() {
    List<List<KeyLogModel>> pages = [];
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

  void selectRow(KeyLogModel row) {
    state = state
        .copyWith(selectedRows: [...state.selectedRows, row], items: items);
  }

  void unselectRow(KeyLogModel row) {
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
              element.assistantName!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              element.roomNumber!
                  .toLowerCase()
                  .trim()
                  .contains(query.toLowerCase()) ||
              element.studentName!
                  .toLowerCase()
                  .trim()
                  .contains(query.toLowerCase()) ||
              element.activity!.toLowerCase().contains(query.toLowerCase()) ||
              element.date!.toLowerCase().trim().contains(query.toLowerCase()))
          .toList();
      List<List<KeyLogModel>> pages = [];
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

  void filterByDate(DateTime value, WidgetRef ref) {
    var formatedDate = DateFormat('MMM dd ,yyyy').format(value);
    ref.read(keyLogFilter.notifier).state = formatedDate;
    var data = items
        .where((element) => element.date!
            .toLowerCase()
            .trim()
            .contains(formatedDate.trim().toLowerCase()))
        .toList();
    List<List<KeyLogModel>> pages = [];
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
        var page = data.skip(i * state.pageSize).take(state.pageSize).toList();

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

  void exportKeyLogs(
      {required String dataLength, required String format}) async {
    CustomDialog.showLoading(message: 'Exporting data to excel.......');

    var data = ExportData<KeyLogModel>(
        fileName: dataLength == 'all'
            ? 'all_keyLogs.$format'
            : 'selected_keyLogs.$format',
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

final keyLogFilter = StateProvider<String>((ref) => 'All');

final newKeyLogProvider =
    StateNotifierProvider<NewKeyFlow, void>((ref) => NewKeyFlow());

class NewKeyFlow extends StateNotifier<void> {
  NewKeyFlow() : super(KeyLogModel());

  void addKeyActivity(
      {required WidgetRef ref,
      required String activity,
      required StudentModel student}) async {
    CustomDialog.showLoading(message: 'Adding Key Activity....');
    var db = ref.watch(dbProvider);
    var settings = ref.watch(settingsProvider);
    var me = ref.watch(myselfProvider);
    var dateTime = DateTime.now().toUtc();
    var keyLog = KeyLogModel();
    keyLog.activity = activity;
    keyLog.assistantId = me.id;
    keyLog.assistantName = '${me.firstname} ${me.surname}';
    keyLog.studentId = student.id;
    keyLog.studentName = '${student.firstname} ${student.surname}';
    keyLog.studentPhone = student.phone;
    keyLog.roomNumber = student.room;
    keyLog.academicYear = settings.academicYear;
    keyLog.date = DateFormat('MMM dd ,yyyy').format(dateTime);
    keyLog.time = DateFormat('hh:mm a').format(dateTime);
    keyLog.createdAt = dateTime.millisecondsSinceEpoch;
    keyLog.studentImage = student.image;
    keyLog.assistantImage = me.image;
    keyLog.id = AppUtils.getId();
    var (status, message) = await KeyFlowUseCase(db: db!).addKeyFlow(keyLog);
    ref.invalidate(keyLogFutureProvider);
    CustomDialog.dismiss();
    if (status) {
      CustomDialog.showToast(message: message);
    } else {
      CustomDialog.showError(message: message);
    }
  }
}
