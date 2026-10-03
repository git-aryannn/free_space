import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

if "final FocusNode _searchFocusNode = FocusNode();" not in content:
    content = content.replace("final _searchController = TextEditingController();", "final _searchController = TextEditingController();\n  final FocusNode _searchFocusNode = FocusNode();")

    dispose_target = r'''  @override
  void dispose\(\) \{
    _searchController\.dispose\(\);
    super\.dispose\(\);
  \}'''

    dispose_replacement = '''  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }'''
    content = re.sub(dispose_target, dispose_replacement, content)

# Remove autofocus and use FocusNode
content = content.replace("autofocus: true,", "focusNode: _searchFocusNode,")

# Request focus on search icon tap
search_icon_tap_target = r'''                    IconButton\(
                      icon: const Icon\(Icons\.search\),
                      onPressed: \(\) \{
                        setState\(\(\) \{
                          _isSearchExpanded = true;
                        \}\);
                      \},
                    \),'''
search_icon_tap_replacement = '''                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _isSearchExpanded = true;
                        });
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _searchFocusNode.requestFocus();
                        });
                      },
                    ),'''
content = re.sub(search_icon_tap_target, search_icon_tap_replacement, content)

with open("lib/presentation/screens/permanent/permanent_screen.dart", "w") as f:
    f.write(content)

