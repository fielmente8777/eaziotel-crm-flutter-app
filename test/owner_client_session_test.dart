import 'package:eazotel/core/local_storage/token_storage.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/models/auth_user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'access_token': 'owner-token',
      'refresh_token': 'owner-refresh',
      'selected_hotel_id': 'owner-hotel',
    });
  });

  test(
    'client switches preserve owner credentials and restore original hotel',
    () async {
      await TokenStorage.enterClient('client-a-token', 'hotel-a');
      expect(await TokenStorage.getOwnerAccessToken(), 'owner-token');
      expect(await TokenStorage.getAccessToken(), 'client-a-token');
      expect(await TokenStorage.getRefreshToken(), isNull);

      // A second client switch and app controller recreation must not lose owner.
      await TokenStorage.enterClient('client-b-token', 'hotel-b');
      expect(await TokenStorage.getOwnerAccessToken(), 'owner-token');
      expect(await TokenStorage.getAccessToken(), 'client-b-token');

      expect(await TokenStorage.restoreOwner(), isTrue);
      expect(await TokenStorage.getAccessToken(), 'owner-token');
      expect(await TokenStorage.getRefreshToken(), 'owner-refresh');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_hotel_id'), 'owner-hotel');
      expect(await TokenStorage.getOwnerAccessToken(), isNull);
      expect(await TokenStorage.restoreOwner(), isFalse);
    },
  );

  test('empty client locations never reuse a previous account hotel', () async {
    await TokenStorage.enterClient('client-token', '');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_hotel_id'), isNull);
    await TokenStorage.restoreOwner();
    expect(prefs.getString('selected_hotel_id'), 'owner-hotel');
  });

  test('logout clears both sessions and cannot restore an old owner', () async {
    await TokenStorage.enterClient('client-token', 'client-hotel');
    await TokenStorage.clearTokens();
    expect(await TokenStorage.getAccessToken(), isNull);
    expect(await TokenStorage.getOwnerAccessToken(), isNull);
    expect(await TokenStorage.restoreOwner(), isFalse);
  });

  test(
    'restoring an owner without refresh or hotel clears client values',
    () async {
      SharedPreferences.setMockInitialValues({'access_token': 'owner-token'});
      await TokenStorage.enterClient('client-token', 'client-hotel');
      await TokenStorage.restoreOwner();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_hotel_id'), isNull);
      expect(await TokenStorage.getRefreshToken(), isNull);
    },
  );

  test(
    'owner controls survive client role without granting client admin rights',
    () {
      final dashboard = DashboardController();
      const client = AuthUserModel(
        role: 'user',
        isAdmin: false,
        assignedHids: ['a'],
      );
      const owner = AuthUserModel(
        role: 'owner',
        isAdmin: true,
        assignedHids: [],
      );
      dashboard.authUser.value = client;
      expect(dashboard.isOwner, isFalse);
      dashboard.ownerUser.value = owner;
      expect(dashboard.isOwner, isTrue);
      expect(dashboard.isViewingClient, isTrue);
      expect(dashboard.authUser.value!.isAdmin, isFalse);
      expect(dashboard.authUser.value!.assignedHids, ['a']);
      dashboard.clearDashboardData();
      expect(dashboard.isOwner, isFalse);
      expect(dashboard.isViewingClient, isFalse);
    },
  );
}
