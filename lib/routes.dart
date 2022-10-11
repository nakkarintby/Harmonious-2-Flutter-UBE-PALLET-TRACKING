import 'package:flutter/widgets.dart';
import 'package:test/screens/login.dart';

import 'package:test/screens/menu.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  Menu.routeName: (context) => Menu(),
  Login.routeName: (context) => Login(),
};
