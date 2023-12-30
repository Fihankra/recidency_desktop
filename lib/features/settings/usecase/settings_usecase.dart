import 'package:mongo_dart/mongo_dart.dart';
import 'package:residency_desktop/core/widgets/custom_dialog.dart';
import 'package:residency_desktop/features/settings/data/settings_model.dart';
import 'package:residency_desktop/features/settings/repo/settings_repo.dart';

class SettingsUseCase extends SettingsRepository {
  final Db db;
  SettingsUseCase({required this.db});
  @override
  Future<SettingsModel?> loadSettings() async {
    try {
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('settings');
      Map<String, dynamic>? data = await coll.findOne();
      if (data != null) {
        return Future.value(SettingsModel.fromMap(data));
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
      if (db.state != State.open) {
        await db.open();
      }
      var coll = db.collection('settings');
      var data = await coll.findOne();
      if (data != null) {
        await coll.update(
          where.eq('_id', data['_id']),
          settings.toMap(),
        );
        return Future.value((null, 'Settings Updated Successfully'));
      } else {
        await coll.insert(settings.toMap());
        return Future.value((null, 'Settings Saved Successfully'));
      }
    } catch (e) {
      return Future.value((Exception(e), null));
    }
  }

  @override
  Future<(Exception?, String?)> updateSettings(SettingsModel settings) {
    // TODO: implement updateSettings
    throw UnimplementedError();
  }
}
