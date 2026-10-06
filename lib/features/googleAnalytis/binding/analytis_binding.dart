import 'package:eazotel/features/googleAnalytis/controller/analytisController.dart';
 import 'package:eazotel/features/googleAnalytis/services/analytisServices.dart';
import 'package:get/get.dart';

class AnalytisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalytisService>(
      () => AnalytisService(),
    );

    Get.lazyPut<AnalytisController>(
      () => AnalytisController(),
    );
  }
}