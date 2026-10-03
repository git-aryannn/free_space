import re

with open("android/app/src/main/AndroidManifest.xml", "r") as f:
    content = f.read()

content = content.replace('android:label="free_space"', 'android:label="Free Space"')

with open("android/app/src/main/AndroidManifest.xml", "w") as f:
    f.write(content)

