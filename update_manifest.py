import re

with open("android/app/src/main/AndroidManifest.xml", "r") as f:
    content = f.read()

permissions = """
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
"""

content = content.replace('<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />', '<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n' + permissions)

with open("android/app/src/main/AndroidManifest.xml", "w") as f:
    f.write(content)

