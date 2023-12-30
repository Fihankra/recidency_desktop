import 'package:residency_desktop/features/settings/data/settings_model.dart';

abstract class SettingsRepository {
  Future<SettingsModel?> loadSettings();
  Future<(Exception?, String?)> saveSettings(SettingsModel settings);
  //update settings
  Future<(Exception?, String?)> updateSettings(SettingsModel settings);
}
