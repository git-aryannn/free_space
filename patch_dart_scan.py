import re

with open("lib/data/services/system_file_scan_service.dart", "r") as f:
    content = f.read()

target1 = r"""                sizeBytes: stat\.size,
                modifiedAt: stat\.modified,
                accessedAt: _usableAccessDate\(stat\.accessed, stat\.modified\),"""

replacement1 = r"""                sizeBytes: stat.size,
                modifiedAt: stat.modified,
                accessedAt: stat.modified,"""

content = re.sub(target1, replacement1, content)

target2 = r"""              sizeBytes: stat\.size,
              modifiedAt: stat\.modified,
              accessedAt: _usableAccessDate\(stat\.accessed, stat\.modified\),"""

replacement2 = r"""              sizeBytes: stat.size,
              modifiedAt: stat.modified,
              accessedAt: stat.modified,"""

content = re.sub(target2, replacement2, content)

with open("lib/data/services/system_file_scan_service.dart", "w") as f:
    f.write(content)
