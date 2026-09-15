import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/dashboard_screen/models/ProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/DashboardStatCard.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/dashboard_card.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/greeting_text.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/hotle_name.dart';
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

 

}
