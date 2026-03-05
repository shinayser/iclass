import 'package:flutter/material.dart' show WidgetBuilder;

abstract class Module {
  Future<void> init();
}

mixin RoutedModule on Module {
  Map<String, WidgetBuilder> get routes;
}
