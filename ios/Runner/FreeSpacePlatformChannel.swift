import Foundation
import Flutter
import UserNotifications

public class FreeSpacePlatformChannel: NSObject {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.freespace.app/platform", binaryMessenger: registrar.messenger())
        let instance = FreeSpacePlatformChannel()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getStorageInfo":
            result(getStorageInfo())
        case "scanDirectory":
            result(scanDirectory())
        case "requestPermission":
            if let args = call.arguments as? [String: Any], let type = args["type"] as? String {
                requestPermission(type: type, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Permission type is required", details: nil))
            }
        default:
            result(FlutterError(code: "UNSUPPORTED", message: "This feature is not available on iOS due to platform restrictions.", details: nil))
        }
    }
    
    private func getStorageInfo() -> [String: Any] {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
            let total = values.volumeTotalCapacity ?? 0
            let free = values.volumeAvailableCapacityForImportantUsage ?? 0
            let used = total - free
            
            return [
                "totalBytes": total,
                "usedBytes": used,
                "freeBytes": free
            ]
        } catch {
            return ["error": error.localizedDescription]
        }
    }
    
    private func scanDirectory() -> [[String: Any]] {
        let fileManager = FileManager.default
        guard let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        var results = [[String: Any]]()
        
        do {
            let items = try fileManager.contentsOfDirectory(at: docsDir, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey], options: [.skipsHiddenFiles])
            for item in items {
                let resources = try item.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey])
                results.append([
                    "name": item.lastPathComponent,
                    "path": item.path,
                    "sizeBytes": resources.fileSize ?? 0,
                    "lastModified": resources.contentModificationDate?.timeIntervalSince1970 ?? 0 * 1000,
                    "mimeType": "application/octet-stream"
                ])
            }
        } catch {
            print("Error scanning directory: \(error)")
        }
        return results
    }
    
    private func requestPermission(type: String, result: @escaping FlutterResult) {
        if type == "notification" {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                result(granted)
            }
        } else if type == "storage" {
            result(true)
        } else {
            result(FlutterError(code: "UNSUPPORTED", message: "Permission type not supported on iOS", details: nil))
        }
    }
}
