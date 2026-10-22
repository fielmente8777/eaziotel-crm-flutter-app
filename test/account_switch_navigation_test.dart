import 'package:eazotel/core/navigation/session_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Dashboard extends GetxController {
  final hotel = 'initial'.obs;
}

class _HotelListener extends GetxController {
  _HotelListener(this.dashboard);
  final _Dashboard dashboard;
  String lastHotel = '';
  Worker? worker;

  @override
  void onInit() {
    super.onInit();
    worker = ever<String>(dashboard.hotel, (hotel) => lastHotel = hotel);
  }

  @override
  void onClose() {
    worker?.dispose();
    super.onClose();
  }
}

class _AccountScreen extends StatefulWidget {
  const _AccountScreen();

  @override
  State<_AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<_AccountScreen> {
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    final dashboard = Get.put(_Dashboard());
    Get.put(_HotelListener(dashboard), permanent: true);
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => SessionNavigation.restart(
        context: context,
        clearControllers: () {
          // No new account dependencies may exist before old route disposal.
          expect(disposed, isTrue);
          Get.delete<_HotelListener>(force: true);
          Get.delete<_Dashboard>(force: true);
        },
        destination: () => const _AccountScreen(),
      ),
      child: const Text('Switch account'),
    ),
  );
}

void main() {
  tearDown(() async => Get.reset());

  testWidgets('repeated switches keep hotel listener on the live dashboard', (
    tester,
  ) async {
    Get.testMode = true;
    await tester.pumpWidget(const GetMaterialApp(home: _AccountScreen()));
    await tester.pumpAndSettle();

    // First switch from /, then successive replacements of the same route.
    for (var account = 0; account < 3; account++) {
      final previous = Get.find<_Dashboard>();
      final previousListener = Get.find<_HotelListener>();
      await tester.tap(find.text('Switch account'));
      await tester.pumpAndSettle();

      final dashboard = Get.find<_Dashboard>();
      final listener = Get.find<_HotelListener>();
      expect(identical(dashboard, previous), isFalse);
      expect(identical(listener, previousListener), isFalse);
      expect(dashboard.isClosed, isFalse);
      expect(identical(listener.dashboard, dashboard), isTrue);
      dashboard.hotel.value = 'connected-location-$account';
      await tester.pump();
      expect(listener.lastHotel, 'connected-location-$account');
      expect(tester.takeException(), isNull);
    }
  });
}
