import Foundation
import FlutterMacOS
import UserNotifications

public class FreeSpacePlatformChannel: NSObject, FlutterPlugin {
    private let scanRootBookmarkKey = "systemScanRootBookmark"
    private let trashAccessBookmarksKey = "systemTrashAccessBookmarks"
    private var activeScanRoot: URL?
    private var activeScanSelections = [URL]()
    private var activeTrashFolders = [URL]()
    private var loadedTrashBookmarks = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.freespace.app/platform", binaryMessenger: registrar.messenger)
        let instance = FreeSpacePlatformChannel()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getStorageInfo":
            result(getStorageInfo())
        case "getScanRoot":
            result(authorizedScanRoot()?.path)
        case "setScanRoot":
            if let args = call.arguments as? [String: Any], let path = args["path"] as? String {
                let url = URL(fileURLWithPath: path)
                // If it already matches the active root (which might have security scope), don't overwrite it
                if self.activeScanRoot?.path != url.path {
                    self.activeScanRoot = url
                    do {
                        let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                        UserDefaults.standard.set(bookmarkData, forKey: self.scanRootBookmarkKey)
                    } catch {
                        if let regularBookmark = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) {
                            UserDefaults.standard.set(regularBookmark, forKey: self.scanRootBookmarkKey)
                        }
                    }
                }
                result(true)
            } else {
                result(false)
            }
        case "getScanRootPath":
            let path = authorizedScanRoot()?.path
            do { try path?.write(toFile: "/tmp/freespace_root.txt", atomically: true, encoding: .utf8) } catch {}
            result(path)
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
            result(true)
        case "selectScanRoot":
            chooseScanRoot(completion: result)
        case "selectScanItems":
            chooseScanItems(completion: result)
        case "listSystemTrashItems":
            let requestAccess = (call.arguments as? [String: Any])?["requestAccess"] as? Bool ?? false
            listSystemTrashItems(requestAccess: requestAccess, result: result)
        case "showInFileManager":
            if let args = call.arguments as? [String: Any],
               let path = args["path"] as? String {
                let url = URL(fileURLWithPath: path)
                NSWorkspace.shared.activateFileViewerSelecting([url])
                result(true)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Path is required.",
                    details: nil
                ))
            }
        case "moveItemsToSystemTrash":
            guard let args = call.arguments as? [String: Any],
                  let paths = args["paths"] as? [String] else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Item paths are required.",
                    details: nil
                ))
                return
            }
            moveItemsToTrash(paths, result: result)
        case "restoreItemsFromSystemTrash":
            guard let args = call.arguments as? [String: Any],
                  let items = args["items"] as? [[String: Any]] else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "Items to restore are required.",
                    details: nil
                ))
                return
            }
            restoreItemsFromTrash(items, result: result)
        case "putBackSystemTrashItems":
            guard let args = call.arguments as? [String: Any],
                  let paths = args["paths"] as? [String] else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "System Trash item paths are required.",
                    details: nil
                ))
                return
            }
            putBackSystemTrashItems(paths, result: result)
        case "permanentlyDeleteItemsFromSystemTrash":
            guard let args = call.arguments as? [String: Any],
                  let paths = args["paths"] as? [String] else {
                result(FlutterError(
                    code: "INVALID_ARGUMENT",
                    message: "System Trash paths are required.",
                    details: nil
                ))
                return
            }
            permanentlyDeleteItemsFromTrash(paths, result: result)
        case "scanDirectory":
            if let args = call.arguments as? [String: Any], let path = args["path"] as? String {
                result(scanDirectory(path: path))
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Path is required", details: nil))
            }
        case "requestPermission":
            if let args = call.arguments as? [String: Any], let type = args["type"] as? String {
                requestPermission(type: type, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Permission type is required", details: nil))
            }
        default:
            result(FlutterError(code: "UNSUPPORTED", message: "This feature is not available on macOS.", details: nil))
        }
    }

    private func moveItemsToTrash(
        _ paths: [String],
        result: @escaping FlutterResult
    ) {
        ensureTrashAccess(for: paths) { authorizedFolders, permissionError in
            guard let authorizedFolders else {
                result(FlutterError(
                    code: "TRASH_PERMISSION_DENIED",
                    message: permissionError ?? "Permission to access the selected items was not granted.",
                    details: nil
                ))
                return
            }

            var failures = [String: String]()
            let fileManager = FileManager.default
            var approvedItems = [(path: String, url: URL)]()

            for path in paths {
                let source = URL(fileURLWithPath: path)
                let standardizedPath = source.standardizedFileURL.path
                guard authorizedFolders.contains(where: {
                    Self.contains(standardizedPath, in: $0.standardizedFileURL.path)
                }) else {
                    failures[path] = "The item is outside the folders you approved."
                    continue
                }
                guard fileManager.fileExists(atPath: path) else {
                    failures[path] = "The item no longer exists."
                    continue
                }

                approvedItems.append((path: path, url: source))
            }

            DispatchQueue.global(qos: .userInitiated).async {
                guard !approvedItems.isEmpty else {
                    self.completeTrashMove(
                        moved: [:],
                        failures: failures,
                        requestedPaths: paths,
                        result: result
                    )
                    return
                }

                NSWorkspace.shared.recycle(approvedItems.map(\.url)) { trashLocations, error in
                    var moved = [String: Any]()
                    for item in approvedItems {
                        if let trashURL = trashLocations[item.url] {
                            self.saveTrashItemAccessBookmark(for: trashURL)
                            moved[item.path] = trashURL.path
                        } else {
                            let message = error?.localizedDescription
                                ?? "macOS did not confirm moving this item to Trash."
                            failures[item.path] = message
                            NSLog(
                                "Unable to move item to macOS Trash: %@: %@",
                                item.path,
                                message
                            )
                        }
                    }

                    self.completeTrashMove(
                        moved: moved,
                        failures: failures,
                        requestedPaths: paths,
                        result: result
                    )
                }
            }
        }
    }

    private func saveTrashItemAccessBookmark(for url: URL) {
        let trashItemURL = url.standardizedFileURL
        guard !activeTrashFolders.contains(where: {
            $0.standardizedFileURL.path == trashItemURL.path
        }) else {
            return
        }

        do {
            let bookmark = try trashItemURL.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            guard trashItemURL.startAccessingSecurityScopedResource() else {
                NSLog(
                    "Unable to retain access to trashed item for restore: %@",
                    trashItemURL.path
                )
                return
            }
            activeTrashFolders.append(trashItemURL)
            var bookmarks = UserDefaults.standard
                .array(forKey: trashAccessBookmarksKey) as? [Data] ?? []
            bookmarks.append(bookmark)
            UserDefaults.standard.set(bookmarks, forKey: trashAccessBookmarksKey)
        } catch {
            NSLog(
                "Unable to save restore access for trashed item %@: %@",
                trashItemURL.path,
                error.localizedDescription
            )
        }
    }

    private func ensureTrashAccess(
        for paths: [String],
        forceRequest: Bool = false,
        forSystemTrashListing: Bool = false,
        forRestore: Bool = false,
        completion: @escaping ([URL]?, String?) -> Void
    ) {
        if forceRequest {
            requestTrashFolderAccess(
                for: paths,
                forSystemTrashListing: forSystemTrashListing,
                forRestore: forRestore,
                forceRequest: true,
                completion: completion
            )
            return
        }

        loadTrashAccessBookmarksIfNeeded()

        guard !paths.isEmpty,
              paths.allSatisfy({ path in
                  let url = URL(fileURLWithPath: path).standardizedFileURL
                  if forRestore {
                      return activeTrashFolders.contains {
                          let grantedPath = $0.standardizedFileURL.path
                          if Self.isTrashPath(url.path) {
                              return Self.hasAccess(to: url.path, from: grantedPath)
                          }
                          return Self.contains(
                              url.deletingLastPathComponent().path,
                              in: grantedPath
                          )
                      }
                  }
                  return activeTrashFolders.contains {
                      Self.contains(url.path, in: $0.standardizedFileURL.path)
                  }
              }) else {
            requestTrashFolderAccess(
                for: paths,
                forSystemTrashListing: forSystemTrashListing,
                forRestore: forRestore,
                completion: completion
            )
            return
        }
        completion(activeTrashFolders, nil)
    }

    private func loadTrashAccessBookmarksIfNeeded() {
        guard !loadedTrashBookmarks else {
            return
        }
        loadedTrashBookmarks = true
        let bookmarks = UserDefaults.standard
            .array(forKey: trashAccessBookmarksKey) as? [Data] ?? []
        var validBookmarks = [Data]()

        for bookmark in bookmarks {
            do {
                var isStale = false
                let folder = try URL(
                    resolvingBookmarkData: bookmark,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                guard folder.startAccessingSecurityScopedResource() else {
                    continue
                }
                activeTrashFolders.append(folder)
                if isStale {
                    validBookmarks.append(try folder.bookmarkData(
                        options: .withSecurityScope,
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    ))
                } else {
                    validBookmarks.append(bookmark)
                }
            } catch {
                NSLog("Unable to restore Trash folder access: %@", error.localizedDescription)
            }
        }
        UserDefaults.standard.set(validBookmarks, forKey: trashAccessBookmarksKey)
    }

    private func requestTrashFolderAccess(
        for paths: [String],
        forSystemTrashListing: Bool = false,
        forRestore: Bool = false,
        forceRequest: Bool = false,
        completion: @escaping ([URL]?, String?) -> Void
    ) {
        loadTrashAccessBookmarksIfNeeded()
        let requestedPaths = Array(Set(paths.compactMap { path -> String? in
            let url = URL(fileURLWithPath: path).standardizedFileURL
            if forSystemTrashListing {
                return url.deletingLastPathComponent().path
            }
            if forRestore {
                if Self.isTrashPath(url.path) {
                    if !forceRequest,
                       activeTrashFolders.contains(where: {
                           Self.hasAccess(
                               to: url.path,
                               from: $0.standardizedFileURL.path
                           )
                       }) {
                        return nil
                    }
                    return Self.trashAccessRoot(for: url.path)
                        ?? url.deletingLastPathComponent().path
                }
                let parentPath = url.deletingLastPathComponent().path
                if !forceRequest,
                   activeTrashFolders.contains(where: {
                       Self.contains(parentPath, in: $0.standardizedFileURL.path)
                   }) {
                    return nil
                }
                return parentPath
            }
            return url.deletingLastPathComponent().path
        })).sorted()
        var grantedFolders = [URL]()
        var savedBookmarks = [Data]()

        func requestFolder(at index: Int) {
            guard index < requestedPaths.count else {
                self.activeTrashFolders.append(contentsOf: grantedFolders)
                let existingBookmarks = UserDefaults.standard
                    .array(forKey: self.trashAccessBookmarksKey) as? [Data] ?? []
                UserDefaults.standard.set(
                    existingBookmarks + savedBookmarks,
                    forKey: self.trashAccessBookmarksKey
                )
                completion(self.activeTrashFolders, nil)
                return
            }

            let requestedURL = URL(fileURLWithPath: requestedPaths[index])
                .standardizedFileURL
            if !forceRequest,
               !forSystemTrashListing,
               (self.activeTrashFolders + grantedFolders).contains(where: {
                   Self.contains(requestedURL.path, in: $0.standardizedFileURL.path)
               }) {
                requestFolder(at: index + 1)
                return
            }

            DispatchQueue.main.async {
                let panel = NSOpenPanel()
                panel.title = forSystemTrashListing
                    ? "Allow Access to macOS Trash"
                    : forRestore
                        ? "Allow Access to Restore Item"
                        : "Allow Access to Move Item to Trash"
                panel.message = forSystemTrashListing
                    ? "Select your Home folder “\(requestedURL.lastPathComponent)”. Free Space will access the hidden Trash folder automatically."
                    : forRestore
                        ? "Select the visible folder “\(requestedURL.lastPathComponent)” to allow Free Space to restore the item. Do not select the hidden .Trash folder."
                        : "Select “\(requestedURL.lastPathComponent)” to allow the app to move the item to Trash."
                panel.prompt =
                    forSystemTrashListing
                        ? "Allow Trash Access"
                        : forRestore ? "Allow Restore" : "Allow Access"
                panel.canChooseFiles = false
                panel.canChooseDirectories = true
                panel.allowsMultipleSelection = false
                panel.showsHiddenFiles = !forRestore
                panel.directoryURL = requestedURL.deletingLastPathComponent()

                panel.begin { response in
                    guard response == .OK,
                          let selectedURL = panel.url?.standardizedFileURL else {
                        completion(
                            nil,
                            "Access was not granted to \(requestedURL.path). Retry and select the visible containing folder; do not select .Trash."
                        )
                        return
                    }
                    guard selectedURL == requestedURL else {
                        completion(
                            nil,
                            "Select “\(requestedURL.lastPathComponent)” itself to continue."
                        )
                        return
                    }

                    do {
                        let bookmark = try selectedURL.bookmarkData(
                            options: .withSecurityScope,
                            includingResourceValuesForKeys: nil,
                            relativeTo: nil
                        )
                        guard selectedURL.startAccessingSecurityScopedResource() else {
                            throw NSError(
                                domain: "FreeSpaceTrashAccess",
                                code: 1,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "macOS did not grant access to \(selectedURL.path)."
                                ]
                            )
                        }
                        grantedFolders.append(selectedURL)
                        savedBookmarks.append(bookmark)
                        requestFolder(at: index + 1)
                    } catch {
                        completion(nil, error.localizedDescription)
                    }
                }
            }
        }

        requestFolder(at: 0)
    }

    private static func contains(_ path: String, in folderPath: String) -> Bool {
        let normalizedFolder = folderPath.hasSuffix("/") ? folderPath : folderPath + "/"
        return path == folderPath || path.hasPrefix(normalizedFolder)
    }

    private static func hasAccess(to path: String, from scopePath: String) -> Bool {
        path == scopePath || contains(path, in: scopePath)
    }

    private static func trashAccessRoot(for path: String) -> String? {
        let components = URL(fileURLWithPath: path).standardizedFileURL.path
            .split(separator: "/")
            .map(String.init)
        guard let trashIndex = components.firstIndex(where: {
            $0 == ".Trash" || $0 == ".Trashes"
        }) else {
            return nil
        }
        return "/" + components[..<trashIndex].joined(separator: "/")
    }

    private static func isTrashPath(_ path: String) -> Bool {
        URL(fileURLWithPath: path).standardizedFileURL.path
            .split(separator: "/")
            .contains { $0 == ".Trash" || $0 == ".Trashes" }
    }

    private func completeTrashMove(
        moved: [String: Any],
        failures: [String: String],
        requestedPaths: [String],
        result: @escaping FlutterResult
    ) {
        DispatchQueue.main.async {
            if moved.isEmpty && !requestedPaths.isEmpty {
                let details = failures
                    .map { "\($0.key): \($0.value)" }
                    .joined(separator: "\n")
                result(FlutterError(
                    code: "TRASH_FAILED",
                    message: "macOS could not move the selected items to Trash.",
                    details: details
                ))
            } else {
                result(moved)
            }
        }
    }

    private func restoreItemsFromTrash(
        _ items: [[String: Any]],
        result: @escaping FlutterResult
    ) {
        guard !items.isEmpty else {
            result(true)
            return
        }

        for item in items {
            guard let originalPath = item["originalPath"] as? String,
                  !originalPath.isEmpty,
                  let trashPath = item["trashPath"] as? String else {
                result(FlutterError(
                    code: "RESTORE_FAILED",
                    message: "The saved original and Trash paths are required to restore this item.",
                    details: item["originalPath"]
                ))
                return
            }
            guard Self.isTrashPath(trashPath) else {
                result(FlutterError(
                    code: "RESTORE_FAILED",
                    message: "The saved item path is not inside a recognized macOS Trash folder.",
                    details: trashPath
                ))
                return
            }
        }

        let restorePaths = items.flatMap { item in
            [item["trashPath"] as? String, item["originalPath"] as? String]
                .compactMap { $0 }
        }
        loadTrashAccessBookmarksIfNeeded()
        for trashPath in items.compactMap({ $0["trashPath"] as? String }) {
            let trashURL = URL(fileURLWithPath: trashPath).standardizedFileURL
            let hasParentScope = activeTrashFolders.contains {
                Self.contains(trashURL.path, in: $0.standardizedFileURL.path)
            }
            if hasParentScope {
                saveTrashItemAccessBookmark(for: trashURL)
            }
        }
        ensureTrashAccess(for: restorePaths, forRestore: true) { authorizedFolders, accessError in
            guard authorizedFolders != nil else {
                result(FlutterError(
                    code: "RESTORE_ACCESS_DENIED",
                    message: accessError ?? "Allow access to the selected Trash item and its original destination folder.",
                    details: restorePaths
                ))
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let fileManager = FileManager.default
                var failures = [String]()
                for item in items {
                    guard let originalPath = item["originalPath"] as? String,
                          let trashPath = item["trashPath"] as? String else {
                        continue
                    }
                    let originalURL = URL(fileURLWithPath: originalPath)
                    let trashURL = URL(fileURLWithPath: trashPath)
                    do {
                        guard fileManager.fileExists(atPath: trashURL.path) else {
                            throw NSError(
                                domain: "FreeSpaceTrashRestore",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "The item is no longer in macOS Trash."]
                            )
                        }
                        guard fileManager.fileExists(
                            atPath: originalURL.deletingLastPathComponent().path
                        ) else {
                            throw NSError(
                                domain: "FreeSpaceTrashRestore",
                                code: 2,
                                userInfo: [NSLocalizedDescriptionKey: "The original destination folder no longer exists."]
                            )
                        }
                        guard !fileManager.fileExists(atPath: originalURL.path) else {
                            throw NSError(
                                domain: "FreeSpaceTrashRestore",
                                code: 3,
                                userInfo: [NSLocalizedDescriptionKey: "An item with this name already exists at the original location."]
                            )
                        }
                        try fileManager.moveItem(at: trashURL, to: originalURL)
                    } catch {
                        failures.append("\(originalPath): \(error.localizedDescription)")
                    }
                }

                DispatchQueue.main.async {
                    if failures.isEmpty {
                        result(true)
                    } else {
                        result(FlutterError(
                            code: "RESTORE_FAILED",
                            message: "Could not restore one or more items from macOS Trash.",
                            details: failures.joined(separator: "\n")
                        ))
                    }
                }
            }
        }
    }

    private func permanentlyDeleteItemsFromTrash(
        _ paths: [String],
        result: @escaping FlutterResult
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            var deleted = [String]()
            var failures = [String]()
            for path in paths {
                guard Self.isTrashPath(path) else {
                    failures.append("\(path): Not a recognized system Trash location.")
                    continue
                }
                let pathLiteral = Self.appleScriptString(path)
                let script = """
                tell application id "com.apple.finder"
                    set trashItem to (POSIX file \(pathLiteral)) as alias
                    delete trashItem
                end tell
                """
                do {
                    _ = try Self.executeFinderScript(script)
                    deleted.append(path)
                } catch {
                    failures.append("\(path): \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                if deleted.isEmpty && !paths.isEmpty {
                    result(FlutterError(
                        code: "PERMANENT_DELETE_FAILED",
                        message: "macOS could not permanently delete expired items from Trash.",
                        details: failures.joined(separator: "\n")
                    ))
                } else {
                    result(deleted)
                }
            }
        }
    }

    private func putBackSystemTrashItems(
        _ paths: [String],
        result: @escaping FlutterResult
    ) {
        guard paths.allSatisfy(Self.isTrashPath) else {
            result(FlutterError(
                code: "RESTORE_FAILED",
                message: "Only items currently inside macOS Trash can be put back.",
                details: paths
            ))
            return
        }
        guard !paths.isEmpty else {
            result([String: String]())
            return
        }

        let itemList = paths.map(Self.appleScriptString).joined(separator: ", ")
        let script = """
        set trashItemPaths to {\(itemList)}
        set restoredItems to {}
        tell application id "com.apple.finder"
            activate
            open trash
            repeat with itemPath in trashItemPaths
                set selectedTrashItem to ((POSIX file (itemPath as text)) as alias)
                select selectedTrashItem
                tell application "System Events"
                    tell process "Finder"
                        set frontmost to true
                        key code 51 using {command down}
                    end tell
                end tell
                set restoredPath to POSIX path of (selectedTrashItem as alias)
                repeat 20 times
                    if restoredPath does not contain "/.Trash/" and ¬
                        restoredPath does not contain "/.Trashes/" then
                        exit repeat
                    end if
                    delay 0.25
                    set restoredPath to POSIX path of (selectedTrashItem as alias)
                end repeat
                if restoredPath does not contain "/.Trash/" and ¬
                    restoredPath does not contain "/.Trashes/" then
                    set end of restoredItems to {itemPath as text, restoredPath}
                end if
            end repeat
        end tell
        return restoredItems
        """

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let descriptor = try Self.executeFinderScript(script)
                var restored = [String: String]()
                if descriptor.numberOfItems > 0 {
                    for index in 1...descriptor.numberOfItems {
                        guard let mapping = descriptor.atIndex(index),
                              mapping.numberOfItems >= 2,
                              let trashPath = mapping.atIndex(1)?.stringValue,
                              let restoredPath = mapping.atIndex(2)?.stringValue else {
                            continue
                        }
                        let standardizedRestoredPath =
                            URL(fileURLWithPath: restoredPath).standardizedFileURL.path
                        if !Self.isTrashPath(standardizedRestoredPath) {
                            restored[trashPath] = standardizedRestoredPath
                        }
                    }
                }

                DispatchQueue.main.async {
                    result(restored)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "RESTORE_FAILED",
                        message: "Finder could not put back the selected Trash items. Check Finder Automation and Accessibility permissions.",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }

    private func listSystemTrashItems(
        requestAccess: Bool,
        result: @escaping FlutterResult
    ) {
        _ = requestAccess
        DispatchQueue.global(qos: .userInitiated).async {
            let script = """
            set trashItems to {}
            tell application id "com.apple.finder"
                set itemCount to count of every item of trash
                repeat with itemIndex from 1 to itemCount
                    set trashItem to item itemIndex of trash
                    set itemName to name of trashItem as text
                    set itemPath to POSIX path of (trashItem as alias)
                    set itemSize to size of trashItem as text
                    set end of trashItems to {itemName, itemPath, itemSize}
                end repeat
            end tell
            return trashItems
            """
            do {
                let descriptor = try Self.executeFinderScript(script)
                let items: [[String: Any]] = descriptor.numberOfItems > 0
                    ? (1...descriptor.numberOfItems).compactMap { index in
                    guard let row = descriptor.atIndex(index),
                          row.numberOfItems >= 3,
                          let name = row.atIndex(1)?.stringValue,
                          let path = row.atIndex(2)?.stringValue,
                          let sizeText = row.atIndex(3)?.stringValue else {
                        return nil
                    }
                    return [
                        "name": name,
                        "trashPath": path,
                        "sizeBytes": Int64(sizeText) ?? 0,
                    ]
                }
                    : []
                DispatchQueue.main.async {
                    result(items)
                }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(
                        code: "SYSTEM_TRASH_ACCESS_DENIED",
                        message: "Could not read macOS Trash through Finder.",
                        details: error.localizedDescription
                    ))
                }
            }
        }
    }

    private static func appleScriptString(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        return "\"\(escaped)\""
    }

    private static func executeFinderScript(
        _ source: String
    ) throws -> NSAppleEventDescriptor {
        guard let script = NSAppleScript(source: source) else {
            throw NSError(
                domain: "FreeSpaceFinder",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not prepare the Finder request."]
            )
        }
        var errorInfo: NSDictionary?
        let descriptor = script.executeAndReturnError(&errorInfo)
        if let errorInfo {
            let message = errorInfo["NSAppleScriptErrorMessage"] as? String
                ?? "Finder did not complete the request."
            throw NSError(
                domain: "FreeSpaceFinder",
                code: (errorInfo["NSAppleScriptErrorNumber"] as? Int) ?? 2,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
        }
        return descriptor
    }

    private func getStorageInfo() -> [String: Any] {
        let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
            let total = Int64(values.volumeTotalCapacity ?? 0)
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
    
    private func scanDirectory(path: String) -> [[String: Any]] {
        let fileManager = FileManager.default
        var results = [[String: Any]]()
        let rootURL = URL(fileURLWithPath: path)
        
        do {
            let items = try fileManager.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey], options: [.skipsHiddenFiles])
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
            chooseScanRoot { selectedRoot in
                result(selectedRoot != nil)
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED", message: "Permission type not supported on macOS", details: nil))
        }
    }

    private func chooseScanRoot(completion: @escaping (String?) -> Void) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.title = "Choose the folder to scan"
            panel.message = "Choose a folder to include its accessible files in Permanent Storage."
            panel.prompt = "Allow Access"
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = false
            panel.directoryURL = URL(fileURLWithPath: "/")

            panel.begin { response in
                guard response == .OK, let url = panel.url else {
                    completion(nil)
                    return
                }

                do {
                    let bookmark = try url.bookmarkData(
                        options: .withSecurityScope,
                        includingResourceValuesForKeys: nil,
                        relativeTo: nil
                    )
                    UserDefaults.standard.set(bookmark, forKey: self.scanRootBookmarkKey)
                    guard url.startAccessingSecurityScopedResource() else {
                        completion(nil)
                        return
                    }
                    self.activeScanRoot = url
                    completion(url.path)
                } catch {
                    NSLog("Unable to save access to the selected scan folder: %@", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    private func chooseScanItems(completion: @escaping ([String]?) -> Void) {
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.title = "Choose Files or Folders to Scan"
            panel.message = "Select one or more files and folders to add to Permanent Storage."
            panel.prompt = "Scan Selected"
            panel.canChooseFiles = true
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = true

            panel.begin { response in
                guard response == .OK, !panel.urls.isEmpty else {
                    completion(nil)
                    return
                }

                var authorizedURLs = [URL]()
                do {
                    for url in panel.urls {
                        guard url.startAccessingSecurityScopedResource() else {
                            throw NSError(
                                domain: "FreeSpaceScanAccess",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "macOS did not grant access to \(url.path)."]
                            )
                        }
                        authorizedURLs.append(url)
                    }
                    self.activeScanSelections.append(contentsOf: authorizedURLs)
                    self.activeScanRoot = panel.urls[0]
                    if let bookmark = try? panel.urls[0].bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
                        UserDefaults.standard.set(bookmark, forKey: self.scanRootBookmarkKey)
                    }
                    completion(panel.urls.map(\.path))
                } catch {
                    for url in authorizedURLs {
                        url.stopAccessingSecurityScopedResource()
                    }
                    NSLog("Unable to access selected scan items: %@", error.localizedDescription)
                    completion(nil)
                }
            }
        }
    }

    private func authorizedScanRoot() -> URL? {
        if let activeScanRoot {
            return activeScanRoot
        }
        guard let bookmark = UserDefaults.standard.data(forKey: scanRootBookmarkKey) else {
            return nil
        }
        
        var isStale = false
        var resolvedUrl: URL?
        do {
            resolvedUrl = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        } catch {
            resolvedUrl = try? URL(resolvingBookmarkData: bookmark, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
        }
        guard let url = resolvedUrl else { return nil }
        
        _ = url.startAccessingSecurityScopedResource()
        if isStale {
            let data = (try? url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)) 
                       ?? (try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil))
            if let data = data {
                UserDefaults.standard.set(data, forKey: scanRootBookmarkKey)
            }
        }
        self.activeScanRoot = url
        return url
    }
}
