import 'package:eazotel/features/dashboard_screen/controllers/leads_controller.dart';
import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class LeadsFilterScreen extends StatefulWidget {
  final LeadsController controller;

  const LeadsFilterScreen({
    super.key,
    required this.controller,
  });

  @override
  State<LeadsFilterScreen> createState() =>
      _LeadsFilterScreenState();
}

class _LeadsFilterScreenState
    extends State<LeadsFilterScreen> {
  late List<String> selectedSources;

  late List<String> selectedStages;

  DateTime? startDateTime;

  DateTime? endDateTime;

  @override
  void initState() {
    super.initState();

    selectedSources =
        List<String>.from(
      widget.controller.selectedSources,
    );

    selectedStages =
        List<String>.from(
      widget.controller.selectedStages,
    );

    startDateTime =
        widget.controller.startDateTime.value;

    endDateTime =
        widget.controller.endDateTime.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    final textColor = isDark
        ? TAppColors.darkText
        : TAppColors.lightText;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ??
                theme.scaffoldBackgroundColor,
        elevation:
            theme.appBarTheme.elevation ?? 0,
        centerTitle: false,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
            size: 20,
          ),
        ),

        title: Text(
          'Filters',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        actions: [
          TextButton(
            onPressed: _clear,
            child: const Text(
              'Clear',
              style: TextStyle(
                color:
                    TAppColors.primary,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // SOURCES
                  // ==================================================

                  Text(
                    'Sources',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildSourceChips(
                    context,
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==================================================
                  // STAGES
                  // ==================================================

                  Text(
                    'Stages',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _buildStageChips(
                    context,
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==================================================
                  // DATES
                  // ==================================================

                  Text(
                    'Dates',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _dateField(
                    context,
                    title:
                        'Start Date & Time',
                    value:
                        startDateTime,
                    onTap: () {
                      _pickDateTime(
                        isStart: true,
                      );
                    },
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  _dateField(
                    context,
                    title:
                        'End Date & Time',
                    value:
                        endDateTime,
                    onTap: () {
                      _pickDateTime(
                        isStart: false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ==========================================================
          // APPLY
          // ==========================================================

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.all(16),
              child: SizedBox(
                width:
                    double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _apply,
                  child: const Text(
                    'Apply Filters',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SOURCE CHIPS
  // ============================================================

  Widget _buildSourceChips(
    BuildContext context,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _chip(
          context,
          title: 'All Sources',
          selected:
              selectedSources.isEmpty,
          onTap: () {
            setState(() {
              selectedSources
                  .clear();
            });
          },
        ),

        ...widget.controller
            .sourceOptions
            .map(
          (source) {
            return _chip(
              context,
              title:
                  _capitalize(source),
              selected:
                  selectedSources
                      .contains(
                source,
              ),
              onTap: () {
                setState(() {
                  if (selectedSources
                      .contains(
                    source,
                  )) {
                    selectedSources
                        .remove(
                      source,
                    );
                  } else {
                    selectedSources
                        .add(
                      source,
                    );
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // STAGE CHIPS
  // ============================================================

  Widget _buildStageChips(
    BuildContext context,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.controller
          .stageOptions
          .map(
        (stage) {
          return _chip(
            context,
            title: stage,
            selected:
                selectedStages
                    .contains(
              stage,
            ),
            onTap: () {
              setState(() {
                if (selectedStages
                    .contains(
                  stage,
                )) {
                  selectedStages
                      .remove(
                    stage,
                  );
                } else {
                  selectedStages
                      .add(
                    stage,
                  );
                }
              });
            },
          );
        },
      ).toList(),
    );
  }

  // ============================================================
  // CHIP
  // ============================================================

  Widget _chip(
    BuildContext context, {
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme =
        Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(30),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? Colors.white
              : isDark
                  ? TAppColors.darkCard
                  : const Color(
                      0xFFEFF2F8,
                    ),
          borderRadius:
              BorderRadius.circular(
            30,
          ),
          border: Border.all(
            color: selected
                ? TAppColors.primary
                : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? TAppColors.lightText
                : isDark
                    ? TAppColors.darkText
                    : TAppColors.lightText,
            fontSize: 15,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField(
    BuildContext context, {
    required String title,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final theme =
        Theme.of(context);

    final isDark =
        theme.brightness ==
            Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration:
            BoxDecoration(
          color:
              theme.cardColor,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border: Border.all(
            color: isDark
                ? TAppColors.darkBorder
                : TAppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons
                  .calendar_month_outlined,
              size: 22,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style:
                        TextStyle(
                      color: isDark
                          ? TAppColors
                              .darkSecondaryText
                          : TAppColors
                              .lightSecondaryText,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    value == null
                        ? 'Select date & time'
                        : _formatDateTime(
                            value,
                          ),
                    style:
                        TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE TIME PICKER
  // ============================================================

  Future<void> _pickDateTime({
    required bool isStart,
  }) async {
    final now =
        DateTime.now();

    final current =
        isStart
            ? startDateTime
            : endDateTime;

    final date =
        await showDatePicker(
      context: context,
      initialDate:
          current ?? now,
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (date == null) {
      return;
    }

    final time =
        await showTimePicker(
      context: context,
      initialTime:
          current != null
              ? TimeOfDay
                  .fromDateTime(
                  current,
                )
              : TimeOfDay
                  .fromDateTime(
                  now,
                ),
    );

    if (time == null) {
      return;
    }

    final result =
        DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startDateTime =
            result;
      } else {
        endDateTime =
            result;
      }
    });
  }

  // ============================================================
  // APPLY
  // ============================================================

  Future<void> _apply() async {
    if (startDateTime != null &&
        endDateTime != null &&
        startDateTime!
            .isAfter(
          endDateTime!,
        )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Start date must be before end date',
          ),
        ),
      );

      return;
    }

    await widget.controller
        .applyFilters(
      sources:
          selectedSources,
      stages:
          selectedStages,
      startDate:
          startDateTime,
      endDate:
          endDateTime,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // CLEAR
  // ============================================================

  Future<void> _clear() async {
    setState(() {
      selectedSources.clear();
      selectedStages.clear();
      startDateTime = null;
      endDateTime = null;
    });

    await widget.controller
        .clearFilters();
  }

  // ============================================================
  // CAPITALIZE
  // ============================================================

  String _capitalize(
    String value,
  ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateTime(
    DateTime date,
  ) {
    final day =
        date.day
            .toString()
            .padLeft(2, '0');

    final month =
        date.month
            .toString()
            .padLeft(2, '0');

    final year =
        date.year.toString();

    final hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    final period =
        date.hour >= 12
            ? 'PM'
            : 'AM';

    return '$day/$month/$year • '
        '$hour:$minute $period';
  }
}