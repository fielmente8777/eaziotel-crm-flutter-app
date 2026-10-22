// ============================================================
// LEADS SCREEN  (bottom tab: Leads)
//
//   top     : ← Leads (total leads)          [🔍 filter (3)]  <- badge = filter count
//   search  : name, phone, source
//   tabs    : All Leads | Contact | Converted | Hot   (count in each tab)
//   filter  : "3 filters applied" + chips (remove one with x) + Clear all
//   list    : lead cards, pull down = refresh, more leads at the end
//
// Logic is the same as before: LeadsController / DashboardController do all the work.
// ============================================================

import 'package:eazotel/features/dashboard_screen/controllers/bottom_nav_controller.dart';
import 'package:eazotel/features/leads/controller/leads_controller.dart';
import 'package:eazotel/features/leads/screen/widgets/lead_card.dart';
import 'package:eazotel/features/leads/screen/widgets/leads_empty_state.dart';
import 'package:eazotel/features/leads/screen/widgets/leads_filter_screen.dart';
import 'package:eazotel/features/leads/screen/widgets/leads_search.dart';
import 'package:eazotel/features/leads/screen/widgets/leads_style.dart';
import 'package:eazotel/features/leads/screen/widgets/leads_tabs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeadsScreen extends StatelessWidget {
  final BottomNavController controller;

  LeadsScreen({super.key, required this.controller});

  final LeadsController leadsController = Get.put(LeadsController());

  void _openFilters(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LeadsFilterScreen(controller: leadsController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              leadsController: leadsController,
              onBack: () => controller.changeTab(0),
              onFilter: () => _openFilters(context),
            ),
            LeadsSearch(controller: leadsController),
            LeadsTabs(controller: leadsController),
            _ActiveFilters(controller: leadsController),
            const SizedBox(height: 4),
            Expanded(child: _leadsList(context)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LEADS LIST
  // ============================================================

  Widget _leadsList(BuildContext context) {
    return Obx(() {
      final leads = leadsController.filteredLeads;

      // ---------- First-time loading ----------
      if (leadsController.isLoading && leads.isEmpty) {
        return const LeadsShimmer();
      }

      // ---------- Empty ----------
      if (leads.isEmpty) {
        return RefreshIndicator(
          onRefresh: leadsController.refreshLeads,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .5,
                child: LeadsEmptyState(
                  hasFilters:
                      leadsController.hasFilters ||
                      leadsController.searchText.value.isNotEmpty,
                  onClear: leadsController.hasFilters
                      ? leadsController.clearFilters
                      : null,
                ),
              ),
            ],
          ),
        );
      }

      // ---------- List ----------
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 300) {
              leadsController.loadMoreLeads();
            }
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: leadsController.refreshLeads,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            itemCount: leads.length + (leadsController.isLoadingMore ? 1 : 0),
            itemBuilder: (_, index) {
              // More leads are loading
              if (index >= leads.length) {
                return const LeadsShimmer(count: 1, padding: EdgeInsets.zero);
              }

              return LeadCard(lead: leads[index]);
            },
          ),
        ),
      );
    });
  }
}

// ============================================================
// HEADER (back, title + total, filter with count badge)
// ============================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.leadsController,
    required this.onBack,
    required this.onFilter,
  });

  final LeadsController leadsController;
  final VoidCallback onBack;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final p = LeadsPalette(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back to Home',
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: p.text,
              size: 20,
            ),
          ),
          Expanded(
            child: Obx(() {
              final total = leadsController.totalLeads;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leads',
                    style: TextStyle(
                      color: p.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.3,
                    ),
                  ),
                  Text(
                    total == null
                        ? 'All your enquiries in one place'
                        : '${NumberFormat.decimalPattern('en_IN').format(total)} '
                              'lead${total == 1 ? '' : 's'}'
                              '${leadsController.hasFilters ? ' match your filters' : ''}',
                    style: TextStyle(color: p.subText, fontSize: 12.5),
                  ),
                ],
              );
            }),
          ),
          Obx(() {
            final count = leadsController.activeFilterCount;
            final active = count > 0;

            return Tooltip(
              message: active
                  ? '$count filter${count == 1 ? '' : 's'} applied'
                  : 'Filters',
              child: Material(
                color: active ? p.primary : p.card,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onFilter,
                  child: Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: active ? p.primary : p.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: active ? Colors.white : p.text,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: active ? Colors.white : p.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (active) ...[
                          const SizedBox(width: 6),
                          // Badge: how many filters are applied
                          Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: p.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// ACTIVE FILTERS ROW ("3 filters applied" + chips + Clear all)
// ============================================================

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({required this.controller});

  final LeadsController controller;

  String _date(DateTime d) => DateFormat('d MMM').format(d);

  /// Remove one filter, keep the rest (same applyFilters logic)
  Future<void> _apply({
    List<String>? sources,
    List<String>? stages,
    bool clearDates = false,
  }) {
    return controller.applyFilters(
      sources: sources ?? controller.selectedSources.toList(),
      stages: stages ?? controller.selectedStages.toList(),
      startDate: clearDates ? null : controller.startDateTime.value,
      endDate: clearDates ? null : controller.endDateTime.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = LeadsPalette(context);

    return Obx(() {
      final count = controller.activeFilterCount;

      return AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: count == 0
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.filter_alt_rounded,
                          size: 15,
                          color: p.accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$count filter${count == 1 ? '' : 's'} applied',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: p.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor: Colors.red,
                          ),
                          onPressed: controller.clearFilters,
                          child: const Text('Clear all'),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final s in controller.selectedSources)
                            _chip(
                              context,
                              label: LeadsStyle.capitalize(s),
                              icon: LeadsStyle.source(s).icon,
                              color: LeadsStyle.source(s).color,
                              onRemove: () => _apply(
                                sources: controller.selectedSources
                                    .where((x) => x != s)
                                    .toList(),
                              ),
                            ),
                          for (final s in controller.selectedStages)
                            _chip(
                              context,
                              label: s,
                              icon: Icons.flag_outlined,
                              color: LeadsStyle.stage(s),
                              onRemove: () => _apply(
                                stages: controller.selectedStages
                                    .where((x) => x != s)
                                    .toList(),
                              ),
                            ),
                          if (controller.startDateTime.value != null ||
                              controller.endDateTime.value != null)
                            _chip(
                              context,
                              label: [
                                controller.startDateTime.value == null
                                    ? '…'
                                    : _date(controller.startDateTime.value!),
                                controller.endDateTime.value == null
                                    ? 'now'
                                    : _date(controller.endDateTime.value!),
                              ].join(' – '),
                              icon: Icons.date_range_outlined,
                              color: p.primary,
                              onRemove: () => _apply(clearDates: true),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onRemove,
  }) {
    final p = LeadsPalette(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: p.tint(color),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.tintBorder(color)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: p.onTint(color)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: p.text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, size: 15, color: p.subText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
