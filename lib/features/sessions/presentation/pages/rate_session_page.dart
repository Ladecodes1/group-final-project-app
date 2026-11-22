import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/state/study_link_controller.dart';
import '../../../../core/models/study_link_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class RateSessionPage extends ConsumerStatefulWidget {
  const RateSessionPage({required this.sessionId, super.key});
  final String sessionId;

  static const feedbackOptions = [
    'Clear explanations',
    'Patient',
    'On time',
    'Well prepared',
    'Easy to ask questions'
  ];

  @override
  ConsumerState<RateSessionPage> createState() => _RateSessionPageState();
}

class _RateSessionPageState extends ConsumerState<RateSessionPage> {
  bool _loading = false;
  bool _submitting = false;

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
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.toString())));
          }
        } finally {
          if (mounted) setState(() => _loading = false);
        }
      } else if (session.isNotEmpty) {
        ref.read(studyLinkProvider.notifier).selectSession(session.first);
      }
    });
  }

  Future<void> _submit(StudySession session) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(studyLinkProvider.notifier).submitRating(session.id);
      if (mounted) context.go('/sessions');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                child: AppButton(
                    label: 'Back to my sessions',
                    onPressed: () => context.go('/sessions')))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Center(
              child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () => context.pop(),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            icon: const Icon(Icons.close_rounded, size: 21)),
                        const SizedBox(height: 18),
                        Center(
                            child: InitialsAvatar(
                                initials: session.initials,
                                backgroundColor: AppColors.mintDark,
                                size: 60)),
                        const SizedBox(height: 9),
                        Text(
                            'How was your session with ${session.tutorName.split(' ').first}?',
                            textAlign: TextAlign.center,
                            style:
                                AppTextStyles.pageTitle.copyWith(fontSize: 22)),
                        const SizedBox(height: 8),
                        Center(
                            child: Text(
                                '${session.subject} · ${session.day} ${session.date} · ${session.mode}',
                                style: AppTextStyles.caption
                                    .copyWith(fontSize: 12))),
                        const SizedBox(height: 22),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final selected = index < state.rating;
                              return IconButton(
                                onPressed: _submitting
                                    ? null
                                    : () => ref
                                        .read(studyLinkProvider.notifier)
                                        .setRating(index + 1),
                                visualDensity: VisualDensity.compact,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                constraints: const BoxConstraints(
                                    minWidth: 42, minHeight: 48),
                                icon: Icon(
                                    selected
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 34,
                                    color: selected
                                        ? AppColors.star
                                        : const Color(0xFF9AA19C)),
                              );
                            })),
                        Center(
                            child: Text(
                                state.rating >= 4
                                    ? 'Helpful'
                                    : state.rating == 3
                                        ? 'Good'
                                        : 'Could be better',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600))),
                        const SizedBox(height: 21),
                        const Text('Did you get unstuck?',
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Row(
                            children: ['Yes', 'Partly', 'No'].map((answer) {
                          final selected = state.unstuckAnswer == answer;
                          return Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.only(right: 7),
                                  child: SizedBox(
                                      height: 43,
                                      child: OutlinedButton(
                                        onPressed: _submitting
                                            ? null
                                            : () => ref
                                                .read(
                                                    studyLinkProvider.notifier)
                                                .setUnstuckAnswer(answer),
                                        style: OutlinedButton.styleFrom(
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
                                                  BorderRadius.circular(11)),
                                          textStyle: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13),
                                        ),
                                        child: Text(answer),
                                      ))));
                        }).toList()),
                        const SizedBox(height: 20),
                        const Text('What went well?',
                            style: TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children:
                                RateSessionPage.feedbackOptions.map((value) {
                              final selected =
                                  state.feedbackTags.contains(value);
                              return FilterChip(
                                label: Text(value,
                                    style: TextStyle(
                                        color: selected
                                            ? AppColors.greenDark
                                            : AppColors.text,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                selected: selected,
                                onSelected: _submitting
                                    ? null
                                    : (_) => ref
                                        .read(studyLinkProvider.notifier)
                                        .toggleFeedbackTag(value),
                                selectedColor: AppColors.mint,
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: selected
                                        ? AppColors.green
                                        : AppColors.border),
                                showCheckmark: false,
                              );
                            }).toList()),
                        const SizedBox(height: 18),
                        const Text.rich(TextSpan(children: [
                          TextSpan(
                              text: 'Anything else? ',
                              style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          TextSpan(
                              text: '(optional)',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ])),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: ValueKey('feedback-${session.id}'),
                          initialValue: state.extraFeedback,
                          onChanged: ref
                              .read(studyLinkProvider.notifier)
                              .setExtraFeedback,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              hintText: 'A short note for your tutor',
                              alignLabelWithHint: true),
                        ),
                      ]))),
          Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: AppButton(
                label: _submitting ? 'Submitting…' : 'Submit rating',
                onPressed: _submitting || session.isRated
                    ? null
                    : () => _submit(session!),
              )),
        ]),
      ))),
    );
  }
}
