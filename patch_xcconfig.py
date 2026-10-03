import re

with open("macos/Runner/Configs/AppInfo.xcconfig", "r") as f:
    content = f.read()

target = r"PRODUCT_NAME = free_space"
replacement = r"PRODUCT_NAME = Free Space"

content = re.sub(target, replacement, content)

with open("macos/Runner/Configs/AppInfo.xcconfig", "w") as f:
    f.write(content)
