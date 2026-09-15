 import 'package:flutter/material.dart';

Widget greetingWidget(BuildContext context) {
    return Text(
      DateTime.now().hour < 17 ? 'Good morning 👋' : 'Good evening 👋',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }