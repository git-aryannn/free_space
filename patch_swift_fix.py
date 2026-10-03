import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target1 = r"""        case "setScanRoot":
            if let args = call.arguments as\? \[String: Any\], let path = args\["path"\] as\? String \{
                do \{ try path\.write\(toFile: "/tmp/freespace_set_root.txt", atomically: true, encoding: \.utf8\) \} catch \{\}
                let url = URL\(fileURLWithPath: path\)
                self\.activeScanRoot = url
                do \{
                    let bookmarkData = try url\.bookmarkData\(options: \.withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil\)
                    UserDefaults\.standard\.set\(bookmarkData, forKey: self\.scanRootBookmarkKey\)
                \} catch \{
                    // Ignore if it fails, activeScanRoot is set
                \}
                result\(true\)"""

replacement1 = r"""        case "setScanRoot":
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
                result(true)"""

content = re.sub(target1, replacement1, content)

target2 = r"""    private func authorizedScanRoot\(\) -> URL\? \{
        if let activeScanRoot \{
            return activeScanRoot
        \}
        guard let bookmark = UserDefaults\.standard\.data\(forKey: scanRootBookmarkKey\) else \{
            return nil
        \}
        
        do \{
            var isStale = false
            let url = try URL\(
                resolvingBookmarkData: bookmark,
                options: \.withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            \)"""

replacement2 = r"""    private func authorizedScanRoot() -> URL? {
        if let activeScanRoot {
            return activeScanRoot
        }
        guard let bookmark = UserDefaults.standard.data(forKey: scanRootBookmarkKey) else {
            return nil
        }
        
        do {
            var isStale = false
            var url: URL?
            do {
                url = try URL(
                    resolvingBookmarkData: bookmark,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
            } catch {
                url = try URL(
                    resolvingBookmarkData: bookmark,
                    options: [],
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
            }
            guard let resolvedUrl = url else { return nil }"""

content = re.sub(target2, replacement2, content)

target3 = r"""            guard url\.startAccessingSecurityScopedResource\(\) else \{
                return nil
            \}
            if isStale \{
                let renewedBookmark = try url\.bookmarkData\(
                    options: \.withSecurityScope,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                \)
                UserDefaults\.standard\.set\(renewedBookmark, forKey: scanRootBookmarkKey\)
            \}
            activeScanRoot = url
            return url"""

replacement3 = r"""            _ = resolvedUrl.startAccessingSecurityScopedResource()
            if isStale {
                if let renewedBookmark = try? resolvedUrl.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) ?? resolvedUrl.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) {
                    UserDefaults.standard.set(renewedBookmark, forKey: scanRootBookmarkKey)
                }
            }
            activeScanRoot = resolvedUrl
            return resolvedUrl"""

content = re.sub(target3, replacement3, content)

target4 = r"""                    self\.activeScanSelections\.append\(contentsOf: authorizedURLs\)
                    completion\(panel\.urls\.map\(\\\.path\)\)"""

replacement4 = r"""                    self.activeScanSelections.append(contentsOf: authorizedURLs)
                    self.activeScanRoot = panel.urls[0]
                    if let bookmark = try? panel.urls[0].bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil) {
                        UserDefaults.standard.set(bookmark, forKey: self.scanRootBookmarkKey)
                    }
                    completion(panel.urls.map(\.path))"""

content = re.sub(target4, replacement4, content)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
