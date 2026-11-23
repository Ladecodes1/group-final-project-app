import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/firestore_study_link_backend.dart';
import '../../../../app/state/study_link_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';

class AvailabilityPage extends StatelessWidget {
  const AvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudyLinkCubit>().state;
    final tutor = state.selectedTutor;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 38,
                              height: 42,
                            ),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pick a time',
                                  style: AppTextStyles.pageTitle.copyWith(
                                    fontSize: 21,
                                  ),
                                ),
                                Text(
                                  '${tutor.name} · 45-minute session',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 19),
                      Text(
                        state.slots.isEmpty
                            ? 'Open times'
                            : monthLabel(state.slots.first.startTime),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 9),
                      if (state.slotsLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.days.isEmpty)
                        Text(
                          '${tutor.name} has no open times right now. Please check back later or choose another tutor.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final gap = 6.0;
                            final days = state.days;
                            final width =
                                (constraints.maxWidth -
                                    gap * (days.length - 1)) /
                                days.length;
                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: days.map((value) {
                                final day = (
                                  value.split(' ').first,
                                  value.split(' ').last,
                                );
                                final selected = state.selectedDay == value;
                                return SizedBox(
                                  width: width,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(13),
                                    onTap: () => context
                                        .read<StudyLinkCubit>()
                                        .selectDay(value),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      height: 65,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.green
                                            : Colors.white,
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.green
                                              : AppColors.border,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            day.$1,
                                            style: TextStyle(
                                              color: selected
                                                  ? Colors.white70
                                                  : AppColors.textSecondary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            day.$2,
                                            style: TextStyle(
                                              color: selected
                                                  ? Colors.white
                                                  : AppColors.text,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      const SizedBox(height: 18),
                      const Text(
                        'Open slots',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 9),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const gap = 8.0;
                          final width = (constraints.maxWidth - gap * 2) / 3;
                          return Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: state.timesForSelectedDay.map((time) {
                              final selected = state.selectedTime == time;
                              return SizedBox(
                                width: width,
                                child: OutlinedButton(
                                  onPressed: () => context
                                      .read<StudyLinkCubit>()
                                      .selectTime(time),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 48),
                                    backgroundColor: selected
                                        ? AppColors.green
                                        : Colors.white,
                                    foregroundColor: selected
                                        ? Colors.white
                                        : AppColors.text,
                                    side: BorderSide(
                                      color: selected
                                          ? AppColors.green
                                          : AppColors.border,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  child: Text(time),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 19),
                      const Text(
                        'Where',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: _ModeButton(
                              label: 'On campus',
                              selected: state.meetingMode == 'On campus',
                              onTap: () => context
                                  .read<StudyLinkCubit>()
                                  .selectMeetingMode('On campus'),
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _ModeButton(
                              label: 'Online',
                              selected: state.meetingMode == 'Online',
                              onTap: () => context
                                  .read<StudyLinkCubit>()
                                  .selectMeetingMode('Online'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 19),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'What are you stuck on? ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            TextSpan(
                              text: '(only your booked tutor sees this)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: state.privateNote,
                        onChanged: context
                            .read<StudyLinkCubit>()
                            .setPrivateNote,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'e.g. I do not understand recursion in merge sort',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Text(
                          state.selectedSlot == null
                              ? 'Choose an open time'
                              : '${state.selectedDay} · ${state.selectedTime} · ${state.meetingMode == 'Online' ? 'online' : 'on campus'}',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: 9),
                        AppButton(
                          label: state.isSaving
                              ? 'Booking…'
                              : 'Confirm booking',
                          onPressed:
                              state.isSaving || state.selectedSlot == null
                              ? null
                              : () async {
                                  // Saved in Firestore; if the slot was just
                                  // taken, the Cubit shows a message instead.
                                  final ok = await context
                                      .read<StudyLinkCubit>()
                                      .confirmBooking();
                                  if (ok && context.mounted) {
                                    context.push('/booking-confirmed');
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.green : Colors.white,
        foregroundColor: selected ? Colors.white : AppColors.text,
        side: BorderSide(color: selected ? AppColors.green : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    ),
  );
}
