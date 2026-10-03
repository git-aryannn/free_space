def fix_file(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # For PermanentScreen:
    # `return Scrollbar(child: ListView.builder(`
    # We need to close Scrollbar after ListView.builder.
    # We see:
    #           },
    #         );
    #       },
    #     ),
    #     );
    #   }
    if "permanent_screen.dart" in filepath:
        if "    ),\n    );\n  }" in content:
            pass # already fixed
        else:
            content = content.replace("      },\n    );\n  }", "      },\n    ),\n    );\n  }")

    # For BinScreen:
    if "bin_screen.dart" in filepath:
        # replace `child: Scrollbar( ... child: ListView(` with just `child: ListView(` to undo it.
        # wait, if I just undo it, it's easier.
        content = content.replace("                  child: Scrollbar(\n                    interactive: true,\n                    thickness: 6.0,\n                    radius: const Radius.circular(10),\n                    child: ListView(", "                  child: ListView(")
        
        # then I add it back correctly:
        target = "                  child: ListView(\n                    padding:"
        replacement = "                  child: Scrollbar(\n                    interactive: true,\n                    thickness: 6.0,\n                    radius: const Radius.circular(10),\n                    child: ListView(\n                    padding:"
        content = content.replace(target, replacement)
        
        target_close = "                      ],\n                    ),\n                  ),\n                ),\n              ],\n            );\n          },"
        replacement_close = "                      ],\n                    ),\n                  ),\n                  ),\n                ),\n              ],\n            );\n          },"
        content = content.replace(target_close, replacement_close)

    # For TemporaryScreen:
    if "temporary_screen.dart" in filepath:
        content = content.replace("              return Scrollbar(\n                interactive: true,\n                thickness: 6.0,\n                radius: const Radius.circular(10),\n                child: ListView.builder(", "              return ListView.builder(")
        
        target = "              return ListView.builder(\n                padding:"
        replacement = "              return Scrollbar(\n                interactive: true,\n                thickness: 6.0,\n                radius: const Radius.circular(10),\n                child: ListView.builder(\n                padding:"
        content = content.replace(target, replacement)
        
        target_close = "                },\n              ),\n              );"
        replacement_close = "                },\n              ),\n              );"
        content = content.replace(target_close, replacement_close)

    with open(filepath, "w") as f:
        f.write(content)

fix_file("lib/presentation/screens/permanent/permanent_screen.dart")
fix_file("lib/presentation/screens/bin/bin_screen.dart")
fix_file("lib/presentation/screens/temporary/temporary_screen.dart")

