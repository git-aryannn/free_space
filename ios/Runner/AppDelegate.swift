import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    if let flutterViewController = window?.rootViewController as? FlutterViewController {
        FreeSpacePlatformChannel.register(with: flutterViewController.pluginRegistry().registrar(forPlugin: "FreeSpacePlatformChannel")!)
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
