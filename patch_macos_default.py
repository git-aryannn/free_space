import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target = r"""            if let args = call\.arguments as\? \[String: Any\], let type = args\["type"\] as\? String \{
                requestPermission\(type: type, result: result\)
            \} else \{
                result\(FlutterError\(code: "INVALID_ARGUMENT", message: "Permission type is required", details: nil\)\)
            \}"""
replacement = r"""            if let args = call.arguments as? [String: Any], let type = args["type"] as? String {
                requestPermission(type: type, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Permission type is required", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)"""

content = re.sub(target, replacement, content)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
