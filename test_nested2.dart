import 'package:flutter/widgets.dart';
void test(GlobalKey<NestedScrollViewState> key) {
  key.currentState?.outerController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.linear);
}
