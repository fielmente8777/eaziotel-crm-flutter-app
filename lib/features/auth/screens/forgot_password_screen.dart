// ============================================================
// FORGOT PASSWORD SCREEN  (web: Forgot password? + Reset your password)
//
//   Step 1: email          -> "Send reset code"
//   Step 2: code + new password
//   Step 3: "Password updated" -> Back to sign in
//
// Full width on phones; a 460-wide card in the middle on tablet / web.
// ============================================================

import 'package:eazotel/features/auth/controllers/forgot_password_controller.dart';
import 'package:eazotel/features/setting_screen/screen/widgets/setting_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.email = ''});

  /// Pre-fill the email typed on the login screen (if any)
  final String email;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordController c = Get.put(
    ForgotPasswordController(email: widget.email),
  );

  @override
  void dispose() {
    Get.delete<ForgotPasswordController>(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);

    return Scaffold(
      backgroundColor: p.inner,
      appBar: AppBar(
        backgroundColor: p.inner,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: p.text),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= 600;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, wide ? 24 : 4, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: EdgeInsets.all(wide ? 28 : 20),
                    decoration: BoxDecoration(
                      color: p.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: p.border),
                    ),
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: switch (c.step.value) {
                          ForgotStep.email => _EmailStep(c: c),
                          ForgotStep.reset => _ResetStep(c: c),
                          ForgotStep.done => const _DoneStep(),
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// STEP 1: EMAIL
// ============================================================

class _EmailStep extends StatelessWidget {
  const _EmailStep({required this.c});

  final ForgotPasswordController c;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(
          icon: Icons.lock_reset_rounded,
          title: 'Forgot password?',
          subtitle: 'Enter your email and we will send you a reset code.',
        ),
        const SizedBox(height: 22),
        _Field(
          c: c,
          name: 'email',
          label: 'Email',
          hint: 'you@hotel.com',
          icon: Icons.mail_outline_rounded,
          controller: c.emailController,
          keyboard: TextInputType.emailAddress,
          onSubmit: (_) => c.sendCode(),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _PrimaryButton(
            label: c.isSending.value ? 'Sending...' : 'Send reset code',
            busy: c.isSending.value,
            onTap: () {
              FocusScope.of(context).unfocus();
              c.sendCode();
            },
          ),
        ),
        const SizedBox(height: 14),
        _LinkRow(
          text: 'Already have a code?',
          link: 'Enter it here',
          onTap: c.haveCode,
        ),
        _LinkRow(
          text: 'Remember your password?',
          link: 'Back to sign in',
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

// ============================================================
// STEP 2: CODE + NEW PASSWORD
// ============================================================

class _ResetStep extends StatelessWidget {
  const _ResetStep({required this.c});

  final ForgotPasswordController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    return Column(
      key: const ValueKey('reset'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Header(
          icon: Icons.password_rounded,
          title: 'Reset your password',
          subtitle:
              'Enter the 6-digit code we emailed you and choose a new password.',
        ),
        const SizedBox(height: 22),
        _Field(
          c: c,
          name: 'email',
          label: 'Email',
          hint: 'you@hotel.com',
          icon: Icons.mail_outline_rounded,
          controller: c.emailController,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _Field(
          c: c,
          name: 'otp',
          label: 'Verification code',
          hint: '••••••',
          icon: Icons.pin_outlined,
          controller: c.otpController,
          keyboard: TextInputType.number,
          letterSpacing: 6,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(
              ForgotPasswordController.otpLength,
            ),
          ],
          autofill: const [AutofillHints.oneTimeCode],
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              "Sent to your email. Didn't get it?",
              style: TextStyle(color: p.subText, fontSize: 12.5),
            ),
            Obx(() {
              final wait = c.cooldown.value;
              final sending = c.isSending.value;
              return TextButton(
                onPressed: wait > 0 || sending
                    ? null
                    : () => c.sendCode(resend: true),
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                child: Text(
                  sending
                      ? 'Sending...'
                      : wait > 0
                      ? 'Resend in ${wait}s'
                      : 'Resend code',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        _Field(
          c: c,
          name: 'password',
          label: 'New password',
          hint: 'Create a new password',
          icon: Icons.lock_outline_rounded,
          controller: c.passwordController,
          password: true,
          autofill: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: 8),
        _Rules(c: c),
        const SizedBox(height: 14),
        _Field(
          c: c,
          name: 'confirm',
          label: 'Confirm new password',
          hint: 'Re-enter the new password',
          icon: Icons.lock_outline_rounded,
          controller: c.confirmController,
          password: true,
          onSubmit: (_) => c.resetPassword(),
        ),
        const SizedBox(height: 22),
        Obx(
          () => _PrimaryButton(
            label: c.isResetting.value ? 'Updating...' : 'Reset password',
            busy: c.isResetting.value,
            onTap: () {
              FocusScope.of(context).unfocus();
              c.resetPassword();
            },
          ),
        ),
        const SizedBox(height: 14),
        _LinkRow(
          text: 'Remember your password?',
          link: 'Back to sign in',
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

class _Rules extends StatelessWidget {
  const _Rules({required this.c});

  final ForgotPasswordController c;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    const green = Color(0xFF16A34A);
    return Obx(() {
      final value = c.password.value;
      return Wrap(
        spacing: 14,
        runSpacing: 6,
        children: [
          for (final rule in ForgotPasswordController.rules)
            Builder(
              builder: (_) {
                final ok = rule.test(value);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ok
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 15,
                      color: ok ? green : p.subText.withValues(alpha: .6),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        rule.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: ok ? green : p.subText,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      );
    });
  }
}

// ============================================================
// STEP 3: DONE
// ============================================================

class _DoneStep extends StatelessWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    return Column(
      key: const ValueKey('done'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: green.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: green,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _Header(
          title: 'Password updated',
          subtitle:
              'Your password has been changed. Sign in with your new password.',
          center: true,
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: 'Back to sign in',
          busy: false,
          icon: Icons.login_rounded,
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

// ============================================================
// PARTS
// ============================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    this.icon,
    this.center = false,
  });

  final IconData? icon;
  final String title;
  final String subtitle;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: p.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: p.primary),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          title,
          textAlign: align,
          style: TextStyle(
            color: p.text,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          textAlign: align,
          style: TextStyle(color: p.subText, fontSize: 13.5, height: 1.4),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.c,
    required this.name,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboard,
    this.password = false,
    this.formatters,
    this.autofill,
    this.letterSpacing,
    this.onSubmit,
  });

  final ForgotPasswordController c;
  final String name;
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final bool password;
  final List<TextInputFormatter>? formatters;
  final Iterable<String>? autofill;
  final double? letterSpacing;
  final ValueChanged<String>? onSubmit;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    const red = Color(0xFFDC2626);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return Obx(() {
      final error = c.errors[name];
      final hidden = password && !c.showPassword.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: p.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboard,
            obscureText: hidden,
            inputFormatters: formatters,
            autofillHints: autofill,
            onChanged: (_) => c.clearError(name),
            onSubmitted: onSubmit,
            textInputAction: onSubmit == null
                ? TextInputAction.next
                : TextInputAction.done,
            style: TextStyle(
              color: p.text,
              fontSize: 14,
              letterSpacing: letterSpacing,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(
                color: p.subText.withValues(alpha: .8),
                fontSize: 14,
                letterSpacing: letterSpacing,
              ),
              prefixIcon: Icon(icon, size: 19, color: p.subText),
              suffixIcon: password
                  ? IconButton(
                      onPressed: () =>
                          c.showPassword.value = !c.showPassword.value,
                      icon: Icon(
                        hidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 19,
                        color: p.subText,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: p.inner,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: border(error != null ? red : p.border),
              enabledBorder: border(error != null ? red : p.border),
              focusedBorder: border(error != null ? red : p.primary, 1.5),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 2),
              child: Text(
                error,
                style: const TextStyle(color: red, fontSize: 12),
              ),
            ),
        ],
      );
    });
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.busy,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool busy;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: busy ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: p.primary.withValues(alpha: .6),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(
          busy ? Icons.hourglass_top_rounded : (icon ?? Icons.send_rounded),
          size: 18,
        ),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.text, required this.link, required this.onTap});

  final String text;
  final String link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SettingPalette(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: TextStyle(color: p.subText, fontSize: 13)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          child: Text(
            link,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
