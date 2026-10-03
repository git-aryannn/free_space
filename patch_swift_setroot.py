import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target = r"""        case "setScanRoot":
            if let args = call\.arguments as\? \[String: Any\], let path = args\["path"\] as\? String \{
                UserDefaults\.standard\.set\(path, forKey: "mock_scan_root"\)
                result\(true\)
            \} else \{
                result\(false\)
            \}"""

replacement = r"""        case "setScanRoot":
            if let args = call.arguments as? [String: Any], let path = args["path"] as? String {
                let url = URL(fileURLWithPath: path)
                self.activeScanRoot = url
                do {
                    let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                    UserDefaults.standard.set(bookmarkData, forKey: self.scanRootBookmarkKey)
                } catch {
                    // Ignore if it fails, activeScanRoot is set
                }
                result(true)
            } else {
                result(false)
            }"""

content = re.sub(target, replacement, content)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
