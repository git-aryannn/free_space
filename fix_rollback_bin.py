import re

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "r") as f:
    content = f.read()

target = r"""            restored\.asReversed\(\)\.forEach \{ \(trashPath, originalPath\) ->
                File\(originalPath\)\.renameTo\(File\(trashPath\)\)
            \}"""

replacement = r"""            restored.asReversed().forEach { (trashPath, originalPath) ->
                val o = File(originalPath)
                val t = File(trashPath)
                if (!o.renameTo(t)) {
                    try {
                        o.inputStream().use { input ->
                            t.outputStream().use { output ->
                                input.copyTo(output)
                            }
                        }
                        o.delete()
                    } catch (e: Exception) {}
                }
            }"""

content = re.sub(target, replacement, content)

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "w") as f:
    f.write(content)
