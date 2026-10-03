/// A lightweight background-task stub.
///
/// The project previously depended on the WorkManager plugin, but that package is
/// not compatible with the current Flutter/Android toolchain in this workspace.
/// The app does not currently invoke this service, so we keep it as a harmless
/// no-op to keep the project building on the device.
class BackgroundService {
  static Future<void> init() async {}

  static Future<void> cancel() async {}
}
