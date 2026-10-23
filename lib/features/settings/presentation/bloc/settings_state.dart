import '../../domain/models/app_settings.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final AppSettings settings;

  const SettingsLoaded(this.settings);
}

class SettingsUpdated extends SettingsState {
  final AppSettings settings;

  const SettingsUpdated(this.settings);
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);
}
