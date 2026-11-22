import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../shared/widgets/app_button.dart';

final tutorOptInProvider = StateProvider<bool>((ref) => false);

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});
  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _programme = 'Software Eng.';
  String _year = 'Year 1';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!(_formKey.currentState?.validate() ?? false) || _submitting) return;
    setState(() => _submitting = true);
    try {
      final profile = await ref.read(authRepositoryProvider).signUp(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            programme: _programme,
            year: int.tryParse(_year.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1,
            isTutor: ref.read(tutorOptInProvider),
          );
      final controller = ref.read(studyLinkProvider.notifier);
      controller.setCurrentUser(profile);
      unawaited(controller.loadSessions().catchError((_) {}));
      unawaited(controller.loadSubjects().catchError((_) {}));
      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error
                  .toString()
                  .replaceFirst('Exception: ', '')
                  .replaceFirst('Bad state: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        onPressed: _submitting
                                            ? null
                                            : () => context.pop(),
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.centerLeft,
                                        icon: const Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            size: 21),
                                      ),
                                      const SizedBox(height: 20),
                                      Text('Create your account',
                                          style: AppTextStyles.title
                                              .copyWith(fontSize: 27)),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Use your ALU email so tutors know you are a classmate.',
                                          style: AppTextStyles.body.copyWith(
                                              color: AppColors.textSecondary,
                                              fontSize: 14)),
                                      const SizedBox(height: 26),
                                      const _SignUpLabel('Full name'),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _nameController,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        validator: (value) => value == null ||
                                                value.trim().isEmpty
                                            ? 'Enter your full name'
                                            : null,
                                        decoration: const InputDecoration(
                                            hintText: 'e.g. Aline Uwimana'),
                                      ),
                                      const SizedBox(height: 14),
                                      const _SignUpLabel('ALU email'),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) => value == null ||
                                                !value.contains('@')
                                            ? 'Enter a valid ALU email'
                                            : null,
                                        decoration: const InputDecoration(
                                            hintText: 'you@alustudent.com'),
                                      ),
                                      const SizedBox(height: 14),
                                      Row(children: [
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              const _SignUpLabel('Programme'),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<String>(
                                                initialValue: _programme,
                                                isExpanded: true,
                                                decoration:
                                                    const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        13)),
                                                items: const [
                                                  'Software Eng.',
                                                  'Global Challenges',
                                                  'Entrepreneurial Leadership',
                                                  'Policy & Advocacy'
                                                ]
                                                    .map((value) => DropdownMenuItem(
                                                        value: value,
                                                        child: Text(value,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        13))))
                                                    .toList(),
                                                onChanged: _submitting
                                                    ? null
                                                    : (value) {
                                                        if (value != null) {
                                                          setState(() =>
                                                              _programme =
                                                                  value);
                                                        }
                                                      },
                                              ),
                                            ])),
                                        const SizedBox(width: 12),
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              const _SignUpLabel('Year'),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<String>(
                                                initialValue: _year,
                                                isExpanded: true,
                                                decoration:
                                                    const InputDecoration(
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        13)),
                                                items: const [
                                                  'Year 1',
                                                  'Year 2',
                                                  'Year 3',
                                                  'Year 4'
                                                ]
                                                    .map((value) => DropdownMenuItem(
                                                        value: value,
                                                        child: Text(value,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        13))))
                                                    .toList(),
                                                onChanged: _submitting
                                                    ? null
                                                    : (value) {
                                                        if (value != null) {
                                                          setState(() =>
                                                              _year = value);
                                                        }
                                                      },
                                              ),
                                            ])),
                                      ]),
                                      const SizedBox(height: 14),
                                      const _SignUpLabel('Password'),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        validator: (value) =>
                                            value == null || value.length < 8
                                                ? 'Use at least 8 characters'
                                                : null,
                                        decoration: const InputDecoration(
                                            hintText: 'At least 8 characters'),
                                      ),
                                      const SizedBox(height: 16),
                                      Consumer(builder: (context, ref, child) {
                                        final optedIn =
                                            ref.watch(tutorOptInProvider);
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                              color: AppColors.mint,
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Checkbox(
                                                    value: optedIn,
                                                    activeColor:
                                                        AppColors.green,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    onChanged: _submitting
                                                        ? null
                                                        : (value) => ref
                                                            .read(
                                                                tutorOptInProvider
                                                                    .notifier)
                                                            .state = value ?? false),
                                                const Expanded(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 9),
                                                        child: Text.rich(TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                  text:
                                                                      'I can also help others. ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                              TextSpan(
                                                                  text:
                                                                      'Show me as a tutor for courses I have passed.')
                                                            ],
                                                            style: TextStyle(
                                                                color: AppColors
                                                                    .text,
                                                                fontSize: 13,
                                                                height:
                                                                    1.4))))),
                                              ]),
                                        );
                                      }),
                                      const SizedBox(height: 24),
                                      AppButton(
                                          label: _submitting
                                              ? 'Creating account…'
                                              : 'Create account',
                                          onPressed: _submitting
                                              ? null
                                              : _createAccount),
                                    ])),
                          ),
                        ),
                      ),
                    ),
                  )),
        ),
      );
}

class _SignUpLabel extends StatelessWidget {
  const _SignUpLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13));
}
