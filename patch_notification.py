import re

def patch_body(filepath, body_start):
    with open(filepath, "r") as f:
        content = f.read()

    target = f"body: {body_start}"
    replacement = f"""body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {{
          if (notification.metrics.axis == Axis.vertical) {{
            final offset = notification.metrics.pixels;
            if (offset > 200 && !_showBackToTop) {{
              setState(() => _showBackToTop = true);
            }} else if (offset <= 200 && _showBackToTop) {{
              setState(() => _showBackToTop = false);
            }}
          }}
          return false;
        }},
        child: {body_start}"""
    
    # We need to add an extra closing parenthesis `)` at the very end of the NestedScrollView.
    # Where does NestedScrollView end? Right before `);` for the `Scaffold` return?
    # Let's just do it directly.
    content = content.replace(target, replacement)
    
    # In TemporaryScreen:
    # Scaffold body: NestedScrollView( ... )
    # So we need to add `),` before the Scaffold closing bracket.
    
    with open(filepath, "w") as f:
        f.write(content)

patch_body("lib/presentation/screens/temporary/temporary_screen.dart", "itemsAsync.when(")
patch_body("lib/presentation/screens/bin/bin_screen.dart", "binItemsAsync.when(")
