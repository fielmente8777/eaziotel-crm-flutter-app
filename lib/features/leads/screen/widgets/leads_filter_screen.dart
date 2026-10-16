import 'package:eazotel/features/leads/controller/leads_controller.dart';
import 'package:eazotel/features/leads/screen/widgets/leads_style.dart';
import 'package:flutter/material.dart';

class LeadsFilterScreen extends StatefulWidget {
  final LeadsController controller;

  const LeadsFilterScreen({super.key, required this.controller});

  @override
  State<LeadsFilterScreen> createState() => _LeadsFilterScreenState();
}

class _LeadsFilterScreenState extends State<LeadsFilterScreen> {
  late List<String> selectedSources;

  late List<String> selectedStages;

  DateTime? startDateTime;

  DateTime? endDateTime;

  @override
  void initState() {
    super.initState();

    selectedSources = List<String>.from(widget.controller.selectedSources);

    selectedStages = List<String>.from(widget.controller.selectedStages);

    startDateTime = widget.controller.startDateTime.value;

    endDateTime = widget.controller.endDateTime.value;
  }

  /// Abhi chune hue filter (badge): source + stage + date range (1)
  int get _count =>
      selectedSources.length +
      selectedStages.length +
      (startDateTime != null || endDateTime != null ? 1 : 0);

  /// Jaldi wali date: aaj / pichhle 7 / 30 din (Apply par lagti hai)
  void _quickRange(int days) {
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days));
    setState(() {
      startDateTime = start;
      endDateTime = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = LeadsPalette(context);
    final wide = MediaQuery.sizeOf(context).width >= 600;

    final startField = _dateField(
      context,
      title: 'Start Date & Time',
      value: startDateTime,
      onTap: () {
        _pickDateTime(isStart: true);
      },
    );
    final endField = _dateField(
      context,
      title: 'End Date & Time',
      value: endDateTime,
      onTap: () {
        _pickDateTime(isStart: false);
      },
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: theme.appBarTheme.elevation ?? 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.text, size: 20),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filters',
              style: TextStyle(
                color: p.text,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (_count > 0) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: p.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_count selected',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---------- SOURCES ----------
                      _section(
                        context,
                        icon: Icons.hub_outlined,
                        title: 'Sources',
                        count: selectedSources.length,
                        child: _buildSourceChips(context),
                      ),
                      const SizedBox(height: 14),

                      // ---------- STAGES ----------
                      _section(
                        context,
                        icon: Icons.flag_outlined,
                        title: 'Stages',
                        count: selectedStages.length,
                        child: _buildStageChips(context),
                      ),
                      const SizedBox(height: 14),

                      // ---------- DATES ----------
                      _section(
                        context,
                        icon: Icons.date_range_outlined,
                        title: 'Dates',
                        count: startDateTime != null || endDateTime != null
                            ? 1
                            : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final q in const [
                                  (0, 'Today'),
                                  (7, 'Last 7 days'),
                                  (30, 'Last 30 days'),
                                ])
                                  ActionChip(
                                    avatar: const Icon(
                                      Icons.bolt_rounded,
                                      size: 16,
                                    ),
                                    label: Text(q.$2),
                                    onPressed: () => _quickRange(q.$1),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (wide)
                              Row(
                                children: [
                                  Expanded(child: startField),
                                  const SizedBox(width: 12),
                                  Expanded(child: endField),
                                ],
                              )
                            else ...[
                              startField,
                              const SizedBox(height: 12),
                              endField,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ---------- RESET + APPLY ----------
          Container(
            decoration: BoxDecoration(
              color: p.card,
              border: Border(top: BorderSide(color: p.border)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _clear,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: p.text,
                            side: BorderSide(color: p.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.restart_alt_rounded, size: 20),
                          label: const Text('Reset'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _count > 0
                                ? 'Apply Filters ($_count)'
                                : 'Apply Filters',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required Widget child,
  }) {
    final p = LeadsPalette(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: p.tint(p.primary),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: p.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: p.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (count > 0)
                Text(
                  '$count selected',
                  style: TextStyle(
                    color: p.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // SOURCE CHIPS
  // ============================================================

  Widget _buildSourceChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _chip(
          context,
          title: 'All Sources',
          selected: selectedSources.isEmpty,
          onTap: () {
            setState(() {
              selectedSources.clear();
            });
          },
        ),

        ...widget.controller.sourceOptions.map((source) {
          return _chip(
            context,
            title: _capitalize(source),
            color: LeadsStyle.source(source).color,
            icon: LeadsStyle.source(source).icon,
            selected: selectedSources.contains(source),
            onTap: () {
              setState(() {
                if (selectedSources.contains(source)) {
                  selectedSources.remove(source);
                } else {
                  selectedSources.add(source);
                }
              });
            },
          );
        }),
      ],
    );
  }

  // ============================================================
  // STAGE CHIPS
  // ============================================================

  Widget _buildStageChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.controller.stageOptions.map((stage) {
        return _chip(
          context,
          title: stage,
          color: LeadsStyle.stage(stage),
          selected: selectedStages.contains(stage),
          onTap: () {
            setState(() {
              if (selectedStages.contains(stage)) {
                selectedStages.remove(stage);
              } else {
                selectedStages.add(stage);
              }
            });
          },
        );
      }).toList(),
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
    Color? color,
    IconData? icon,
  }) {
    final p = LeadsPalette(context);
    final accent = color ?? p.primary;

    return Material(
      color: selected ? p.tint(accent) : p.inner,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected ? accent : p.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Icon(Icons.check_rounded, size: 16, color: p.onTint(accent))
              else if (icon != null)
                Icon(icon, size: 16, color: p.onTint(accent)),
              if (selected || icon != null) const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: selected ? p.onTint(accent) : p.text,
                  fontSize: 13.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
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
    final p = LeadsPalette(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: p.inner,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value == null ? p.border : p.primary),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 22,
              color: value == null ? p.subText : p.accent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: p.subText, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    value == null
                        ? 'Select date & time'
                        : _formatDateTime(value),
                    style: TextStyle(
                      color: value == null ? p.subText : p.text,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.subText),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE TIME PICKER
  // ============================================================

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();

    final current = isStart ? startDateTime : endDateTime;

    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : TimeOfDay.fromDateTime(now),
    );

    if (time == null) {
      return;
    }

    final result = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        startDateTime = result;
      } else {
        endDateTime = result;
      }
    });
  }

  // ============================================================
  // APPLY
  // ============================================================

  Future<void> _apply() async {
    if (startDateTime != null &&
        endDateTime != null &&
        startDateTime!.isAfter(endDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );

      return;
    }

    await widget.controller.applyFilters(
      sources: selectedSources,
      stages: selectedStages,
      startDate: startDateTime,
      endDate: endDateTime,
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

    await widget.controller.clearFilters();
  }

  // ============================================================
  // CAPITALIZE
  // ============================================================

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year • '
        '$hour:$minute $period';
  }
}
