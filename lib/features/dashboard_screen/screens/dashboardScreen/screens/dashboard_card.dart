import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.white,
              ),

              const SizedBox(height: 16),

              Container(
                height: 20,
                width: 180,
                color: Colors.white,
              ),

              const SizedBox(height: 12),

              Container(
                height: 14,
                width: double.infinity,
                color: Colors.white,
              ),

              const SizedBox(height: 8),

              Container(
                height: 14,
                width: 220,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}