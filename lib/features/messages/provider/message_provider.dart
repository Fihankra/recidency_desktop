import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:residency_desktop/core/data/table_model.dart';
import 'package:residency_desktop/core/functions/export/export_data.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/messages/data/message_model.dart';
import 'package:residency_desktop/features/students/data/students_model.dart';
import 'package:residency_desktop/utils/application_utils.dart';
import '../../container/provider/main_provider.dart';
import '../../settings/provider/settings_provider.dart';
import '../usecases/message_usecase.dart';

final messageProvider =
    StateNotifierProvider<MessageProvider, TableModel<MessageModel>>((ref) {
  return MessageProvider(ref.watch(messageDataProvider));
});

class MessageProvider extends StateNotifier<TableModel<MessageModel>> {
  MessageProvider(this.items)
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
  final List<MessageModel> items;
  void init() {
    List<List<MessageModel>> pages = [];
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

  void selectRow(MessageModel row) {
    state = state
        .copyWith(selectedRows: [...state.selectedRows, row], items: items);
  }

  void unselectRow(MessageModel row) {
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
              element.message!.toLowerCase().contains(query.toLowerCase()) ||
              element.senderId!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      List<List<MessageModel>> pages = [];
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

  void exportMessages(
      {required String dataLength, required String format}) async {
    if (state.items.isEmpty) {
      CustomDialog.showError(message: 'No data to export');
      return;
    }
    CustomDialog.showLoading(message: 'Exporting data to excel.......');

    var data = ExportData<MessageModel>(
        fileName: dataLength == 'all'
            ? 'all_messages.$format'
            : 'selected_messages.$format',
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

final newMessageProvider =
    StateNotifierProvider.autoDispose<NewMessageProvider, MessageModel>((ref) {
  return NewMessageProvider();
});

class NewMessageProvider extends StateNotifier<MessageModel> {
  NewMessageProvider()
      : super(MessageModel(
          recipients: [],
        ));

  void setSender(String? sender) {
    state = state.copyWith(
        senderId: () =>
            sender != null ? sender.toUpperCase() : 'Autonomy'.toUpperCase());
  }

  void setMessage(String? message) {
    state = state.copyWith(message: () => message);
  }

  void setRecipients(List<StudentModel> filter, WidgetRef ref) {
    //convert to list of map
    var recipients = <Map<String, dynamic>>[];
    for (var item in filter) {
      recipients.add(item.toMap());
    }
    state = state.copyWith(recipients: () => recipients);
    ref.read(selectedReceipientProvider.notifier).state = filter;
  }

  void search(String value, WidgetRef ref) {
    if (value.isEmpty) {
      if (state.recipients != null) {
        List<StudentModel> filter = [];
        for (var item in state.recipients!) {
          filter.add(StudentModel.fromMap(item));
        }
        ref.read(selectedReceipientProvider.notifier).state = filter;
      }
    } else {
      var filter = state.recipients!
          .where((element) =>
              element['firstname']!
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              element['surname']!.toLowerCase().contains(value.toLowerCase()) ||
              element['phone']!.toLowerCase().contains(value.toLowerCase()) ||
              element['id']!.toLowerCase().contains(value.toLowerCase()))
          .toList();

      List<StudentModel> data = [];
      for (var item in filter) {
        data.add(StudentModel.fromMap(item));
      }
      ref.read(selectedReceipientProvider.notifier).state = data;
    }
  }

  void deleteRecipient(StudentModel student, WidgetRef ref) {
    var filter = state.recipients!
        .where((element) => element['id'] != student.id)
        .toList();
    state = state.copyWith(recipients: () => filter);
    List<StudentModel> data = [];
    for (var item in filter) {
      data.add(StudentModel.fromMap(item));
    }
    ref.read(selectedReceipientProvider.notifier).state = data;
  }

  void send(
      WidgetRef ref, BuildContext context, GlobalKey<FormState> formKey) async {
    CustomDialog.dismiss();
    if (state.recipients == null || state.recipients!.isEmpty) {
      CustomDialog.showError(message: 'Please select at least one recipient');
      return;
    }
    CustomDialog.showLoading(message: 'Sending message.......');
    var settings = ref.read(settingsProvider);
    var dio = ref.read(serverProvider);
    state = state.copyWith(
        createdAt: () => DateTime.now().toUtc().millisecondsSinceEpoch,
        accademicYear: () => settings.academicYear,
        id: () => AppUtils.getId(),
        status: () => 'pending');
    var (success, data, message) =
        await MessageUsecase(dio: dio!).createMessage(state);

    if (success) {
      CustomDialog.dismiss();
      if (data != null) {
        CustomDialog.showSuccess(
            message: message ?? 'Message sent successfully');
        ref.read(messageDataProvider.notifier).addMessage(data);
      } else {
        CustomDialog.showError(message: message ?? 'An error occured');
      }
    } else {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message ?? 'An error occured');
    }
  }
}

final messageReceipeintProvider = StateNotifierProvider.family
    .autoDispose<MessageReceipeintProvider, List<StudentModel>, WidgetRef>(
        (ref, ref2) =>
            MessageReceipeintProvider(ref.watch(studentDataProvider), ref2));

class MessageReceipeintProvider extends StateNotifier<List<StudentModel>> {
  MessageReceipeintProvider(this.items, this.ref) : super(items);
  final List<StudentModel> items;
  final WidgetRef ref;

  void filterByGender(String string) {
    var filter = items.where((element) => element.gender == string).toList();
    ref.read(newMessageProvider.notifier).setRecipients(filter, ref);
  }

  void filterByLevel(String string) {
    var filter = items.where((element) => element.level == string).toList();
    ref.read(newMessageProvider.notifier).setRecipients(filter, ref);
  }

  void filterByBlock(String string) {
    var filter = items.where((element) => element.block == string).toList();
    ref.read(newMessageProvider.notifier).setRecipients(filter, ref);
  }

  void filterByStudent(StudentModel value) {
    var filter = items.where((element) => element.id == value.id).toList();
    ref.read(newMessageProvider.notifier).setRecipients(filter, ref);
  }

  void filterByRoom(String room) {
    var filter = items
        .where((element) => element.room!.toLowerCase() == room.toLowerCase())
        .toList();
    ref.read(newMessageProvider.notifier).setRecipients(filter, ref);
  }
}

final messageReceipeintFilterProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final selectedReceipientProvider =
    StateProvider<List<StudentModel>>((ref) => []);

final selectedFilterProvider = StateProvider<String?>((ref) => null);

final selectedMessageProvider =
    StateNotifierProvider<SelectedMessageProvider, MessageModel>(
        (ref) => SelectedMessageProvider());

class SelectedMessageProvider extends StateNotifier<MessageModel> {
  SelectedMessageProvider() : super(MessageModel());

  void deleteMessage(WidgetRef ref, MessageModel selected) async {
    CustomDialog.showLoading(message: 'Deleting message.......');
    var dio = ref.read(serverProvider);
    var (success, data, message) = await MessageUsecase(dio: dio!)
        .makeAsDeleted(selected.id!, {'isDeleted': true});
    if (success) {
      CustomDialog.dismiss();
      if (data != null) {
        ref.read(messageDataProvider.notifier).deleteMessage(data.id!);
        CustomDialog.showSuccess(
            message: message != null && message.isNotEmpty
                ? message
                : 'Message deleted successfully');
      } else {
        CustomDialog.showError(message: message ?? 'An error occured');
      }
    } else {
      CustomDialog.dismiss();
      CustomDialog.showError(message: message ?? 'An error occured');
    }
  }
}
