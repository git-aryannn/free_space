import re

with open("lib/main.dart", "r") as f:
    content = f.read()

target = r"""  if \(mode == DetectionMode\.liveMonitoring\) \{
    FlutterBackgroundService\(\)\.startService\(\);
  \} else \{
    FlutterBackgroundService\(\)\.invoke\("stopService"\);
  \}"""

replacement = r"""  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    if (mode == DetectionMode.liveMonitoring) {
      FlutterBackgroundService().startService();
    } else {
      FlutterBackgroundService().invoke("stopService");
    }
  }"""

content = re.sub(target, replacement, content)

with open("lib/main.dart", "w") as f:
    f.write(content)
