import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:front/app.dart';
import 'package:front/di/app_dependencies.dart';
import 'package:front/presentation/home/widgets/home_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('HomeTitle shows Regicide', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeTitle())),
    );
    expect(find.text('Regicide'), findsOneWidget);
  });

  testWidgets('RegicideApp builds home route', (tester) async {
    final deps = await AppDependencies.init();
    await tester.pumpWidget(RegicideApp(deps: deps));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Regicide'), findsWidgets);
    expect(find.text('Create room (solo)'), findsOneWidget);
  });
}
