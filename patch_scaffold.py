import re

with open("lib/presentation/widgets/adaptive_scaffold.dart", "r") as f:
    content = f.read()

# Replace Desktop leading icon
target1 = r'''                              const Icon\(
                                Icons\.diamond_outlined,
                                color: AppColors\.gold,
                              \),'''

replacement1 = r'''                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),'''

content = re.sub(target1, replacement1, content)

# Replace Desktop small leading icon
target2 = r'''                      : const Icon\(
                          Icons\.diamond_outlined,
                          color: AppColors\.gold,
                        \),'''

replacement2 = r'''                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 30,
                            height: 30,
                          ),
                        ),'''

content = re.sub(target2, replacement2, content)

# Replace Mobile AppBar icon
target3 = r'''          Container\(
            width: 34,
            height: 34,
            decoration: BoxDecoration\(
              color: AppColors\.gold\.withValues\(alpha: 0\.15\),
              borderRadius: BorderRadius\.circular\(12\),
            \),
            child: const Icon\(
              Icons\.diamond_outlined,
              color: AppColors\.gold,
              size: 19,
            \),
          \),'''

replacement3 = r'''          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 34,
              height: 34,
            ),
          ),'''

content = re.sub(target3, replacement3, content)


with open("lib/presentation/widgets/adaptive_scaffold.dart", "w") as f:
    f.write(content)

