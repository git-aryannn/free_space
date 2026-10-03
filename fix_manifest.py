import re

with open("android/app/src/main/AndroidManifest.xml", "r") as f:
    content = f.read()

# Add tools namespace if missing
if 'xmlns:tools="http://schemas.android.com/tools"' not in content:
    content = content.replace('<manifest xmlns:android="http://schemas.android.com/apk/res/android"', '<manifest xmlns:android="http://schemas.android.com/apk/res/android"\n    xmlns:tools="http://schemas.android.com/tools"')

# Add tools:replace
if 'tools:replace="android:exported"' not in content:
    target = r'''<service android:name="id.flutter.flutter_background_service.BackgroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false" />'''
    replacement = r'''<service android:name="id.flutter.flutter_background_service.BackgroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false"
            tools:replace="android:exported" />'''
    content = re.sub(target, replacement, content)
    
    # Also handle if it's slightly formatted differently
    target2 = r'''<service\s+android:name="id.flutter.flutter_background_service.BackgroundService"\s+android:foregroundServiceType="dataSync"\s+android:exported="false"\s*/>'''
    content = re.sub(target2, '''<service android:name="id.flutter.flutter_background_service.BackgroundService"
            android:foregroundServiceType="dataSync"
            android:exported="false"
            tools:replace="android:exported" />''', content)

with open("android/app/src/main/AndroidManifest.xml", "w") as f:
    f.write(content)
