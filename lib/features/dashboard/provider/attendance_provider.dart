import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:residency_desktop/core/data/table_model.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/dashboard/data/attendance_model.dart';
import 'package:residency_desktop/features/dashboard/usecase/attendance_usecase.dart';
import 'package:residency_desktop/features/settings/provider/settings_provider.dart';


final attendanceFutureProvider =
    FutureProvider.autoDispose<List<AttendanceModel>>((ref) async {
      var dio = ref.watch(serverProvider);
      var settings = ref.watch(settingsProvider);
  var data = await AttendanceUseCase(dio: dio!).getAttendance(settings.academicYear!);
  data.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  return data;
});

final todayAttendanceProvider =
    StateProvider.family<List<AttendanceModel>, List<AttendanceModel>>(
        (ref, list) {
  var today = DateTime.now();
  var todayAttendance = list
      .where(
          (element) => element.date == DateFormat('MMM dd, yyyy').format(today))
      .toList();
  return todayAttendance;
});

final attendanceProvider = StateNotifierProvider.family<AttendanceNotifer,
    TableModel<AttendanceModel>, List<AttendanceModel>>((ref, list) {
  return AttendanceNotifer(list);
});

class AttendanceNotifer extends StateNotifier<TableModel<AttendanceModel>> {
  AttendanceNotifer(this.items) : super(TableModel(
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

  final List<AttendanceModel> items;
  
   void init() {
    List<List<AttendanceModel>> pages = [];
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

  void selectRow(AttendanceModel row) {
    state = state
        .copyWith(selectedRows: [...state.selectedRows, row], items: items);
  }

  void unselectRow(AttendanceModel row) {
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
              element.action!.toLowerCase().contains(query.toLowerCase()) ||
              element.time!.toLowerCase().contains(query.toLowerCase()) ||
              element.date!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      List<List<AttendanceModel>> pages = [];
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
    ref.read(attendanceFilter.notifier).state = formatedDate;
    var data = items
        .where(
            (element) => element.date!.toLowerCase().contains(formatedDate))
        .toList();
    List<List<AttendanceModel>> pages = [];
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
}
final isAttendanceSearchingProvider = StateProvider<bool>((ref) => false);

final attendanceFilter = StateProvider<String>((ref) => 'All');
