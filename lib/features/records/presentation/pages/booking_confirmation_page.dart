import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_cubit.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';

class BookingConfirmationPage extends StatelessWidget {
  const BookingConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudyLinkCubit>().state;
    final session = state.sessions.isEmpty ? null : state.sessions.first;
    if (session == null) {
      return const Scaffold(body: Center(child: Text('No booking details found.')));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                    children: [
                      Center(
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 46),
                        ),
                      ),
                      const SizedBox(height: 21),
                      Text(
                        "You're booked",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title.copyWith(fontSize: 29),
                      ),
                      const SizedBox(height: 11),
                      Text(
                        '${session.tutorName.split(' ').first} will see this session and the private note you shared.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 25),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                InitialsAvatar(
                                  initials: session.initials,
                                  backgroundColor: state.selectedTutor.avatarColor,
                                  size: 48,
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.tutorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(session.subject, style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: AppColors.border, height: 1),
                            ),
                            _DetailRow(
                              label: 'When',
                              value: '${session.day} ${session.date} Sep · ${session.time}–${_endTime(session.time)}',
                            ),
                            const SizedBox(height: 8),
                            _DetailRow(label: 'Where', value: session.location),
                            const SizedBox(height: 8),
                            const _DetailRow(label: 'Cost', value: 'Free during pilot'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 13),
                      const Text(
                        'Booking confirmation shown with local demo data until Firestore booking CRUD is connected.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 18),
                  child: Column(
                    children: [
                      AppButton(
                        label: 'View my sessions',
                        onPressed: () => context.go('/sessions'),
                      ),
                      const SizedBox(height: 9),
                      AppButton(
                        label: 'Back to home',
                        style: AppButtonStyle.secondary,
                        onPressed: () => context.go('/home'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _endTime(String start) {
    final pieces = start.split(':');
    final hour = int.tryParse(pieces.first) ?? 0;
    final minute = (int.tryParse(pieces.length > 1 ? pieces[1] : '0') ?? 0) + 45;
    return '${(hour + minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      );
}
