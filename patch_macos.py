import re

with open("macos/Runner/MainFlutterWindow.swift", "r") as f:
    content = f.read()

target = r"""    RegisterGeneratedPlugins\(registry: flutterViewController\)

    super\.awakeFromNib\(\)"""
replacement = r"""    RegisterGeneratedPlugins(registry: flutterViewController)
    FreeSpacePlatformChannel.register(with: flutterViewController.registrar(forPlugin: "FreeSpacePlatformChannel"))

    super.awakeFromNib()"""

content = re.sub(target, replacement, content)

with open("macos/Runner/MainFlutterWindow.swift", "w") as f:
    f.write(content)
