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
  var dio = ref.watch(serverProvider);
  var data = await SettingsUseCase(dio: dio!).loadSettings() ?? SettingsModel();
  ref.read(settingsProvider.notifier).setSettings(data);
  return Future.value(data);
});

final hallLogoProvider =
    StateNotifierProvider<HallLogoPickerNotifier, File?>((ref) {
  return HallLogoPickerNotifier();
});

class HallLogoPickerNotifier extends StateNotifier<File?> {
  HallLogoPickerNotifier() : super(null);

  void clearLogo() {
    state = null;
  }

  Future<void> pickImage() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (image != null) {
      state = File(image.path);
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsModel>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(SettingsModel());

  void setSettings(SettingsModel settings) {
    state = settings;
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
    var id = 'settings'.hashCode.toString();
    var dio = ref.watch(serverProvider);
    if (ref.watch(hallLogoProvider) != null) {
      var (success, data) = await AppUtils.endCodeimage(
        image: ref.watch(hallLogoProvider)!,
      );
      if (success) {
        state = state.copyWith(
          hallLogo: () => data,
        );
      }
      //clear logo
      ref.read(hallLogoProvider.notifier).clearLogo();
      ref.invalidate(hallLogoProvider);
    }
    state = state.copyWith(
      id: () => id,
      createdAt: () => DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    var (exception, settings) =
        await SettingsUseCase(dio: dio!).saveSettings(state);
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
