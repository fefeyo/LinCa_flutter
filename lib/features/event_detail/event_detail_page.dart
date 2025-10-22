import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/model/user.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/participation_type_extension.dart';
import 'package:linca_otaku_support/features/event_detail/data/event_detail_state.dart';
import 'package:linca_otaku_support/features/event_detail/view/custom_participation_button.dart';
import 'package:linca_otaku_support/features/event_detail/view_model/event_detail_view_model.dart';
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
    final EventDetailState state = ref.read(eventDetailViewModelProvider);
    final EventDetailViewModel viewModel =
        ref.read(eventDetailViewModelProvider.notifier);
    final ParticipationController participationController =
        ref.read(participationControllerProvider.notifier);
    final ValueNotifier<ParticipationType> selectedParticipationType = useState(
        participationInfo?.participationType ?? ParticipationType.onSite);
    final TextEditingController participationMemoController =
        useTextEditingController(text: participationInfo?.participationMemo);
    final UserController userController =
        ref.read(userControllerProvider.notifier);

    useEffect(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      if (lincaEvent.event is UnOfficialEvent) {
        final UnOfficialEvent event = lincaEvent.event as UnOfficialEvent;
        Future<void>.microtask(() async {
          if (event.createdBy.isNotEmpty) {
            final User organizerUser =
                await userController.fetchUserData(userId: event.createdBy);
            viewModel.updateOrganizerUser(organizerUser);
          }
        });
      }

      return () {
        // 戻るときに元に戻す
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      };
    }, const <Object?>[]);

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
                    image: lincaEvent.event.imageUrlIfOfficial.isNotEmpty
                        ? CachedNetworkImageProvider(
                            lincaEvent.event.imageUrlIfOfficial)
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
                      ..._buildBadgeAreaIfNeeded(context: context),
                      ..._buildOrganizerArea(
                          context: context, user: state.organizerUser),
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
                                  .map_launch_url(lincaEvent.venueName));
                              launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            },
                            icon: const Icon(Icons.pin_drop),
                          ),
                          Expanded(
                            child: Text(
                              lincaEvent.venueName,
                              style: context.textTheme.headlineSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._buildUrlAreaIfNeeded(context: context),
                      ..._buildDescriptionAreaIfNeeded(context: context),
                      ..._buildEventCodeAreaIfNeeded(context: context),
                      Container(
                        decoration: BoxDecoration(
                          color: context.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: _buildButtonArea(
                          selectedParticipationType:
                              selectedParticipationType.value,
                          availableParticipationTypes:
                              lincaEvent.event.availableParticipationTypes,
                          onClickButton: (ParticipationType participationType) {
                            selectedParticipationType.value = participationType;
                          },
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
                      ..._generateDeleteButtonIfNeeded(
                        context: context,
                        onClickDelete: () {
                          participationController.deleteParticipation(
                            lincaEvent,
                            participationInfo!,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(context.l10n.snackbar_title_deleted),
                              ),
                            );
                            context.router.pop();
                          }
                        },
                      ),
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
                  lincaEvent: lincaEvent,
                  participation: ParticipationInfo(
                    eventId: lincaEvent.event.id,
                    participationType: selectedParticipationType.value,
                    participationMemo: participationMemoController.text,
                    groupSlug: lincaEvent.organizerName,
                  ),
                );
                if (context.mounted) {
                  context.router.pop();
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

  List<Widget> _buildBadgeAreaIfNeeded({
    required BuildContext context,
  }) {
    final List<Widget> widgets = <Widget>[];
    if (participationInfo == null) return widgets;

    if (lincaEvent.event.date?.isAfter(DateTime.now()) == true) {
      widgets.add(
        ParticipationStatusBadge(
          text: context.l10n.participation_planned,
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

  List<Widget> _buildOrganizerArea({
    required BuildContext context,
    required User? user,
  }) {
    final String organizerName;
    switch (lincaEvent.event) {
      case OfficialEvent():
        {
          organizerName = lincaEvent.group.name;
          break;
        }
      case UnOfficialEvent():
        {
          if (user == null) return <Widget>[];
          organizerName =
              context.l10n.text_unofficial_event_organizer(user.displayName);
          break;
        }
    }

    if (context.mounted) {
      return <Widget>[
        Text(
          organizerName,
          style: context.textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
      ];
    } else {
      return <Widget>[];
    }
  }

  List<Widget> _buildUrlAreaIfNeeded({
    required BuildContext context,
  }) {
    if (lincaEvent.event.url.isEmpty) return <Widget>[];

    return <Widget>[
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
    ];
  }

  Widget _buildButtonArea({
    required ParticipationType selectedParticipationType,
    required List<ParticipationType> availableParticipationTypes,
    required Function(ParticipationType participationType) onClickButton,
  }) {
    final List<Widget> buttons = <Widget>[];
    if (availableParticipationTypes.contains(ParticipationType.onSite)) {
      buttons.add(
        Expanded(
          child: CustomParticipationButton(
            participationType: ParticipationType.onSite,
            selectedParticipationType: selectedParticipationType,
            iconData: Icons.place,
            onClick: () => onClickButton(ParticipationType.onSite),
          ),
        ),
      );
    }
    if (availableParticipationTypes.contains(ParticipationType.liveViewing)) {
      buttons.add(
        Expanded(
          child: CustomParticipationButton(
            participationType: ParticipationType.liveViewing,
            selectedParticipationType: selectedParticipationType,
            iconData: Icons.directions_bus,
            onClick: () => onClickButton(ParticipationType.liveViewing),
          ),
        ),
      );
    }
    if (availableParticipationTypes.contains(ParticipationType.streaming)) {
      buttons.add(
        Expanded(
          child: CustomParticipationButton(
            participationType: ParticipationType.streaming,
            selectedParticipationType: selectedParticipationType,
            iconData: Icons.bookmark,
            onClick: () => onClickButton(ParticipationType.streaming),
          ),
        ),
      );
    }
    if (availableParticipationTypes.contains(ParticipationType.absent)) {
      buttons.add(
        Expanded(
          child: CustomParticipationButton(
            participationType: ParticipationType.absent,
            selectedParticipationType: selectedParticipationType,
            iconData: Icons.notifications_off,
            onClick: () => onClickButton(ParticipationType.absent),
          ),
        ),
      );
    }

    return Row(children: buttons);
  }

  List<Widget> _generateDeleteButtonIfNeeded({
    required BuildContext context,
    required Function() onClickDelete,
  }) {
    if (participationInfo == null) {
      return <Widget>[const SizedBox.shrink()];
    }

    return <Widget>[
      const SizedBox(
        height: 60,
      ),
      Center(
        child: ElevatedButton(
          onPressed: onClickDelete,
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

  List<Widget> _buildDescriptionAreaIfNeeded({
    required BuildContext context,
  }) {
    if (lincaEvent.event is OfficialEvent) return <Widget>[];
    final UnOfficialEvent userEvent = lincaEvent.event as UnOfficialEvent;

    return <Widget>[
      Text(
        context.l10n.text_unofficial_event_description,
        style: context.textTheme.headlineSmall,
      ),
      const SizedBox(height: 4),
      Text(
        userEvent.desrcription,
        style: context.textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildEventCodeAreaIfNeeded({
    required BuildContext context,
  }) {
    if (lincaEvent.event is OfficialEvent) return <Widget>[];
    final UnOfficialEvent userEvent = lincaEvent.event as UnOfficialEvent;

    return <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Text(
              context.l10n.event_detail_text_event_code(userEvent.id),
              style: context.textTheme.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: context.l10n.event_detail_text_event_code_copy,
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: userEvent.id));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(context.l10n.event_detail_text_event_code_copied),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                    backgroundColor: context.colorScheme.secondaryContainer,
                  ),
                );
              }
            },
          ),
        ],
      ),
      const SizedBox(height: 8),
    ];
  }
}
