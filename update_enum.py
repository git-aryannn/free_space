import re

with open("lib/data/repositories/settings_repository.dart", "r") as f:
    content = f.read()

content = content.replace(
    'enum DetectionMode { smartSync, liveMonitoring }',
    'enum DetectionMode { smartSync, liveMonitoring, efficientBackground }'
)

with open("lib/data/repositories/settings_repository.dart", "w") as f:
    f.write(content)
