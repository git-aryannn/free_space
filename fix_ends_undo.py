import re

def undo_bracket(filepath, lines_to_fix):
    with open(filepath, "r") as f:
        lines = f.readlines()
        
    # We added in forward order:
    # idx 0 -> inserted at 291-1 = 290
    # idx 1 -> inserted at 546-1 = 545
    # The new line numbers where they were inserted are:
    # 291, 546+1, 597+2, 677+3, 723+4, 751+5, 832+6
    
    lines_to_remove = [
        291,
        546 + 1,
        597 + 2,
        677 + 3,
        723 + 4,
        751 + 5,
        832 + 6
    ]
    
    for line_num in sorted(lines_to_remove, reverse=True):
        if lines[line_num - 1] == "      ),\n":
            del lines[line_num - 1]
        
    with open(filepath, "w") as f:
        f.writelines(lines)

bin_lines = [291, 546, 597, 677, 723, 751, 832]
undo_bracket("lib/presentation/screens/bin/bin_screen.dart", bin_lines)

