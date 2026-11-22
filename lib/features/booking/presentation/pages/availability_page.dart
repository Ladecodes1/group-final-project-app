import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class AvailabilityPage extends ConsumerStatefulWidget {
  const AvailabilityPage({super.key});

  @override
  ConsumerState<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends ConsumerState<AvailabilityPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(studyLinkProvider);
      ref.read(studyLinkProvider.notifier).loadAvailability(
            state.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyLinkProvider);
    final tutor = state.selectedTutor;
    final selectedDate =
        state.selectedDate ?? DateTime.now().add(const Duration(days: 1));
    final days = List.generate(
        5, (index) => DateTime.now().add(Duration(days: index + 1)));
    final month = _month(selectedDate.month);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 15, 18, 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          IconButton(
                              onPressed: () => context.pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints.tightFor(
                                  width: 36, height: 42),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 20)),
                          const SizedBox(width: 5),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Pick a time',
                                    style: AppTextStyles.pageTitle
                                        .copyWith(fontSize: 21)),
                                Text('${tutor.name} · 45-minute session',
                                    style: AppTextStyles.caption
                                        .copyWith(fontSize: 12)),
                              ])),
                        ]),
                        const SizedBox(height: 22),
                        Text('$month ${selectedDate.year}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text)),
                        const SizedBox(height: 9),
                        Row(
                            children: days.map((day) {
                          final selected = day.year == selectedDate.year &&
                              day.month == selectedDate.month &&
                              day.day == selectedDate.day;
                          return Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(13),
                                    onTap: () => ref
                                        .read(studyLinkProvider.notifier)
                                        .selectDate(day),
                                    child: Container(
                                      height: 65,
                                      decoration: BoxDecoration(
                                          color: selected
                                              ? AppColors.green
                                              : Colors.white,
                                          border: Border.all(
                                              color: selected
                                                  ? AppColors.green
                                                  : AppColors.border),
                                          borderRadius:
                                              BorderRadius.circular(13)),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(_weekday(day),
                                                style: TextStyle(
                                                    color: selected
                                                        ? Colors.white70
                                                        : AppColors
                                                            .textSecondary,
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            const SizedBox(height: 3),
                                            Text(day.day.toString(),
                                                style: TextStyle(
                                                    color: selected
                                                        ? Colors.white
                                                        : AppColors.text,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ]),
                                    ),
                                  )));
                        }).toList()),
                        const SizedBox(height: 18),
                        const Text('Open slots',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text)),
                        const SizedBox(height: 9),
                        if (state.isLoadingSlots)
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: LoadingIndicator())
                        else if (state.availableSlots.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'No open times on this date. Choose another day.',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.availableSlots.map((slot) {
                                final selected =
                                    state.selectedSlotId == slot.id;
                                return SizedBox(
                                    width: (MediaQuery.sizeOf(context).width -
                                            60) /
                                        3,
                                    child: OutlinedButton(
                                      onPressed: () => ref
                                          .read(studyLinkProvider.notifier)
                                          .selectTime(slot.time),
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
                                                : AppColors.border),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      child: Text(slot.time),
                                    ));
                              }).toList()),
                        const SizedBox(height: 19),
                        const Text('Where',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text)),
                        const SizedBox(height: 9),
                        Row(children: [
                          Expanded(
                              child: _ModeButton(
                                  label: 'On campus',
                                  selected: state.meetingMode == 'On campus',
                                  onTap: () => ref
                                      .read(studyLinkProvider.notifier)
                                      .selectMeetingMode('On campus'))),
                          const SizedBox(width: 9),
                          Expanded(
                              child: _ModeButton(
                                  label: 'Online',
                                  selected: state.meetingMode == 'Online',
                                  onTap: () => ref
                                      .read(studyLinkProvider.notifier)
                                      .selectMeetingMode('Online'))),
                        ]),
                        const SizedBox(height: 20),
                        const Text.rich(TextSpan(children: [
                          TextSpan(
                              text: 'What are you stuck on? ',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text)),
                          TextSpan(
                              text: '(only your tutor sees this)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ])),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: state.privateNote,
                          onChanged: ref
                              .read(studyLinkProvider.notifier)
                              .setPrivateNote,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              hintText:
                                  'e.g. I do not understand how recursion works in merge sort',
                              alignLabelWithHint: true),
                        ),
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(state.errorMessage!,
                              style: const TextStyle(
                                  color: AppColors.danger, fontSize: 12)),
                        ],
                      ]))),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border))),
            child: Column(children: [
              Text(
                  '${state.selectedDay} $month · ${state.selectedTime} · ${state.meetingMode == 'Online' ? 'online' : 'on campus'}',
                  style: AppTextStyles.caption),
              const SizedBox(height: 9),
              AppButton(
                label: 'Confirm booking',
                onPressed: state.isLoadingSlots || state.selectedSlotId.isEmpty
                    ? null
                    : () async {
                        try {
                          final ok = await ref
                              .read(studyLinkProvider.notifier)
                              .confirmBooking();
                          if (!context.mounted) return;
                          if (ok) {
                            context.push('/booking-confirmed');
                          } else {
                            final error =
                                ref.read(studyLinkProvider).errorMessage;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(error ??
                                      'That time is no longer available. Please choose another time.')),
                            );
                          }
                        } catch (error) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(error
                                    .toString()
                                    .replaceFirst('Exception: ', ''))),
                          );
                        }
                      },
              ),
            ]),
          ),
        ]),
      ))),
    );
  }

  String _month(int value) => const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][value - 1];

  String _weekday(DateTime value) => const [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][value.weekday - 1];
}

class _ModeButton extends StatelessWidget {
  const _ModeButton(
      {required this.label, required this.selected, required this.onTap});
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
            side: BorderSide(
                color: selected ? AppColors.green : AppColors.border),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          child: Text(label),
        ),
      );
}
