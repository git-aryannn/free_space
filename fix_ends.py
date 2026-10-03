import re

def add_bracket(filepath, lines_to_fix):
    with open(filepath, "r") as f:
        lines = f.readlines()
        
    for line_num in lines_to_fix:
        # line_num is 1-based, we want to insert at line_num - 1
        lines.insert(line_num - 1, "      ),\n")
        
    with open(filepath, "w") as f:
        f.writelines(lines)

# For BinScreen
bin_lines = [291, 546, 597, 677, 723, 751, 832]
add_bracket("lib/presentation/screens/bin/bin_screen.dart", bin_lines)

