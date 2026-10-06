import 'package:eazotel/features/googleAnalytis/controller/analytisController.dart';
import 'package:eazotel/features/googleAnalytis/screen/analytics_line_chart.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/DeviceTechSection.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/TopEventCard.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/analytics_layout.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/convertaion.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/geographic_section.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/audience_section.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/dateFilterdropdown.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/metric_tabs.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/topPageCard.dart';
import 'package:eazotel/features/googleAnalytis/screen/widgets/traffic_channels_card.dart';
import 'package:eazotel/utils/res/t_responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Analytis extends StatelessWidget {
  const Analytis({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalytisController());
    return TResponsiveBuilder(
      builder: (context, r) {
        final layout = AnalyticsLayout(r);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Analytics'),
            actions: [
              if (!r.isPhone)
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.loadAll, // sab refresh
                ),
              DateRangeDropdown(controller: controller),
              SizedBox(width: r.pagePadding),
            ],
          ),
          body: SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final points = controller.analyticsData.value?.chartData ?? [];
              final metric = controller.selectedMetric.value;

              return RefreshIndicator(
                onRefresh: controller.loadAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: r.pagePadding),
                  children: [
                    TCenteredContent(
                      child: Column(
                        children: [
                          MetricTabs(
                            points: points,
                            selected: metric,
                            onSelected: controller.changeMetric,
                            layout: layout,
                          ),
                          SizedBox(height: r.gap + 4),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.pagePadding,
                            ),
                            child: const AnalyticsLineChart(),
                          ),
                          SizedBox(height: r.gap + 4),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.pagePadding,
                            ),
                            child: TrafficChannelsCard(
                              channels:
                                  controller.trafficData.value?.channels ?? [],
                              layout: layout,
                            ),
                          ),
                          SizedBox(height: r.gap + 4),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.pagePadding,
                            ),
                            child: Obx(
                              () => TopPagesCard(
                                pages:
                                    controller.topPagesData.value?.pages ?? [],
                                layout: layout,
                                isLoading: controller.isPagesLoading.value,
                              ),
                            ),
                          ),
                          SizedBox(height: r.gap + 4),
                          // Events + Conversions: wide par side-by-side
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.pagePadding,
                            ),
                            child: LayoutBuilder(
                              builder: (context, box) {
                                final events = Obx(
                                  () => TopEventsCard(
                                    events:
                                        controller
                                            .conversionsData
                                            .value
                                            ?.events ??
                                        [],
                                    layout: layout,
                                    isLoading:
                                        controller.isConversionsLoading.value,
                                  ),
                                );
                                final conversions = Obx(
                                  () => ConversionsCard(
                                    metrics: controller
                                        .conversionsData
                                        .value
                                        ?.metrics,
                                    conversions:
                                        controller
                                            .conversionsData
                                            .value
                                            ?.conversions ??
                                        [],
                                    layout: layout,
                                    isLoading:
                                        controller.isConversionsLoading.value,
                                  ),
                                );

                                if (box.maxWidth >= 900) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 3, child: events),
                                      SizedBox(width: r.gap + 4),
                                      Expanded(flex: 2, child: conversions),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    events,
                                    SizedBox(height: r.gap + 4),
                                    conversions,
                                  ],
                                );
                              },
                            ),
                          ),
                          SizedBox(height: r.gap + 12),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.pagePadding,
                            ),
                            child: Obx(
                              () => DeviceTechSection(
                                data: controller.devicesData.value,
                                layout: layout,
                                isLoading: controller.isDevicesLoading.value,
                              ),
                            ),
                          ),
                          SizedBox(height: r.gap + 12),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.pagePadding,
                            ),
                            child: Obx(
                              () => GeographicSection(
                                data: controller.geoData.value,
                                layout: layout,
                                isLoading: controller.isGeoLoading.value,
                              ),
                            ),
                          ),
                          SizedBox(height: r.gap + 12),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.pagePadding,
                            ),
                            child: Obx(
                              () => AudienceSection(
                                data: controller.audienceData.value,
                                layout: layout,
                                isLoading: controller.isAudienceLoading.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
