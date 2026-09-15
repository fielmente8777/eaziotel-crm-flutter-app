import 'package:eazotel/utils/theme/custome_them/app_colors.dart';
import 'package:flutter/material.dart';

class LeadsEmptyState extends StatelessWidget {
  const LeadsEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark
        ? TAppColors.darkSecondaryText
        : TAppColors.lightSecondaryText;

    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            Icons.people_outline,
            color: textColor,
            size: 50,
          ),

          const SizedBox(height: 12),

          Text(
            'No leads found',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}