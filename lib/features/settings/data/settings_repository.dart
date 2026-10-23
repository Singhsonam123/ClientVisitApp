import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/app_settings.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const String _settingsKey = 'app_settings';

  Future<AppSettings> getSettings() async {
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson == null) {
      return AppSettings();
    }
    
    // Parse JSON string to Map
    try {
      final Map<String, dynamic> map = {};
      final pairs = settingsJson.split('&');
      for (var pair in pairs) {
        final keyValue = pair.split('=');
        if (keyValue.length == 2) {
          map[keyValue[0]] = keyValue[1] == 'true';
        }
      }
      return AppSettings.fromMap(map);
    } catch (e) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final map = settings.toMap();
    final pairs = <String>[];
    map.forEach((key, value) {
      pairs.add('$key=$value');
    });
    final settingsJson = pairs.join('&');
    await _prefs.setString(_settingsKey, settingsJson);
  }

  Future<void> updateSetting(String key, bool value) async {
    final settings = await getSettings();
    late AppSettings updatedSettings;
    
    switch (key) {
      case 'enableGallery':
        updatedSettings = settings.copyWith(enableGallery: value);
        break;
      case 'enableAgenda':
        updatedSettings = settings.copyWith(enableAgenda: value);
        break;
      case 'enablePotluck':
        updatedSettings = settings.copyWith(enablePotluck: value);
        break;
      case 'enableSweets':
        updatedSettings = settings.copyWith(enableSweets: value);
        break;
      case 'enableNotifications':
        updatedSettings = settings.copyWith(enableNotifications: value);
        break;
      case 'enableAnalytics':
        updatedSettings = settings.copyWith(enableAnalytics: value);
        break;
      case 'enableDarkMode':
        updatedSettings = settings.copyWith(enableDarkMode: value);
        break;
      default:
        return;
    }
    
    await saveSettings(updatedSettings);
  }
}
