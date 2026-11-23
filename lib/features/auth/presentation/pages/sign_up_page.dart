import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

final tutorOptInProvider = StateProvider<bool>((ref) => false);

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});
  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                    child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
                      ),
                      const SizedBox(height: 20),
                      Text('Create your account', style: AppTextStyles.title.copyWith(fontSize: 27)),
                      const SizedBox(height: 8),
                      Text('Use your ALU email so tutors know you are a classmate.', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontSize: 14)),
                      const SizedBox(height: 26),
                      const _SignUpLabel('Full name'),
                      const SizedBox(height: 6),
                      TextFormField(validator: (v) => v == null || v.trim().isEmpty ? 'Enter your full name' : null, decoration: const InputDecoration(hintText: 'e.g. Aline Uwimana')),
                      const SizedBox(height: 14),
                      const _SignUpLabel('ALU email'),
                      const SizedBox(height: 6),
                      TextFormField(keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Enter a valid ALU email' : null, decoration: const InputDecoration(hintText: 'you@alustudent.com')),
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const _SignUpLabel('Programme'), const SizedBox(height: 6),
                          DropdownButtonFormField<String>(initialValue: 'Software Eng.', isExpanded: true, decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13)), items: const ['Software Eng.', 'Global Challenges', 'Entrepreneurial Leadership', 'Policy & Advocacy'].map((v) => DropdownMenuItem(value: v, child: Text(v, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)))).toList(), onChanged: (_) {}),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const _SignUpLabel('Year'), const SizedBox(height: 6),
                          DropdownButtonFormField<String>(initialValue: 'Year 1', isExpanded: true, decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13)), items: const ['Year 1', 'Year 2', 'Year 3', 'Year 4'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(), onChanged: (_) {}),
                        ])),
                      ]),
                      const SizedBox(height: 14),
                      const _SignUpLabel('Password'),
                      const SizedBox(height: 6),
                      TextFormField(obscureText: true, validator: (v) => v == null || v.length < 8 ? 'Use at least 8 characters' : null, decoration: const InputDecoration(hintText: 'At least 8 characters')),
                      const SizedBox(height: 16),
                      Consumer(builder: (context, ref, child) {
                        final optedIn = ref.watch(tutorOptInProvider);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Checkbox(value: optedIn, activeColor: AppColors.green, visualDensity: VisualDensity.compact, onChanged: (v) => ref.read(tutorOptInProvider.notifier).state = v ?? false),
                            const Expanded(child: Padding(padding: EdgeInsets.only(top: 9), child: Text.rich(TextSpan(children: [TextSpan(text: 'I can also help others. ', style: TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: 'Show me as a tutor for courses I have passed.')], style: TextStyle(color: AppColors.text, fontSize: 13, height: 1.4))))),
                          ]),
                        );
                      }),
                      const SizedBox(height: 24),
                      AppButton(label: 'Create account', onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) context.go('/home');
                      }),
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
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 13));
}
