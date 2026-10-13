import 'package:eazotel/features/auth/controllers/login_controller.dart';
import 'package:eazotel/features/dashboard_screen/screens/dashbord_botum_nav.dart';
import 'package:eazotel/main.dart';
import 'package:eazotel/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final pasword = controller.showPassword;

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final screenHeight = MediaQuery.of(context).size.height;

    final isDarkMode = theme.brightness == Brightness.light;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          // Email + password ko password manager (Google / iCloud) se jodta hai.
          // Save sirf login successful hone par hota hai (LoginController me).
          child: AutofillGroup(
            onDisposeAction: AutofillContextAction.cancel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 55),

                // ==================================================
                // LOGO
                // ==================================================
                Center(
                  child: Column(
                    children: [
                      Visibility(
                        visible: !isDarkMode,
                        child: SvgPicture.asset(
                          'assets/image/eazotel.svg',
                          width: screenWidth * 0.35,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Container(
                      //   height: 50,
                      //   width: 50,
                      //   decoration: BoxDecoration(
                      //     color: theme.colorScheme.primary,
                      //     borderRadius: BorderRadius.circular(15),
                      //   ),
                      //   alignment: Alignment.center,
                      //   child: Text(
                      //     'H',
                      //     style: theme.textTheme.titleLarge?.copyWith(
                      //       color: theme.colorScheme.onPrimary,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // WELCOME
                // ==================================================
                Center(
                  child: Text(
                    'Welcome back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Sign in to your HotelCRM account',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ==================================================
                // EMAIL
                // ==================================================
                Text('EMAIL ADDRESS', style: theme.textTheme.labelSmall),

                const SizedBox(height: 7),

                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  // Sirf "username": "email" hint bhi dene par password manager
                  // is field ko login ka username nahi, ek aam email field maanta hai
                  autofillHints: const [AutofillHints.username],
                  decoration: const InputDecoration(
                    hintText: 'your@email.com',
                    suffixIcon: Icon(Icons.mail_outline),
                  ),
                ),

                const SizedBox(height: 26),

                // ==================================================
                // PASSWORD
                // ==================================================
                Text('PASSWORD', style: theme.textTheme.labelSmall),

                const SizedBox(height: 7),

                Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    obscureText: !controller.showPassword.value,
                    enableInteractiveSelection: true,
                    keyboardType: TextInputType.visiblePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.password],

                    decoration: InputDecoration(
                      hintText: '••••••••',

                      suffixIcon: IconButton(
                        onPressed: controller.toggleShowPassword,
                        icon: Icon(
                          controller.showPassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // FORGOT PASSWORD
                // ==================================================
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // SIGN IN BUTTON
                // ==================================================
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              final success = await controller.login();

                              if (!context.mounted) {
                                return;
                              }

                              if (success) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardBottomNav(),
                                  ),
                                  (route) => false,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ Login failed'),
                                  ),
                                );
                              }
                            },
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // ==================================================
                // OR
                // ==================================================
                Row(
                  children: [
                    const Expanded(child: Divider()),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or continue with',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // ==================================================
                // GOOGLE LOGIN
                // ==================================================
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: BorderSide(
                          color:
                              theme.dividerTheme.color ??
                              theme.colorScheme.outline,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      icon: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.red,
                        size: 30,
                      ),

                      label: controller.isLoading.value
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Continue with Google',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),

                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              final success = await controller
                                  .loginWithGoogle();

                              if (!context.mounted) {
                                return;
                              }

                              if (success) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardBottomNav(),
                                  ),
                                  (route) => false,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('❌ Google login failed'),
                                  ),
                                );
                              }
                            },
                    ),
                  );
                }),

                const SizedBox(height: 25),

                // ==================================================
                // SIGN UP
                // ==================================================
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),

                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: theme.colorScheme.primary,
                            decorationThickness: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
