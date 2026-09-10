import 'package:eazotel/core/api/google_signin_api.dart';
import 'package:eazotel/features/auth/controllers/login_controller.dart';
import 'package:eazotel/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 55),

              // Logo
              Center(
                child: Column(
                  children: [
                    Text(
                      'EAZOTEL',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'H',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 42),

              // Welcome
              Center(
                child: Text(
                  'Welcome back',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Sign in to your HotelCRM account',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Email
              Text('EMAIL ADDRESS', style: theme.textTheme.labelSmall),

              const SizedBox(height: 7),

              TextFormField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'your@email.com',
                  suffixIcon: Icon(Icons.mail_outline),
                ),
              ),

              const SizedBox(height: 26),

              // Password
              Text('PASSWORD', style: theme.textTheme.labelSmall),

              const SizedBox(height: 7),

              TextFormField(
                controller: controller.passwordController,
                obscureText: false,
                decoration: const InputDecoration(
                  hintText: '••••••••',
                  suffixIcon: Icon(Icons.visibility_off_outlined),
                ),
              ),

              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot password?'),
                ),
              ),

              const SizedBox(height: 12),

              // Sign in button
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final success = await controller.login();

                            if (success && context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const WelcomeScreen(),
                                ),
                                (route) => false,
                              );
                            } else if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login failed')),
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

              // OR
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

              // Google
              // SizedBox(
              //   width: double.infinity,
              //   height: 48,
              //   child: OutlinedButton(
              //     onPressed: () {},
              //     style: OutlinedButton.styleFrom(
              //       backgroundColor: theme.cardTheme.color,
              //       side: BorderSide(
              //         color:
              //             theme.dividerTheme.color ?? theme.colorScheme.outline,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text(
              //           'G',
              //           style: theme.textTheme.titleMedium?.copyWith(
              //             color: Colors.blue,
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),

              //         const SizedBox(width: 12),

              //         Text(
              //           'Continue with Google',
              //           style: theme.textTheme.bodyMedium,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // Google Sign Up
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    side: BorderSide(
                      color:
                          theme.dividerTheme.color ?? theme.colorScheme.outline,
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
                  label: const Text(
                    'Sign Up with Google',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onPressed: () async {
                   ;

                  
                  },
                ),
              ),

              const SizedBox(height: 25),

              // Sign up
              Center(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: "Don't have an account? "),

                      TextSpan(
                        text: 'Sign up free',
                        style: TextStyle(color: theme.colorScheme.primary),
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
    );
  }
}
