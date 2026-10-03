import re

with open("macos/Runner/AppDelegate.swift", "r") as f:
    content = f.read()

target = r"""  override func applicationDidFinishLaunching\(_ notification: Notification\) \{
    let controller : FlutterViewController = mainFlutterWindow\?\.contentViewController as! FlutterViewController
    FreeSpacePlatformChannel\.register\(with: controller\.registrar\(forPlugin: "FreeSpacePlatformChannel"\)\)
    super\.applicationDidFinishLaunching\(notification\)
  \}"""

replacement = r"""  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
  }"""

content = re.sub(target, replacement, content)

with open("macos/Runner/AppDelegate.swift", "w") as f:
    f.write(content)
