import 'package:eazotel/common/widgets/spacing.dart';
import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/dashboard_api_controller.dart';
import 'package:eazotel/features/dashboard_screen/controllers/headerLocationController.dart';
import 'package:eazotel/features/dashboard_screen/models/HotelIdProfileResponseModel%20.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/lead_card.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/LeadsScreenWidget/leads_empty_state.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/DashboardStatCard.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/dashboard_card.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/greeting_text.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashboardScreen/screens/dashboardwidget/hotle_name.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  final BottomNavController controller;

  DashboardScreen({super.key, required this.controller});

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final DashboardController dashboardController = Get.put(
    DashboardController(),
  );

  final LocationController locationController = Get.put(LocationController());

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // ======================================================
        // APP BAR - FIXED
        // ======================================================
        appBar: dashboardAppBar(context),

        // ======================================================
        // BODY
        // ======================================================
        body: Obx(() {
          if (locationController.showHotels.value) {
            return hotelSelector(context);
          }

          return _dashboardBody(context);
        }),
      ),
    );
  }

  // ============================================================
  // DASHBOARD BODY
  // ============================================================
  Widget _dashboardBody(BuildContext context) {
    return RefreshIndicator(
      displacement: 50,
      edgeOffset: 0,

      onRefresh: () async {
        final hotelId = dashboardController.selectedHotelId.value;

        if (hotelId.isEmpty) {
          return;
        }

        await Future.wait([
          dashboardController.refreshLeads(),
          dashboardController.getAnalytics(hotelId),
        ]);
      },

      child: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),

        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [SliverToBoxAdapter(child: dashboardBody())];
        },

        body: _leadsList(context, leadsController: dashboardController),
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
            child: Obx(() {
              final hotelName =
                  locationController.selectedHotel.value?.local.trim() ?? '';

              final lastWord = hotelName.isNotEmpty
                  ? hotelName.split(RegExp(r'\s+')).first
                  : 'E';

              final profileName = lastWord.isNotEmpty
                  ? lastWord[0].toUpperCase()
                  : '';

              return Container(
                width: 55,
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFF3B82F6)
                      : Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  profileName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
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
  // LEADS
  // ============================================================
  Widget _leadsList(
    BuildContext context, {
    required DashboardController leadsController,
  }) {
    return Obx(() {
      // ============================================================
      // CURRENT TIME
      // ============================================================

      final now = DateTime.now().toUtc();

      // ============================================================
      // LAST 24 HOURS
      // ============================================================

      final twentyFourHoursAgo = now.subtract(const Duration(days: 424));

      // ============================================================
      // FILTER LEADS
      // ============================================================

      final leads = leadsController.leads.where((lead) {
        final createdAt = lead.createdAtDate;

        if (createdAt == null) {
          return false;
        }

        final createdDate = DateTime.tryParse(createdAt.toString());

        if (createdDate == null) {
          return false;
        }

        final createdUtc = createdDate.toUtc();

        return createdUtc.isAfter(twentyFourHoursAgo) &&
            createdUtc.isBefore(now);
      }).toList();

      // ============================================================
      // HEADER
      // ============================================================

      Widget header() {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Leads',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),

              GestureDetector(
                onTap: () {
                  controller.changeTab(1);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'See All Leads',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      // ============================================================
      // INITIAL LOADING
      // ============================================================

      if (leadsController.isLeadsLoading.value && leads.isEmpty) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: header()),

            SliverFillRemaining(
              hasScrollBody: false,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ],
        );
      }

      // ============================================================
      // EMPTY STATE
      // ============================================================

      if (leads.isEmpty) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // --------------------------------------------------------
            // LEADS HEADER
            // --------------------------------------------------------
            SliverToBoxAdapter(child: header()),

            // --------------------------------------------------------
            // EMPTY STATE
            // --------------------------------------------------------
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,

              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: 40,
                ),

                child: Center(child: LeadsEmptyState()),
              ),
            ),
          ],
        );
      }

      // ============================================================
      // LEADS LIST
      // ============================================================

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;

          // ========================================================
          // PAGINATION
          // ========================================================

          if (metrics.pixels >= metrics.maxScrollExtent - 300) {
            if (!leadsController.isLoadingMoreLeads.value &&
                leadsController.hasMoreLeads.value) {
              leadsController.loadMoreLeads();
            }
          }

          return false;
        },

        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),

          slivers: [
            // ======================================================
            // HEADER
            // ======================================================
            SliverToBoxAdapter(child: header()),

            // ======================================================
            // LEAD CARDS
            // ======================================================
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),

              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // ==============================================
                    // PAGINATION LOADER
                    // ==============================================

                    if (index >= leads.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    // ==============================================
                    // LEAD CARD
                    // ==============================================

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LeadCard(lead: leads[index]),
                    );
                  },

                  childCount:
                      leads.length +
                      (leadsController.isLoadingMoreLeads.value ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
