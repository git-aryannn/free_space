import re

with open("lib/presentation/screens/permanent/permanent_screen.dart", "r") as f:
    content = f.read()

# Replace Scaffold -> NestedScrollView
target_scaffold = r'''    return Scaffold\(
      appBar: AppBar\(
        toolbarHeight: 68,
        title: Column\('''

replacement = r'''    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            toolbarHeight: 68,
            floating: true,
            snap: true,
            title: Column('''

content = re.sub(target_scaffold, replacement, content)

# End of AppBar -> body: Column -> body:
target_body = r'''        ],
      \),
      body: Column\(
        children: \['''

replacement_body = r'''        ],
          ),
        ],
        body: Column(
          children: ['''
content = re.sub(target_body, replacement_body, content)

# But wait, we want the body to just be the Expanded part, 
# and the Filter Chips inside SliverAppBar bottom!
