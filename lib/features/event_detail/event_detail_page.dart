import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/participation_type_extension.dart';
import 'package:linca_otaku_support/features/event_detail/view/custom_participation_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/context_extension.dart';
import '../../../core/utils/date_extension.dart';
import '../../core/asset_gen/assets.gen.dart';
import '../../core/models/linca_event.dart';
import '../../core/network/model/tag.dart';
import '../../core/network/providers.dart';
import '../../core/widgets/event/participation_status_badge.dart';

@RoutePage()
class EventDetailPage extends HookConsumerWidget {
  const EventDetailPage({
    super.key,
    required this.lincaEvent,
    this.participationInfo,
  });

  final LincaEvent lincaEvent;
  final ParticipationInfo? participationInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ParticipationController participationController =
        ref.read(participationControllerProvider.notifier);
    final ValueNotifier<ParticipationType> selectedParticipationType = useState(
        participationInfo?.participationType ?? ParticipationType.onSite);
    final TextEditingController participationMemoController =
        useTextEditingController(text: participationInfo?.participationMemo);

    useEffect(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

      return () {
        // 戻るときに元に戻す
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      };
    }, const <Object?>[]);

    List<Widget> generateDeleteButtonIfNeeded() {
      if (participationInfo == null) {
        return <Widget>[const SizedBox.shrink()];
      }

      return <Widget>[
        const SizedBox(
          height: 60,
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              participationController.deleteParticipation(
                lincaEvent,
                participationInfo!,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.snackbar_title_deleted),
                  ),
                );
                context.router.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              context.l10n.event_detail_delete,
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ];
    }

    List<Widget> buildBadgeAreaIfNeeded() {
      final List<Widget> widgets = <Widget>[];
      if (participationInfo == null) return widgets;

      if (lincaEvent.event.date?.isAfter(DateTime.now()) == true) {
        widgets.add(
          const ParticipationStatusBadge(
            text: '参加予定',
            color: Colors.green,
          ),
        );
        widgets.add(const SizedBox(width: 4));

      }

      widgets.add(
        ParticipationStatusBadge(
          text: participationInfo!.participationType!.label(context),
          color: participationInfo!.participationType!.badgeColor(context),
        ),
      );

      widgets.add(const SizedBox(height: 4));

      return <Widget>[
        Row(children: widgets),
        const SizedBox(height: 4),
      ];
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 250,
                toolbarHeight: 30,
                collapsedHeight: 30,
                backgroundColor: Colors.transparent,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image(
                    image: lincaEvent.event.imageUrl.isNotEmpty
                        ? NetworkImage(lincaEvent.event.imageUrl)
                        : AssetImage(Assets.images.defaultLiveBackground.path),
                    fit: BoxFit.cover,
                  ),
                  collapseMode: CollapseMode.parallax,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ...buildBadgeAreaIfNeeded(),
                      Text(
                        lincaEvent.group.name,
                        style: context.textTheme.titleMedium
                            ?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lincaEvent.event.title,
                        style: context.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lincaEvent.event.date?.simpleDateFormat() ?? '',
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              final Uri url = Uri.parse(context.l10n
                                  .map_launch_url(lincaEvent.venue.name));
                              launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            },
                            icon: const Icon(Icons.pin_drop),
                          ),
                          Expanded(
                            child: Text(
                              lincaEvent.venue.name,
                              style: context.textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          text: lincaEvent.event.url,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(Uri.parse(lincaEvent.event.url));
                            },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: context.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: CustomParticipationButton(
                                participationType: ParticipationType.onSite,
                                selectedParticipationType:
                                    selectedParticipationType.value,
                                iconData: Icons.place,
                                onClick: () => selectedParticipationType.value =
                                    ParticipationType.onSite,
                              ),
                            ),
                            Expanded(
                              child: CustomParticipationButton(
                                participationType:
                                    ParticipationType.liveViewing,
                                selectedParticipationType:
                                    selectedParticipationType.value,
                                iconData: Icons.directions_bus,
                                onClick: () => selectedParticipationType.value =
                                    ParticipationType.liveViewing,
                              ),
                            ),
                            Expanded(
                              child: CustomParticipationButton(
                                participationType: ParticipationType.streaming,
                                selectedParticipationType:
                                    selectedParticipationType.value,
                                iconData: Icons.bookmark,
                                onClick: () => selectedParticipationType.value =
                                    ParticipationType.streaming,
                              ),
                            ),
                            Expanded(
                              child: CustomParticipationButton(
                                participationType: ParticipationType.absent,
                                selectedParticipationType:
                                    selectedParticipationType.value,
                                iconData: Icons.notifications_off,
                                onClick: () => selectedParticipationType.value =
                                    ParticipationType.absent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 8,
                        children: <Widget>[
                          ...lincaEvent.tags.map((Tag tag) {
                            return Chip(
                              label: Text(
                                tag.name,
                                style: context.textTheme.labelMedium,
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: participationMemoController,
                        maxLines: null,
                        // 自動で高さが伸びる
                        keyboardType: TextInputType.multiline,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: context.l10n.event_detail_memo_hint,
                          hintStyle: TextStyle(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor:
                              context.colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none, // 枠線なし
                          ),
                        ),
                      ),
                      ...generateDeleteButtonIfNeeded(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            child: IconButton(
              onPressed: () => context.router.pop(),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 8,
            child: ElevatedButton(
              onPressed: () async {
                await participationController.createParticipation(
                  lincaEvent,
                  ParticipationInfo(
                    eventId: lincaEvent.event.id,
                    participationType: selectedParticipationType.value,
                    participationMemo: participationMemoController.text,
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.snackbar_title_saved),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colorScheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.archive_outlined,
                      color: context.colorScheme.surface),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.common_save,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
