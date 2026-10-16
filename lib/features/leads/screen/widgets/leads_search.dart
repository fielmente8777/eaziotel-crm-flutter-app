// ============================================================
// LEADS SEARCH  (naam, phone, source)
// Likhte hi 0.5 sec baad search (LeadsController.updateSearch),
// x se saaf.
// ============================================================

import 'package:eazotel/features/leads/controller/leads_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'leads_style.dart';

class LeadsSearch extends StatefulWidget {
  final LeadsController controller;

  const LeadsSearch({super.key, required this.controller});

  @override
  State<LeadsSearch> createState() => _LeadsSearchState();
}

class _LeadsSearchState extends State<LeadsSearch> {
  // Tab badal kar wapas aao to likha hua search dikhta rahe
  late final TextEditingController textController = TextEditingController(
    text: widget.controller.searchText.value,
  );

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = LeadsPalette(context);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: w),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Obx(() {
        final hasSearch = widget.controller.searchText.value.isNotEmpty;

        return TextField(
          controller: textController,
          onChanged: widget.controller.updateSearch,
          textInputAction: TextInputAction.search,
          style: TextStyle(color: p.text),
          decoration: InputDecoration(
            hintText: 'Search name, phone, source...',
            hintStyle: TextStyle(color: p.subText, fontSize: 13.5),
            filled: true,
            fillColor: p.card,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            prefixIcon: Icon(Icons.search_rounded, color: p.subText),
            suffixIcon: hasSearch
                ? IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      // Clear TextField
                      textController.clear();

                      // Clear search + API call
                      widget.controller.clearSearch();
                    },
                    icon: Icon(Icons.close_rounded, color: p.subText),
                  )
                : null,
            border: border(p.border),
            enabledBorder: border(p.border),
            focusedBorder: border(p.primary, 1.5),
          ),
        );
      }),
    );
  }
}
