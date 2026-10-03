import re

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "r") as f:
    content = f.read()

target = r"""                if \(source\.renameTo\(destination\)\) \{
                    moved\[path\] = destination\.absolutePath
                \}"""

replacement = r"""                if (source.renameTo(destination)) {
                    moved[path] = destination.absolutePath
                } else {
                    // Fallback to copy and delete if renameTo fails (e.g. cross-device link)
                    source.inputStream().use { input ->
                        destination.outputStream().use { output ->
                            input.copyTo(output)
                        }
                    }
                    if (source.delete()) {
                        moved[path] = destination.absolutePath
                    } else {
                        destination.delete()
                    }
                }"""

content = re.sub(target, replacement, content)

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "w") as f:
    f.write(content)
