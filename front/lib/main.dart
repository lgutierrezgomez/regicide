import 'package:flutter/material.dart';

import 'app.dart';
import 'di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await AppDependencies.init();
  runApp(RegicideApp(deps: deps));
}
