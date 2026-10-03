import 'package:flutter/material.dart';
import 'package:free_space/data/models/tracked_item_model.dart';
import 'dart:convert';
import 'package:free_space/data/database/app_database.dart';

enum DetectionMode { smartSync, liveMonitoring, efficientBackground }

/// Modes of operation for binning.
enum OperationMode { autoBin, holdReview }

/// Repository for managing app settings.
class SettingsRepository {
  final AppSettingsDao _dao;

  const SettingsRepository(this._dao);

  static const String _keyOperationMode = 'operation_mode';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyInactivityDays = 'inactivity_days';
  static const String _keyDetectionMode = 'detection_mode';
  static const String _keyLastSyncTime = 'last_sync_time';

  /// Gets the current operation mode.
  Future<OperationMode> getOperationMode() async {
    final value = await _dao.getSetting(_keyOperationMode);
    if (value != null) {
      return OperationMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => OperationMode.holdReview,
      );
    }
    return OperationMode.holdReview;
  }

  /// Sets the operation mode.
  Future<void> setOperationMode(OperationMode mode) async {
    await _dao.setSetting(_keyOperationMode, mode.name);
  }

  /// Watches the operation mode.
  Stream<OperationMode> watchOperationMode() {
    return _dao.watchSetting(_keyOperationMode).map((value) {
      if (value != null) {
        return OperationMode.values.firstWhere(
          (e) => e.name == value,
          orElse: () => OperationMode.holdReview,
        );
      }
      return OperationMode.holdReview;
    });
  }

  /// Gets the theme mode.
  Future<ThemeMode> getThemeMode() async {
    final value = await _dao.getSetting(_keyThemeMode);
    if (value != null) {
      return ThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ThemeMode.system,
      );
    }
    return ThemeMode.system;
  }

  /// Sets the theme mode.
  Future<void> setThemeMode(ThemeMode mode) async {
    await _dao.setSetting(_keyThemeMode, mode.name);
  }

  /// Checks if onboarding is complete.
  Future<bool> isOnboardingComplete() async {
    final value = await _dao.getSetting(_keyOnboardingComplete);
    return value == 'true';
  }

  /// Sets onboarding as complete.
  Future<void> setOnboardingComplete() async {
    await _dao.setSetting(_keyOnboardingComplete, 'true');
  }

  /// Gets the number of inactivity days required for binning.
  Future<int> getInactivityDays() async {
    final value = await _dao.getSetting(_keyInactivityDays);
    return value != null ? (int.tryParse(value) ?? 30) : 30;
  }

  /// Sets the number of inactivity days.
  Future<void> setInactivityDays(int days) async {
    await _dao.setSetting(_keyInactivityDays, days.toString());
  }

  Future<DetectionMode> getDetectionMode() async {
    final value = await _dao.getSetting(_keyDetectionMode);
    if (value != null) {
      return DetectionMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => DetectionMode.smartSync,
      );
    }
    return DetectionMode.smartSync;
  }

  Future<void> setDetectionMode(DetectionMode mode) async {
    await _dao.setSetting(_keyDetectionMode, mode.name);
  }

  Future<DateTime?> getLastSyncTime() async {
    final value = await _dao.getSetting(_keyLastSyncTime);
    if (value != null) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _dao.setSetting(_keyLastSyncTime, time.toIso8601String());
  }

  static const String _keyInboxItems = 'inbox_items';

  Future<List<TrackedItemModel>> getInboxItems() async {
    final value = await _dao.getSetting(_keyInboxItems);
    if (value != null && value.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(value);
        return jsonList.map((e) => TrackedItemModel.fromJson(e)).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> setInboxItems(List<TrackedItemModel> items) async {
    final jsonList = items.map((e) => e.toJson()).toList();
    await _dao.setSetting(_keyInboxItems, jsonEncode(jsonList));
  }
}
