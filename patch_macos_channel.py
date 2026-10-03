import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target = r"""        case "getScanRoot":
            result\(authorizedScanRoot\(\)\?\.path\)"""
replacement = r"""        case "getScanRoot":
            result(authorizedScanRoot()?.path)
        case "setScanRoot":
            if let args = call.arguments as? [String: Any], let path = args["path"] as? String {
                UserDefaults.standard.set(path, forKey: "mock_scan_root")
                result(true)
            } else {
                result(false)
            }
        case "getScanRootPath":
            result(authorizedScanRoot()?.path)
        case "hasAllFilesAccess":
            result(authorizedScanRoot() != nil)
        case "requestAllFilesAccess":
            chooseScanRoot { selected in result(selected != nil) }
        case "getDownloadsPath":
            result(FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.path)
        case "getExternalStorageRootPath":
            result(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path)
        case "scanDocumentTree":
            if let args = call.arguments as? [String: Any], let treeUri = args["treeUri"] as? String {
                let items = self.scanDirectory(path: treeUri)
                result(["items": items, "inaccessibleDirectories": 0])
            } else {
                result(["items": [], "inaccessibleDirectories": 0])
            }
        case "hasNotificationPermission":
            result(true)
        case "requestNotificationPermission":
            result(true)
        case "startFileObserver":
            result(true)"""

content = re.sub(target, replacement, content)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
