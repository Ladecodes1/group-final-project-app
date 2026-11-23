import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation.dart';
import '../../../../app/state/study_link_cubit.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';

class SessionDetailsPage extends StatelessWidget {
  const SessionDetailsPage({this.session, super.key});

  /// The session the student tapped. Null when opened without one, in which
  /// case the next upcoming session is shown.
  final StudySession? session;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudyLinkCubit>().state;
    final current = session ?? _defaultSession(state);
    final tutor = sampleTutors.firstWhere(
      (t) => t.id == current.tutorId,
      orElse: () => state.selectedTutor,
    );
    final firstName = current.tutorName.split(' ').first;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Text(
                            'Confirmed · Tomorrow',
                            style: TextStyle(
                              color: AppColors.greenDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current.subject,
                          style: AppTextStyles.title.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 17),
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  InitialsAvatar(
                                    initials: current.initials,
                                    backgroundColor: tutor.avatarColor,
                                    size: 46,
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          current.tutorName,
                                          style: const TextStyle(
                                            color: AppColors.text,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        const Text(
                                          'Your peer tutor',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<StudyLinkCubit>()
                                          .selectTutor(tutor);
                                      context.push('/tutor-profile');
                                    },
                                    child: const Text(
                                      'Profile',
                                      style: TextStyle(
                                        color: AppColors.green,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 13),
                                child: Divider(
                                  height: 1,
                                  color: AppColors.border,
                                ),
                              ),
                              _SessionInfo(
                                icon: Icons.calendar_today_outlined,
                                title: '${current.day} ${current.date}',
                                subtitle:
                                    '${current.time}–${_endTime(current.time)}',
                              ),
                              const SizedBox(height: 13),
                              _SessionInfo(
                                icon: Icons.location_on_outlined,
                                title: current.mode == 'Online'
                                    ? 'Online session'
                                    : current.location,
                                subtitle: current.mode == 'Online'
                                    ? 'Online'
                                    : 'ALU Kigali campus',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 19),
                        Text(
                          'YOUR NOTE TO ${firstName.toUpperCase()}',
                          style: AppTextStyles.eyebrow,
                        ),
                        const SizedBox(height: 8),
                        AppCard(
                          padding: const EdgeInsets.all(13),
                          child: Text(
                            current.privateNote.isEmpty
                                ? 'No note for this session.'
                                : current.privateNote,
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Text(
                          "After the session you'll be asked to rate it here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (current.isUpcoming)
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _showCancelSheet(context, current),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(
                                color: AppColors.dangerBorder,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            child: const Text('Cancel session'),
                          ),
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

  String _endTime(String start) => '${start.split(':').first}:45';

  static StudySession _defaultSession(StudyLinkState state) => state.sessions
      .firstWhere((s) => s.isUpcoming, orElse: () => state.sessions.first);

  void _showCancelSheet(BuildContext context, StudySession current) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CancelSessionSheet(
        summary:
            '${current.day} ${current.date} · ${current.time} with ${current.tutorName}',
        tutorFirstName: current.tutorName.split(' ').first,
        onCancel: () {
          context.read<StudyLinkCubit>().cancelSession(current.id);
          Navigator.of(sheetContext).pop();
          context.openMainScreen('/sessions');
        },
        onPickAnotherTime: () {
          Navigator.of(sheetContext).pop();
          context.push('/availability');
        },
      ),
    );
  }
}

class _SessionInfo extends StatelessWidget {
  const _SessionInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppColors.green, size: 19),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
    ],
  );
}

class _CancelSessionSheet extends StatelessWidget {
  const _CancelSessionSheet({
    required this.summary,
    required this.tutorFirstName,
    required this.onCancel,
    required this.onPickAnotherTime,
  });
  final String summary;
  final String tutorFirstName;
  final VoidCallback onCancel;
  final VoidCallback onPickAnotherTime;
  static const reasons = [
    'I figured it out',
    'The time no longer works',
    'I found help elsewhere',
    'Something else',
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudyLinkCubit>().state;
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        10,
        18,
        18 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cancel this session?',
                style: AppTextStyles.pageTitle.copyWith(fontSize: 21),
              ),
              const SizedBox(height: 8),
              Text(
                '$summary. $tutorFirstName will see that it was cancelled, and the time opens up for other students.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 17),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Why are you cancelling? ',
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: '(optional)',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: reasons.map((reason) {
                  final selected = state.cancelReason == reason;
                  return ChoiceChip(
                    label: Text(
                      reason,
                      style: TextStyle(
                        color: selected ? AppColors.greenDark : AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: selected,
                    selectedColor: AppColors.mint,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected ? AppColors.green : AppColors.border,
                    ),
                    onSelected: (_) =>
                        context.read<StudyLinkCubit>().setCancelReason(reason),
                  );
                }).toList(),
              ),
              const SizedBox(height: 13),
              AppButton(
                label: 'Yes, cancel session',
                style: AppButtonStyle.danger,
                onPressed: onCancel,
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Pick a new time instead',
                style: AppButtonStyle.secondary,
                onPressed: onPickAnotherTime,
              ),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Keep my session',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
