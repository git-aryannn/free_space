import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target = r"""        default:
            result\(FlutterMethodNotImplemented\)
        default:"""
replacement = r"""        default:"""

content = re.sub(target, replacement, content)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
