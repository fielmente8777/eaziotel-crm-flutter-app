// App khul kar di gayi pehli screen dikhati hai ya nahi (smoke test)

import 'package:eazotel/main.dart';
import 'package:eazotel/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app opens the given first screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.put(ThemeController());

    await tester.pumpWidget(
      const MyApp(home: Scaffold(body: Text('first screen'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('first screen'), findsOneWidget);
  });
}
