import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/state/study_link_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';

class BookingConfirmationPage extends ConsumerWidget {
  const BookingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyLinkProvider);
    final tutor = state.selectedTutor;
    final session = state.selectedSession;
    final day = session?.date ?? state.selectedDay;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 40, 22, 22),
                  child: Column(children: [
                    Container(
                        width: 86,
                        height: 86,
                        decoration: const BoxDecoration(
                            color: AppColors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 48)),
                    const SizedBox(height: 22),
                    Text("You're booked",
                        style: AppTextStyles.title.copyWith(fontSize: 29)),
                    const SizedBox(height: 12),
                    Text(
                        '${tutor.name.split(' ').first} will see this session and your private note in their session list.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary, fontSize: 15)),
                    const SizedBox(height: 26),
                    AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(children: [
                          Row(children: [
                            InitialsAvatar(
                                initials: tutor.initials,
                                backgroundColor: tutor.avatarColor,
                                size: 48),
                            const SizedBox(width: 11),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(tutor.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: AppColors.text)),
                                  const SizedBox(height: 3),
                                  Text(
                                      session?.subject ?? state.selectedSubject,
                                      style: AppTextStyles.caption),
                                ])),
                          ]),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child:
                                  Divider(color: AppColors.border, height: 1)),
                          _DetailRow(
                            label: 'When',
                            value:
                                '${session?.day ?? state.selectedDay.split(' ').first} ${session?.date ?? day} · ${session?.time ?? state.selectedTime}',
                          ),
                          const SizedBox(height: 8),
                          _DetailRow(
                              label: 'Where',
                              value: session?.location ??
                                  (state.meetingMode == 'Online'
                                      ? 'Online'
                                      : 'Library, study pod 2')),
                          const SizedBox(height: 8),
                          const _DetailRow(
                              label: 'Cost', value: 'Free during pilot'),
                        ])),
                  ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                child: Column(children: [
                  AppButton(
                      label: 'View my sessions',
                      onPressed: () => context.go('/sessions')),
                  const SizedBox(height: 9),
                  AppButton(
                      label: 'Back to home',
                      style: AppButtonStyle.secondary,
                      onPressed: () => context.go('/home')),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: Text(label,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary))),
        const SizedBox(width: 12),
        Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text))),
      ]);
}
