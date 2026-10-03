import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/data/services/native_platform_service.dart';
import 'package:free_space/data/repositories/storage_repository.dart';

/// Provides the NativePlatformService
final nativePlatformServiceProvider = Provider<NativePlatformService>((ref) {
  return NativePlatformService();
});

/// Provides the StorageRepository
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(ref.watch(nativePlatformServiceProvider));
});

/// Fetches current storage info
final storageInfoProvider = FutureProvider<StorageInfo>((ref) async {
  return ref.watch(storageRepositoryProvider).getStorageInfo();
});

final authorizedScanRootPathProvider = FutureProvider<String?>((ref) async {
  return ref.watch(nativePlatformServiceProvider).getScanRootDisplayPath();
});
