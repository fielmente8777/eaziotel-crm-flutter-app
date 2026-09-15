import 'package:eazotel/features/dashboard_screen/controllers/leads_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeadsSearch extends StatefulWidget {
  final LeadsController controller;

  const LeadsSearch({super.key, required this.controller});

  @override
  State<LeadsSearch> createState() => _LeadsSearchState();
}

class _LeadsSearchState extends State<LeadsSearch> {
  final TextEditingController textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Obx(() {
        final hasSearch = widget.controller.searchText.value.isNotEmpty;

        return TextField(
          controller: textController,

          onChanged: widget.controller.updateSearch,

          decoration: InputDecoration(
            hintText: 'Search name, phone, source...',

            prefixIcon: const Icon(Icons.search),

            suffixIcon: hasSearch
                ? IconButton(
                    onPressed: () {
                      // Clear TextField
                      textController.clear();

                      // Clear search + API call
                      widget.controller.clearSearch();
                    },
                    icon: const Icon(Icons.close),
                  )
                : null,
          ),
        );
      }),
    );
  }
}
