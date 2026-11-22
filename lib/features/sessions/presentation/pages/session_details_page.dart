import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_controller.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class SessionDetailsPage extends ConsumerStatefulWidget {
  const SessionDetailsPage({required this.sessionId, super.key});
  final String sessionId;

  @override
  ConsumerState<SessionDetailsPage> createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends ConsumerState<SessionDetailsPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final alreadyLoaded = ref.read(studyLinkProvider).sessions.any(
          (session) => session.id == widget.sessionId,
        );
    _loading = widget.sessionId.isNotEmpty && !alreadyLoaded;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = ref
          .read(studyLinkProvider)
          .sessions
          .where((item) => item.id == widget.sessionId);
      if (session.isEmpty && widget.sessionId.isNotEmpty) {
        setState(() => _loading = true);
        try {
          await ref
              .read(studyLinkProvider.notifier)
              .loadSessionById(widget.sessionId);
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(error.toString().replaceFirst('Exception: ', ''))),
            );
          }
        } finally {
          if (mounted) setState(() => _loading = false);
        }
      } else if (session.isNotEmpty) {
        ref.read(studyLinkProvider.notifier).selectSession(session.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyLinkProvider);
    final matchingSessions =
        state.sessions.where((item) => item.id == widget.sessionId).toList();
    StudySession? session =
        matchingSessions.isEmpty ? null : matchingSessions.first;
    if (session == null && widget.sessionId.isEmpty) {
      session = state.selectedSession;
    }

    if (_loading) {
      return const Scaffold(
          body: SafeArea(child: Center(child: LoadingIndicator())));
    }
    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
            child: Center(
                child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Session not found', style: AppTextStyles.pageTitle),
            const SizedBox(height: 12),
            AppButton(
                label: 'Back to my sessions',
                onPressed: () => context.go('/sessions')),
          ]),
        ))),
      );
    }

    final selectedSession = session;
    final date = selectedSession.startAt == null
        ? '${selectedSession.day} ${selectedSession.date}'
        : '${_weekday(selectedSession.startAt!)} ${selectedSession.startAt!.day} ${_month(selectedSession.startAt!.month)} ${selectedSession.startAt!.year}';
    final isConfirmed =
        selectedSession.status == 'confirmed' && selectedSession.isUpcoming;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(children: [
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
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                size: 20)),
                        const SizedBox(height: 13),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: isConfirmed
                                    ? AppColors.mint
                                    : AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(22)),
                            child: Text(selectedSession.status.toUpperCase(),
                                style: const TextStyle(
                                    color: AppColors.greenDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700))),
                        const SizedBox(height: 8),
                        Text(selectedSession.subject,
                            style: AppTextStyles.title.copyWith(fontSize: 24)),
                        const SizedBox(height: 17),
                        AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    InitialsAvatar(
                                        initials: selectedSession.initials,
                                        backgroundColor: AppColors.beigeAvatar,
                                        size: 46),
                                    const SizedBox(width: 11),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(selectedSession.tutorName,
                                              style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 3),
                                          const Text('Your peer tutor',
                                              style: AppTextStyles.caption),
                                        ])),
                                    if (selectedSession.tutorId.isNotEmpty)
                                      TextButton(
                                        onPressed: () async {
                                          try {
                                            await ref
                                                .read(
                                                    studyLinkProvider.notifier)
                                                .loadTutorProfile(
                                                    selectedSession.tutorId);
                                            if (context.mounted) {
                                              context.push('/tutor-profile');
                                            }
                                          } catch (error) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          error.toString())));
                                            }
                                          }
                                        },
                                        child: const Text('Profile',
                                            style: TextStyle(
                                                color: AppColors.green,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12)),
                                      ),
                                  ]),
                                  const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 13),
                                      child: Divider(
                                          height: 1, color: AppColors.border)),
                                  _SessionInfo(
                                      icon: Icons.calendar_today_outlined,
                                      title: date,
                                      subtitle:
                                          '${selectedSession.time} · 45-minute session'),
                                  const SizedBox(height: 13),
                                  _SessionInfo(
                                      icon: Icons.location_on_outlined,
                                      title: selectedSession.mode == 'Online'
                                          ? 'Online session'
                                          : selectedSession.location,
                                      subtitle: selectedSession.mode == 'Online'
                                          ? 'Online'
                                          : 'ALU Kigali campus'),
                                ])),
                        const SizedBox(height: 19),
                        const Text('YOUR NOTE TO THE TUTOR',
                            style: AppTextStyles.eyebrow),
                        const SizedBox(height: 8),
                        AppCard(
                            padding: const EdgeInsets.all(13),
                            child: Text(
                              selectedSession.note.isEmpty
                                  ? 'No private note was added for this selectedSession.'
                                  : selectedSession.note,
                              style: AppTextStyles.body,
                            )),
                      ]),
                ),
              ),
              if (isConfirmed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Column(children: [
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(13)),
                        child: const Text(
                            "After the session you'll be asked to rate it here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12))),
                    const SizedBox(height: 14),
                    SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () =>
                              _showCancelSheet(context, ref, selectedSession),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(
                                  color: AppColors.dangerBorder, width: 1.2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)),
                              textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                          child: const Text('Cancel session'),
                        )),
                  ]),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showCancelSheet(
      BuildContext context, WidgetRef ref, StudySession session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CancelSessionSheet(
        session: session,
        onCancel: () async {
          try {
            await ref
                .read(studyLinkProvider.notifier)
                .cancelSession(session.id);
            if (!sheetContext.mounted) return;
            Navigator.of(sheetContext).pop();
            if (context.mounted) context.go('/sessions');
          } catch (error) {
            if (sheetContext.mounted) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                    content:
                        Text(error.toString().replaceFirst('Exception: ', ''))),
              );
            }
          }
        },
        onPickAnotherTime: () async {
          if (session.tutorId.isNotEmpty) {
            try {
              await ref
                  .read(studyLinkProvider.notifier)
                  .loadTutorProfile(session.tutorId);
            } catch (_) {}
          }
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          if (context.mounted) context.push('/availability');
        },
      ),
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
        'December'
      ][value - 1];
  String _weekday(DateTime value) => const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][value.weekday - 1];
}

class _SessionInfo extends StatelessWidget {
  const _SessionInfo(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.green, size: 19),
        const SizedBox(width: 11),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.caption),
        ])),
      ]);
}

class _CancelSessionSheet extends ConsumerWidget {
  const _CancelSessionSheet(
      {required this.session,
      required this.onCancel,
      required this.onPickAnotherTime});
  final StudySession session;
  final VoidCallback onCancel;
  final VoidCallback onPickAnotherTime;
  static const reasons = [
    'I figured it out',
    'The time no longer works',
    'I found help elsewhere',
    'Something else'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyLinkProvider);
    return Container(
      padding: EdgeInsets.fromLTRB(
          18, 10, 18, 18 + MediaQuery.viewInsetsOf(context).bottom),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
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
                            borderRadius: BorderRadius.circular(8)))),
                const SizedBox(height: 16),
                Text('Cancel this session?',
                    style: AppTextStyles.pageTitle.copyWith(fontSize: 21)),
                const SizedBox(height: 8),
                Text(
                    '${session.day} ${session.date} · ${session.time} with ${session.tutorName}. The reserved slot will be released for other students.',
                    style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 17),
                const Text.rich(TextSpan(children: [
                  TextSpan(
                      text: 'Why are you cancelling? ',
                      style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  TextSpan(
                      text: '(optional)',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12))
                ])),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: reasons.map((reason) {
                      final selected = state.cancelReason == reason;
                      return ChoiceChip(
                        label: Text(reason,
                            style: TextStyle(
                                color: selected
                                    ? AppColors.greenDark
                                    : AppColors.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        selected: selected,
                        selectedColor: AppColors.mint,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                            color:
                                selected ? AppColors.green : AppColors.border),
                        onSelected: (_) => ref
                            .read(studyLinkProvider.notifier)
                            .setCancelReason(reason),
                      );
                    }).toList()),
                const SizedBox(height: 13),
                AppButton(
                    label: 'Yes, cancel session',
                    style: AppButtonStyle.danger,
                    onPressed: onCancel),
                const SizedBox(height: 8),
                AppButton(
                    label: 'Pick a new time instead',
                    style: AppButtonStyle.secondary,
                    onPressed: onPickAnotherTime),
                Center(
                    child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Keep my session',
                            style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)))),
              ]))),
    );
  }
}
