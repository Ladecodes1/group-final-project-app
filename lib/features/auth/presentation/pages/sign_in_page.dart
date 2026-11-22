import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/custom_dialog.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});
  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false) || _submitting) return;
    setState(() => _submitting = true);
    try {
      final profile = await ref.read(authRepositoryProvider).signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      final controller = ref.read(studyLinkProvider.notifier);
      controller.setCurrentUser(profile);
      unawaited(controller.loadSessions().catchError((_) {}));
      unawaited(controller.loadSubjects().catchError((_) {}));
      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) {
        final message = error
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('Bad state: ', '');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      showStudyLinkMessage(context,
          title: 'Forgot password?',
          message:
              'Enter your ALU email above, then choose Forgot password again.');
      return;
    }
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Password reset instructions have been sent to your email.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 34, 24, 22),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                            color: AppColors.green,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: const Icon(Icons.link_rounded,
                                            color: Colors.white, size: 25),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text('StudyLink',
                                          style: TextStyle(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.text,
                                              letterSpacing: -.6)),
                                    ]),
                                    const SizedBox(height: 48),
                                    Text(
                                        'Stuck on a topic? A classmate has been there.',
                                        style: AppTextStyles.title.copyWith(
                                            fontSize: 31, height: 1.14)),
                                    const SizedBox(height: 14),
                                    Text(
                                        'Book a one-to-one session with an ALU peer who has already passed the course.',
                                        style: AppTextStyles.body.copyWith(
                                            fontSize: 15,
                                            color: AppColors.textSecondary,
                                            height: 1.55)),
                                    const SizedBox(height: 34),
                                    const _FieldLabel('ALU email'),
                                    const SizedBox(height: 7),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      validator: (value) =>
                                          value == null || !value.contains('@')
                                              ? 'Enter a valid ALU email'
                                              : null,
                                      decoration: const InputDecoration(
                                          hintText: 'you@alustudent.com'),
                                    ),
                                    const SizedBox(height: 16),
                                    const _FieldLabel('Password'),
                                    const SizedBox(height: 7),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _signIn(),
                                      validator: (value) => value == null ||
                                              value.length < 8
                                          ? 'Password must be at least 8 characters'
                                          : null,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter your password'),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: _submitting
                                            ? null
                                            : _sendPasswordReset,
                                        child: const Text('Forgot password?',
                                            style: TextStyle(
                                                color: AppColors.green,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    AppButton(
                                      label: _submitting
                                          ? 'Signing in…'
                                          : 'Sign in',
                                      onPressed: _submitting ? null : _signIn,
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                        child: Wrap(
                                            alignment: WrapAlignment.center,
                                            children: [
                                          const Text('New to StudyLink? ',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 14)),
                                          GestureDetector(
                                            onTap: _submitting
                                                ? null
                                                : () =>
                                                    context.push('/sign-up'),
                                            child: const Text(
                                                'Create an account',
                                                style: TextStyle(
                                                    color: AppColors.green,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14)),
                                          ),
                                        ])),
                                    if (constraints.maxHeight > 700)
                                      const SizedBox(height: 8),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )),
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600));
}
