with open("lib/data/services/system_file_scan_service.dart", "r") as f:
    content = f.read()

content = content.replace("followLinks: false", "followLinks: true")

with open("lib/data/services/system_file_scan_service.dart", "w") as f:
    f.write(content)
