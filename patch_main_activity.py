with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "r") as f:
    content = f.read()

target = '                "getScanRoot" -> result.success('
replacement = '''                "setScanRoot" -> {
                    val rootPath = call.argument<String>("path")
                    getSharedPreferences(SCAN_ROOT_PREFERENCES, MODE_PRIVATE)
                        .edit().putString(SCAN_ROOT_KEY, rootPath).apply()
                    result.success(true)
                }
                "getScanRoot" -> result.success('''

content = content.replace(target, replacement)

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "w") as f:
    f.write(content)
