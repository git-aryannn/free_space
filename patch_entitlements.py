import re

with open("macos/Runner/Release.entitlements", "r") as f:
    content = f.read()

target = r"""	<key>com.apple.security.app-sandbox</key>
	<true/>"""

replacement = r"""	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.cs.disable-library-validation</key>
	<true/>"""

content = re.sub(target, replacement, content)

with open("macos/Runner/Release.entitlements", "w") as f:
    f.write(content)
