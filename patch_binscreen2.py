import re

with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r'''                      Container\(
                        width: 4,
                        decoration: const BoxDecoration\(
                          color: AppColors\.rose,
                          borderRadius: BorderRadius\.horizontal\(
                            left: Radius\.circular\(20\),
                          \),
                        \),
                      \),'''

content = re.sub(target, '', content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)

