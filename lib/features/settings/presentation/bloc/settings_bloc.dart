import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/settings_repository.dart';
import '../../domain/models/app_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc(this._repository) : super(const SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateSettingEvent>(_onUpdateSetting);
    on<ResetSettingsEvent>(_onResetSettings);
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(const SettingsLoading());
      final settings = await _repository.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to load settings: $e'));
    }
  }

  Future<void> _onUpdateSetting(
    UpdateSettingEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.updateSetting(event.key, event.value);
      final settings = await _repository.getSettings();
      emit(SettingsUpdated(settings));
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError('Failed to update setting: $e'));
    }
  }

  Future<void> _onResetSettings(
    ResetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final defaultSettings = AppSettings();
      await _repository.saveSettings(defaultSettings);
      emit(SettingsLoaded(defaultSettings));
    } catch (e) {
      emit(SettingsError('Failed to reset settings: $e'));
    }
  }
}
