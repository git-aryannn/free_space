import 'package:free_space/core/constants/app_constants.dart';

/// Platform channel constants
class MethodChannels {
  MethodChannels._();

  static const String mainChannel = AppConstants.methodChannelName;
}

/// Enums for platform methods
enum PlatformMethod {
  getStorageUsage,
  scanDirectory,
  deleteFile,
  moveToBin,
  restoreFromBin,
  emptyBin;

  String get methodName {
    switch (this) {
      case PlatformMethod.getStorageUsage:
        return 'getStorageUsage';
      case PlatformMethod.scanDirectory:
        return 'scanDirectory';
      case PlatformMethod.deleteFile:
        return 'deleteFile';
      case PlatformMethod.moveToBin:
        return 'moveToBin';
      case PlatformMethod.restoreFromBin:
        return 'restoreFromBin';
      case PlatformMethod.emptyBin:
        return 'emptyBin';
    }
  }
}
