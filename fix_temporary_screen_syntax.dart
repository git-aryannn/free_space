import 'dart:io';

void main() {
  var content = File('lib/presentation/screens/temporary/temporary_screen.dart').readAsStringSync();
  
  // Find where RefreshIndicator ends
  var index = content.indexOf('floatingActionButton:');
  
  // Replace the closing brackets before floatingActionButton
  var before = content.substring(0, index);
  var after = content.substring(index);
  
  // Clean up any extra/missing brackets in before string
  // It should close: RefreshIndicator ), NestedScrollView ), Scaffold (
  
  var newBefore = before.replaceAll(RegExp(r'\),\s*\),\s*\),\s*$'), '        ),\n      ),\n      ');
  
  File('lib/presentation/screens/temporary/temporary_screen.dart').writeAsStringSync(newBefore + after);
}
