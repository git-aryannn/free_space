import re

with open("macos/Runner/FreeSpacePlatformChannel.swift", "r") as f:
    content = f.read()

target = r"""        self\.activeScanRoot = url
        return url
    \} catch \{
            NSLog\("Unable to restore access to the selected scan folder: %@", error\.localizedDescription\)
            return nil
        \}
    \}
\}"""

replacement = r"""        self.activeScanRoot = url
        return url
    }
}"""

content = re.sub(target, replacement, content)

with open("macos/Runner/FreeSpacePlatformChannel.swift", "w") as f:
    f.write(content)
