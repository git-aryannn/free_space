import re
with open("lib/presentation/screens/bin/bin_screen.dart", "r") as f:
    content = f.read()

target = r"""              label: Text\(
                _requestingTrashAccess
                    \? 'Requesting access\.\.\.'
                    : 'Retry / Allow access',
      \),
              \),
            \),
          \],
        \),
      \),
    \);
  \}"""

replacement = r"""              label: Text(
                _requestingTrashAccess
                    ? 'Requesting access...'
                    : 'Retry / Allow access',
              ),
            ),
          ],
        ),
      ),
    );
  }"""
content = re.sub(target, replacement, content)

with open("lib/presentation/screens/bin/bin_screen.dart", "w") as f:
    f.write(content)
