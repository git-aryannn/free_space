with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "r") as f:
    content = f.read()

content = content.replace("private var pendingAppBinRestoreRollback: List<Pair<String, String>> = emptyList()",
                          "private var pendingAppBinRestoreRollback: List<Pair<String, String>> = emptyList()\n    private var observerManager: ObserverManager? = null")

content = content.replace("        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)",
                          "        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)\n        observerManager = ObserverManager(channel)")

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "w") as f:
    f.write(content)
