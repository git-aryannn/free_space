import re

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "r") as f:
    content = f.read()

target = r"""                if \(source\.renameTo\(destination\)\) \{
                    moved\[path\] = destination\.absolutePath
                \} else \{
                    // Fallback to copy and delete if renameTo fails \(e\.g\. cross-device link\)
                    source\.inputStream\(\)\.use \{ input ->
                        destination\.outputStream\(\)\.use \{ output ->
                            input\.copyTo\(output\)
                        \}
                    \}
                    if \(source\.delete\(\)\) \{
                        moved\[path\] = destination\.absolutePath
                    \} else \{
                        destination\.delete\(\)
                    \}
                \}"""

replacement = r"""                if (source.renameTo(destination)) {
                    moved[path] = destination.absolutePath
                } else {
                    // renameTo failed (e.g., cross-volume or permission denied like Android/data).
                    // We purposefully DO NOT fallback to copy+delete to avoid excessive flash write wear.
                    throw java.io.IOException("renameTo failed for ${source.path}")
                }"""

content = re.sub(target, replacement, content)

target_restore = r"""                if \(!source\.renameTo\(destination\)\) \{
                    // Fallback to copy and delete
                    try \{
                        source\.inputStream\(\)\.use \{ input ->
                            destination\.outputStream\(\)\.use \{ output ->
                                input\.copyTo\(output\)
                            \}
                        \}
                        if \(!source\.delete\(\)\) \{
                            destination\.delete\(\)
                            throw IllegalStateException\("Could not delete Bin source after copy\."\)
                        \}
                    \} catch \(e: Exception\) \{
                        destination\.delete\(\)
                        throw IllegalStateException\("Could not restore \$\{source\.name\}: \$\{e\.message\}"\)
                    \}
                \}"""

replacement_restore = r"""                if (!source.renameTo(destination)) {
                    throw IllegalStateException("Could not restore ${source.name}.")
                }"""

content = re.sub(target_restore, replacement_restore, content)


target_rollback = r"""            restored\.asReversed\(\)\.forEach \{ \(trashPath, originalPath\) ->
                val o = File\(originalPath\)
                val t = File\(trashPath\)
                if \(!o\.renameTo\(t\)\) \{
                    try \{
                        o\.inputStream\(\)\.use \{ input ->
                            t\.outputStream\(\)\.use \{ output ->
                                input\.copyTo\(output\)
                            \}
                        \}
                        o\.delete\(\)
                    \} catch \(e: Exception\) \{\}
                \}
            \}"""

replacement_rollback = r"""            restored.asReversed().forEach { (trashPath, originalPath) ->
                File(originalPath).renameTo(File(trashPath))
            }"""

content = re.sub(target_rollback, replacement_rollback, content)

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "w") as f:
    f.write(content)
