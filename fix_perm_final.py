with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

import re

# Remove _scrollController listener logic
target_init = r"""    _scrollController\?\.addListener\(_maybeLoadNextPage\);
    _scrollController\?\.addListener\(\(\) \{
      if \(\(_scrollController\?\.offset \?\? 0\) > 200 && !_showBackToTop\) \{
        setState\(\(\) => _showBackToTop = true\);
      \} else if \(\(_scrollController\?\.offset \?\? 0\) <= 200 && _showBackToTop\) \{
        setState\(\(\) => _showBackToTop = false\);
      \}
    \}\);"""
content = re.sub(target_init, "    _scrollController?.addListener(_maybeLoadNextPage);", content)

# Remove the extra `)` at 759
# The file has:
#       },
#     ),
#     ),
#     );
#   }
# We need it to be:
#       },
#     ),
#     );
#   }
content = content.replace("      },\n    ),\n    ),\n    );\n  }", "      },\n    ),\n    );\n  }")
content = content.replace("      },\n    ),\n    );\n  }", "      },\n    ),\n  }")
# wait, just make sure it parses by replacing the end.
# I will just write the end cleanly.
end_target = r"""        \);
      \},
    \),
    \),
    \);
  \}
\}"""
end_replacement = r"""        );
      },
    ),
    );
  }
}"""
content = re.sub(end_target, end_replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)
