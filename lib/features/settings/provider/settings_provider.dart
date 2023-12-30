import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/database/connection.dart';
import 'package:residency_desktop/features/settings/data/settings_model.dart';
import 'package:residency_desktop/features/settings/usecase/settings_usecase.dart';
import 'package:residency_desktop/utils/application_utils.dart';

final settingsFutureProvider = FutureProvider<SettingsModel>((ref) async {
  var db = ref.watch(dbProvider);
  var data = await SettingsUseCase(db: db!).loadSettings() ?? SettingsModel();
  ref.read(settingsProvider.notifier).setSettings(data);
  return Future.value(data);
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(SettingsModel());

  void setSettings(SettingsModel settings) {
    state = settings;
  }

  Future<void> pickImage() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (image != null) {
      state = state.copyWith(
        hallLogo: () => image.path,
      );
    }
  }

  void setHallName(String s) {
    state = state.copyWith(
      hallName: () => s,
    );
  }

  void setTargetGender(String string) {
    state = state.copyWith(
      targetGender: () => string,
    );
  }

  void setAcademicYear(String string) {
    state = state.copyWith(
      academicYear: () => string,
    );
  }

  void saveSettings({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    CustomDialog.showLoading(message: 'Saving Settings...');
    var db = ref.watch(dbProvider);
    if (state.hallLogo != null && state.hallLogo!.isNotEmpty) {
      var folder = await AppUtils.createFolderInAppDocDir('hall');
      var filename = state.hallName!.replaceAll(' ', '_');
      var path = '$folder/$filename.jpg';
      //save logo to path
      var file = File(state.hallLogo!);

      try {
        await file.rename(path);
        state = state.copyWith(
          hallLogo: () => path,
        );
      } on FileSystemException catch (_) {
        // if rename fails, copy the source file and then delete it
        final newFile = await file.copy(path);
        state = state.copyWith(
          hallLogo: () => newFile.path,
        );
      }
    }
    state = state.copyWith(
      id: () => AppUtils.getId(),
      createdAt: () => DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    var (exception, settings) =
        await SettingsUseCase(db: db!).saveSettings(state);
    if (exception != null) {
      CustomDialog.dismiss();
      CustomDialog.showError(
        message: exception.toString(),
      );
    } else {
      if (settings != null) {
        ref.invalidate(settingsFutureProvider);
        CustomDialog.dismiss();
        CustomDialog.showToast(
          message: 'Settings Saved Successfully',
        );
      } else {
        CustomDialog.dismiss();
        CustomDialog.showError(
          message: 'Something went wrong',
        );
      }
    }
  }
}
