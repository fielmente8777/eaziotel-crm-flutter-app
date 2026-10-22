// ============================================================
// LEADS EMPTY STATE
// No leads. If a filter / search is applied, a "Clear filters" button.
// (The same shows in "Recent Leads" on Home)
// ============================================================

import 'package:flutter/material.dart';

import 'leads_style.dart';

class LeadsEmptyState extends StatelessWidget {
  const LeadsEmptyState({super.key, this.hasFilters = false, this.onClear});

  final bool hasFilters;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final p = LeadsPalette(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: p.tint(p.primary),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters
                    ? Icons.filter_alt_off_rounded
                    : Icons.people_outline_rounded,
                color: p.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              hasFilters ? 'No leads match' : 'No leads found',
              style: TextStyle(
                color: p.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasFilters
                  ? 'Try changing the search or removing some filters.'
                  : 'New enquiries will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.subText, fontSize: 13),
            ),
            if (onClear != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
