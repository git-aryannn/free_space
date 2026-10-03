import re

with open("android/app/src/main/AndroidManifest.xml", "r") as f:
    content = f.read()

service_tag = """
        <service
            android:name="id.flutter.flutter_background_service.BackgroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false" />
"""

if "flutter_background_service" not in content:
    content = content.replace('</activity>', '</activity>\n' + service_tag)
    with open("android/app/src/main/AndroidManifest.xml", "w") as f:
        f.write(content)
