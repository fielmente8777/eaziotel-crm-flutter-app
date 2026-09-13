import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/DashboardStatCard.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/greeting_text.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/hotle_name.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatelessWidget {
  final BottomNavController controller;

  DashboardScreen({super.key, required this.controller});

  // DashboardController FIRST
  final DashboardController dashboardController = Get.put(
    DashboardController(),
  );

  // LocationController SECOND
  final LocationController locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: dashboardAppBar(context),

        body: Obx(() {
          if (locationController.showHotels.value) {
            return hotelSelector(context);
          }

          return dashboardBody();
        }),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget dashboardAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 130,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          greetingWidget(context),

          VSpace(height: 6),

          hotelNameWidget(context),

          VSpace(height: 8),

          locationSelector(context),
        ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 30),
          child: InkWell(
            onTap: () {
              controller.changeTab(3);
            },
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 55,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                'P',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION SELECTOR
  // ============================================================

  Widget locationSelector(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (locationController.showHotels.value) {
          locationController.closeHotelSelector();
        } else {
          locationController.openHotelSelector();
        }
      },

      child: Obx(() {
        final hotel = locationController.selectedHotel.value;

        final isOpen = locationController.showHotels.value;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(8),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isOpen ? Icons.location_on : Icons.location_on_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),

              HSpace(width: 6),

              Text(
                hotel?.city.isNotEmpty == true
                    ? hotel!.city
                    : 'Select location',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),

              HSpace(width: 4),

              Icon(
                isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // HOTEL SELECTOR
  // ============================================================

  Widget hotelSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: locationController.closeHotelSelector,
                icon: const Icon(Icons.arrow_back),
              ),

              Expanded(
                child: Text(
                  'Select Hotel',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ],
          ),

          VSpace(height: 12),

          TextField(
            onChanged: locationController.searchHotels,
            decoration: const InputDecoration(
              hintText: 'Search hotel',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          VSpace(height: 12),

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
                  return hotelItem(context, hotels[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOTEL ITEM
  // ============================================================

  Widget hotelItem(BuildContext context, HotelModel hotel) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        child: Text(
          hotel.local.isNotEmpty ? hotel.local[0].toUpperCase() : 'H',
        ),
      ),

      title: Text(
        hotel.local.isNotEmpty ? hotel.local : 'Hotel ${hotel.hotelId}',
      ),

      subtitle: Text(
        [
          if (hotel.city.isNotEmpty) hotel.city,
          if (hotel.state.isNotEmpty) hotel.state,
        ].join(', '),
      ),

      trailing: Obx(() {
        final selected =
            locationController.selectedHotel.value?.hotelId == hotel.hotelId;

        return selected
            ? Icon(Icons.check, color: theme.colorScheme.primary)
            : const SizedBox.shrink();
      }),

      onTap: () {
        locationController.selectHotel(hotel);
      },
    );
  }

  // ============================================================
  // DASHBOARD BODY
  // ============================================================

  final List<Map<String, dynamic>> dashboardCards = [
    {
      'value': '145',
      'title': 'Total Leads',
      'bottomText': '↑ 12 this week',
      'icon': Icons.person_outline,
      'accentColor': Colors.indigo,
      'iconColor': Colors.indigo,
    },
    {
      'value': '38',
      'title': 'Active Bookings',
      'bottomText': '↑ 5 today',
      'icon': Icons.calendar_today_outlined,
      'accentColor': Colors.teal,
      'iconColor': Colors.teal,
    },
    {
      'value': '₹4.2L',
      'title': 'Revenue (MTD)',
      'bottomText': '↑ 18% vs last',
      'icon': Icons.arrow_downward,
      'accentColor': Colors.orange,
      'iconColor': Colors.orange,
    },
    {
      'value': 'Pro Plan',
      'title': 'Subscription',
      'bottomText': '• Active • 14d left',
      'icon': Icons.remove_circle_outline,
      'accentColor': Colors.purple,
      'iconColor': Colors.purple,
      'valueColor': TAppColors.success,
    },
  ];

  Widget dashboardBody() {
    final leads = dashboardController.leadResponse.value?.result?.docs?.leads;

    final leadsCount = dashboardController.leads.length;

    final isLoading = leads == null;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dashboardCards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final card = dashboardCards[index];

        return DashboardStatCard(
          value: leadsCount.toString(),
          title: card['title'],
          bottomText: card['bottomText'],
          icon: card['icon'],
          accentColor: card['accentColor'],
          iconColor: card['iconColor'],
          valueColor: card['valueColor'],
          isLoading: isLoading,
        );
      },
    );
  }
}
