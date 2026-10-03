import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target = r"""    private func authorizedScanRoot\(\) -> URL\? \{.*?return resolvedUrl.*?\}"""
replacement = r"""    private func authorizedScanRoot() -> URL? {
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
    }"""

content = re.sub(target, replacement, content, flags=re.DOTALL)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
