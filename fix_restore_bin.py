import re

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "r") as f:
    content = f.read()

target = r"""                if \(!source\.renameTo\(destination\)\) \{
                    throw IllegalStateException\("Could not restore \$\{source\.name\}\."\)
                \}"""

replacement = r"""                if (!source.renameTo(destination)) {
                    // Fallback to copy and delete
                    try {
                        source.inputStream().use { input ->
                            destination.outputStream().use { output ->
                                input.copyTo(output)
                            }
                        }
                        if (!source.delete()) {
                            destination.delete()
                            throw IllegalStateException("Could not delete Bin source after copy.")
                        }
                    } catch (e: Exception) {
                        destination.delete()
                        throw IllegalStateException("Could not restore ${source.name}: ${e.message}")
                    }
                }"""

content = re.sub(target, replacement, content)

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "w") as f:
    f.write(content)
