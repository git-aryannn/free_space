import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/repositories/settings_repository.dart';
import 'package:free_space/presentation/providers/database_provider.dart';

/// Provides the [SettingsRepository] instance.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dao = ref.watch(appSettingsDaoProvider);
  return SettingsRepository(dao);
});

/// Watches the current [OperationMode] as a stream.
final operationModeProvider = StreamProvider<OperationMode>((ref) {
  return ref.watch(settingsRepositoryProvider).watchOperationMode();
});

/// Manages the app's [ThemeMode] state.
///
/// Loads the persisted theme on creation and saves changes to the repository.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _settingsRepository;

  ThemeModeNotifier(this._settingsRepository) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _settingsRepository.getThemeMode();
    state = mode;
  }

  /// Sets and persists the given [mode].
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _settingsRepository.setThemeMode(mode);
  }
}

/// Provides the [ThemeModeNotifier] and its current [ThemeMode] state.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(settingsRepositoryProvider));
});

/// Whether the user has completed onboarding.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  return ref.watch(settingsRepositoryProvider).isOnboardingComplete();
});

/// The configured inactivity-days threshold before items are binned.
final inactivityDaysProvider = FutureProvider<int>((ref) async {
  return ref.watch(settingsRepositoryProvider).getInactivityDays();
});

final detectionModeProvider = FutureProvider<DetectionMode>((ref) async {
  return ref.watch(settingsRepositoryProvider).getDetectionMode();
});

/// Provides the list of ignored paths
final ignoredPathsProvider = StreamProvider<List<String>>((ref) {
  final dao = ref.watch(appSettingsDaoProvider);
  return dao.watchSetting('ignored_paths').map((val) {
    if (val == null || val.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(val));
    } catch (_) {
      return [];
    }
  });
});
