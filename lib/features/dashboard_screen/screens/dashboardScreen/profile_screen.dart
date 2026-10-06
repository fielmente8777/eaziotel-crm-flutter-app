import 'package:eazotel/features/auth/controllers/login_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/dashboard_screen.dart';
import 'package:eazotel/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileScreen extends StatelessWidget {
  final BottomNavController controller;

  // App version info (ek hi baar load hoga)
  final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  ProfileScreen({super.key, required this.controller}) {
    Get.lazyPut<LoginController>(() => LoginController());

    // LocationSelector needs this controller
    if (!Get.isRegistered<LocationController>()) {
      Get.put(LocationController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.find<LoginController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final LocationController locationController =
        Get.find<LocationController>();
    final DashboardController dashboardController =
        Get.find<DashboardController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // ==============================
              // PROFILE HEADER
              // ==============================
              Obx(() {
                final hotelName =
                    locationController.selectedHotel.value?.local.trim() ?? '';

                final initial = hotelName.isNotEmpty
                    ? hotelName[0].toUpperCase()
                    : 'U';

                return Container(
                  width: 110,
                  height: 110,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B5BD6),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              Obx(() {
                final profile = dashboardController.user.value?.profile;
                final hotelName =
                    locationController.selectedHotel.value?.local.trim() ?? '';

                return Column(
                  children: [
                    Text(
                      // TODO: switch to the user's real name from
                      // dashboardController.userNameResponse once its model is known
                      hotelName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      profile?.hotelEmail ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // ==============================
              // LOCATION SELECTOR
              // ==============================
              LocationSelector(onTap: () => _showHotelSheet(context)),

              const SizedBox(height: 20),

              // ==============================
              // HOTEL DETAILS CARD
              // ==============================
              Obx(() {
                final hotel = locationController.selectedHotel.value;
                final profile = dashboardController.user.value?.profile;

                return _hotelDetailsCard(
                  context,
                  currentLocation: hotel?.city.isNotEmpty == true
                      ? hotel!.city
                      : '-',
                  hotelName: hotel?.local.isNotEmpty == true
                      ? hotel!.local
                      : '-',
                  phone: profile?.hotelPhone.isNotEmpty == true
                      ? profile!.hotelPhone
                      : '-',
                  plan: profile?.plan.name.isNotEmpty == true
                      ? profile!.plan.name
                      : '-',
                );
              }),

              const SizedBox(height: 24),

              // ==============================
              // THEME SWITCH
              // ==============================
              Obx(
                () => Container(
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _themeOption(
                          context: context,
                          title: 'System',
                          icon: Icons.settings_brightness_outlined,
                          selected: themeController.isSystem,
                          onTap: () {
                            themeController.changeTheme(ThemeMode.system);
                          },
                        ),
                      ),

                      Expanded(
                        child: _themeOption(
                          context: context,
                          title: 'Light',
                          icon: Icons.light_mode_outlined,
                          selected: themeController.isLight,
                          onTap: () {
                            themeController.changeTheme(ThemeMode.light);
                          },
                        ),
                      ),

                      Expanded(
                        child: _themeOption(
                          context: context,
                          title: 'Dark',
                          icon: Icons.dark_mode_outlined,
                          selected: themeController.isDark,
                          onTap: () {
                            themeController.changeTheme(ThemeMode.dark);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==============================
              // LOGOUT
              // ==============================
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await loginController.logoutUser(context);
                },
                child: const Text('Logout'),
              ),

              const SizedBox(height: 16),

              // ==============================
              // APP VERSION
              // ==============================
              FutureBuilder<PackageInfo>(
                future: _packageInfo,
                builder: (context, snapshot) {
                  final info = snapshot.data;

                  return Text(
                    info == null
                        ? ''
                        : 'Version ${info.version} (${info.buildNumber})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HOTEL DETAILS CARD
  // ============================================================

  Widget _hotelDetailsCard(
    BuildContext context, {
    required String currentLocation,
    required String hotelName,
    required String phone,
    required String plan,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hotel Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          _detailRow(context, 'Current Location', currentLocation),
          _detailRow(context, 'Hotel Name', hotelName),
          _detailRow(context, 'Phone Number', phone),
          _detailRow(context, 'Active Plan', plan, isLast: true),
        ],
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  // ============================================================
  // HOTEL BOTTOM SHEET
  // ============================================================

  void _showHotelSheet(BuildContext context) {
    final locationController = Get.find<LocationController>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Hotel', style: theme.textTheme.headlineSmall),

                const SizedBox(height: 12),

                TextField(
                  onChanged: locationController.searchHotels,
                  decoration: const InputDecoration(
                    hintText: 'Search hotel',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Obx(() {
                    final hotels = locationController.filteredHotels;

                    if (hotels.isEmpty) {
                      return const Center(child: Text('No hotel found'));
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: hotels.length,
                      itemBuilder: (context, index) {
                        final HotelModel hotel = hotels[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,

                          leading: CircleAvatar(
                            child: Text(
                              hotel.local.isNotEmpty
                                  ? hotel.local[0].toUpperCase()
                                  : 'H',
                            ),
                          ),

                          title: Text(
                            hotel.local.isNotEmpty
                                ? hotel.local
                                : 'Hotel ${hotel.hotelId}',
                          ),

                          subtitle: Text(
                            [
                              if (hotel.city.isNotEmpty) hotel.city,
                              if (hotel.state.isNotEmpty) hotel.state,
                            ].join(', '),
                          ),

                          trailing: Obx(() {
                            final selected =
                                locationController
                                    .selectedHotel
                                    .value
                                    ?.hotelId ==
                                hotel.hotelId;

                            return selected
                                ? Icon(
                                    Icons.check,
                                    color: theme.colorScheme.primary,
                                  )
                                : const SizedBox.shrink();
                          }),

                          onTap: () {
                            locationController.selectHotel(hotel);
                            Navigator.of(sheetContext).pop();
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // THEME OPTION
  // ============================================================

  Widget _themeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: selected ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
