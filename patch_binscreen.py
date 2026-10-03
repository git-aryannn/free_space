import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r'''                      Container\(
                        width: 4,
                        decoration: const BoxDecoration\(
                          color: AppColors\.rose,
                          borderRadius: BorderRadius\.only\(
                            topLeft: Radius\.circular\(20\),
                            bottomLeft: Radius\.circular\(20\),
                          \),
                        \),
                      \),'''

replacement = r''''''

content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)

