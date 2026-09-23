import 'package:eazotel/features/splash_screen/controllers/splash_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashController controller;

  @override
  void initState() {
    super.initState();

   Get.lazyPut<SplashController>(
  () => SplashController(),
);

controller = Get.find<SplashController>();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        controller.startSplash(context);
      },
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<SplashController>()) {
      Get.delete<SplashController>();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width;

    final screenHeight =
        MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020712),
              Color(0xFF061A4D),
              Color(0xFF0D3BA3),
              Color(0xFF041942),
            ],
            stops: [
              0.0,
              0.35,
              0.65,
              1.0,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: screenHeight * 0.405,
              child: Opacity(
                opacity: 0.07,
                child: SvgPicture.asset(
                  'assets/image/eazotel.svg',
                  width: screenWidth * 0.90,
                ),
              ),
            ),

            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/image/eazotel.svg',
                  width: screenWidth * 0.45,
                ),

                SizedBox(
                  height: screenHeight * 0.012,
                ),

                Text(
                  'Welcome to Eazotel',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.035,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}