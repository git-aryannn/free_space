def fix_end(filepath):
    with open(filepath, "r") as f:
        content = f.read()
        
    # TemporaryScreen has extra `),` before the end of the build method
    # Let's search for `      ),\n    );\n  }\n}` and replace with `    );\n  }\n}`
    
    content = content.replace("      ),\n    );\n  }\n", "    );\n  }\n")
    content = content.replace("      ),\n      ),\n    );\n  }\n", "      ),\n    );\n  }\n")
    
    with open(filepath, "w") as f:
        f.write(content)

fix_end("lib/presentation/screens/temporary/temporary_screen.dart")
fix_end("lib/presentation/screens/bin/bin_screen.dart")
