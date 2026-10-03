import re

with open("lib/main.dart", "r") as f:
    content = f.read()

target = r"""  if \(mode == DetectionMode\.efficientBackground\) \{
    registerEfficientBackgroundTasks\(\);
  \}"""

replacement = r"""  if (!Platform.isMacOS && !Platform.isWindows && !Platform.isLinux) {
    if (mode == DetectionMode.efficientBackground) {
      registerEfficientBackgroundTasks();
    }
  }"""

content = re.sub(target, replacement, content)

with open("lib/main.dart", "w") as f:
    f.write(content)
