import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Finish disposing the previous account's routes before registering controllers
/// with the same GetX types for the next account.
class SessionNavigation {
  SessionNavigation._();

  static Future<void> restart({
    required BuildContext context,
    required VoidCallback clearControllers,
    required Widget Function() destination,
  }) async {
    final previousRoute = ModalRoute.of(context);
    if (previousRoute == null) {
      throw StateError('Account switching requires an active route');
    }

    Get.offAll<void>(
      () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_top_rounded, size: 32),
              SizedBox(height: 12),
              Text('Opening account…'),
            ],
          ),
        ),
      ),
      routeName: '/account-switch',
      transition: Transition.noTransition,
    );

    // GetX removes dependencies by type when a route is disposed. Creating the
    // next dashboard earlier lets disposal delete its newly registered instances.
    await previousRoute.completed;
    clearControllers();
    Get.offAll<void>(destination, transition: Transition.noTransition);
  }
}
