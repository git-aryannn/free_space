with open("pubspec.yaml", "r") as f:
    content = f.read()

config = """
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"
  min_sdk_android: 21

flutter_native_splash:
  color: "#121212"
  image: "assets/images/app_icon.png"
  android_12:
    image: "assets/images/app_icon.png"
    icon_background_color: "#121212"
    color: "#121212"
"""

with open("pubspec.yaml", "a") as f:
    f.write(config)

