import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target = r"""        case "getScanRootPath":
            result\(authorizedScanRoot\(\)\?\.path\)"""

replacement = r"""        case "getScanRootPath":
            let path = authorizedScanRoot()?.path
            do { try path?.write(toFile: "/tmp/freespace_root.txt", atomically: true, encoding: .utf8) } catch {}
            result(path)"""

content = re.sub(target, replacement, content)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
