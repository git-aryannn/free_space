import re

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "r") as f:
    content = f.read()

target = r'''            for \(path in paths\.distinct\(\)\) \{
                val item = if \(isMediaPath\(path\)\) findMediaStoreItem\(path\) else null
                if \(item\?\.isMedia == true\) \{'''

replacement = '''            val allFilesAccess = hasAllFilesAccess()
            for (path in paths.distinct()) {
                val item = if (!allFilesAccess && isMediaPath(path)) findMediaStoreItem(path) else null
                if (item?.isMedia == true) {'''

content = re.sub(target, replacement, content)

with open("android/app/src/main/kotlin/com/example/free_space/MainActivity.kt", "w") as f:
    f.write(content)

