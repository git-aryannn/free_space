import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target = r"""        case "setScanRoot":
            if let args = call.arguments as\? \[String: Any\], let path = args\["path"\] as\? String \{
                let url = URL\(fileURLWithPath: path\)
                self\.activeScanRoot = url"""

replacement = r"""        case "setScanRoot":
            if let args = call.arguments as? [String: Any], let path = args["path"] as? String {
                do { try path.write(toFile: "/tmp/freespace_set_root.txt", atomically: true, encoding: .utf8) } catch {}
                let url = URL(fileURLWithPath: path)
                self.activeScanRoot = url"""

content = re.sub(target, replacement, content)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
