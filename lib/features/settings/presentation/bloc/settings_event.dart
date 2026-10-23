abstract class SettingsEvent {
  const SettingsEvent();
}

class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

class UpdateSettingEvent extends SettingsEvent {
  final String key;
  final bool value;

  const UpdateSettingEvent({required this.key, required this.value});
}

class ResetSettingsEvent extends SettingsEvent {
  const ResetSettingsEvent();
}
