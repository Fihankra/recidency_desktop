import 'package:dio/dio.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/features/settings/data/settings_model.dart';
import 'package:residency_desktop/features/settings/repo/settings_repo.dart';

class SettingsUseCase extends SettingsRepository {
  final Dio dio;
  SettingsUseCase({required this.dio});
  @override
  Future<SettingsModel?> loadSettings() async {
    try {
      var responds = await dio.get('settings');
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          if(responds.data['data']==null){
            return Future.value(null);
          }
          var data = responds.data['data'];
          return Future.value(SettingsModel.fromMap(data));
        } else {
          return Future.value(null);
        }
      } else {
        return Future.value(null);
      }
    } catch (e) {
      CustomDialog.showError(message: e.toString());
      return Future.value(null);
    }
  }

  @override
  Future<(Exception?, String?)> saveSettings(SettingsModel settings) async {
    try {
      var responds = await dio.post('settings', data: settings.toMap());
      if (responds.statusCode == 200) {
        if (responds.data['success']) {
          var message = responds.data['message'];
          return Future.value((null, message.toString()));
        } else {
          return Future.value((Exception(responds.data['message']), null));
        }
      } else {
        return Future.value((Exception('Error saving settings'), null));
      }
    } catch (e) {
      return Future.value((Exception(e), null));
    }
  }
}
