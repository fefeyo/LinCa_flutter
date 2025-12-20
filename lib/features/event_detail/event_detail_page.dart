import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/network/model/user.dart';
import 'package:linca_otaku_support/core/router/app_router.gr.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_dialog.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_loading_dialog.dart';
import 'package:linca_otaku_support/core/widgets/common/event_status_badges.dart';
import 'package:linca_otaku_support/core/widgets/common/image_preview_dialog.dart';
import 'package:linca_otaku_support/features/create_event/data/create_event_type.dart';
import 'package:linca_otaku_support/features/event_detail/data/event_detail_state.dart';
import 'package:linca_otaku_support/features/event_detail/view/custom_participation_button.dart';
import 'package:linca_otaku_support/features/event_detail/view_model/event_detail_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/context_extension.dart';
import '../../../core/utils/date_extension.dart';
import '../../core/asset_gen/assets.gen.dart';
import '../../core/models/check_in_condition.dart';
import '../../core/models/linca_event.dart';
import '../../core/network/model/tag.dart';
import '../../core/network/providers.dart';

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
    final LincaUser? lincaUser = ref.watch(userControllerProvider).value;
    final UserController userController =
        ref.read(userControllerProvider.notifier);
    final bool isToday = lincaEvent.event.date?.isToday == true;
    final bool isAlreadyCheckedIn = lincaUser?.acquiredBadges.any(
            (LincaBadge badge) =>
                badge.id == lincaEvent.event.displayCheckInId) ??
        false;
    final bool isMyEvent = lincaEvent.event is UnOfficialEvent &&
        (lincaEvent.event as UnOfficialEvent).createdBy == lincaUser?.user.id;
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

    ref.listen<CheckInCondition?>(
      eventDetailViewModelProvider
          .select((EventDetailState state) => state.checkInCondition),
      (CheckInCondition? previous, CheckInCondition? next) async {
        final CheckInCondition? checkInCondition = next;
        if (checkInCondition != null) {
          final String? message;
          switch (checkInCondition) {
            case CheckInCondition.locationPermissionDisabled:
              message = context.l10n.check_in_location_permission_disabled;
              break;
            case CheckInCondition.locationPermissionDenied:
              message = context.l10n.check_in_location_permission_denied;
              break;
            case CheckInCondition.locationPermissionDeniedForever:
              message =
                  context.l10n.check_in_location_permission_denied_forever;
              break;
            case CheckInCondition.inRange:
              userController.acquireBadge(lincaEvent.event.displayCheckInId);
              message = context.l10n.check_in_in_range;
              break;
            case CheckInCondition.outRange:
              message = context.l10n.check_in_out_range;
              break;
          }
          await CommonSimpleDialog.show(context: context, title: message);
          viewModel.resetCheckInState();
        }
      },
    );

    ref.listen<bool>(
        eventDetailViewModelProvider
            .select((EventDetailState state) => state.isLoading),
        (bool? previous, bool next) {
      final bool isLoadingBefore = previous ?? false;
      final bool isLoadingNow = next;

      if (!isLoadingBefore && isLoadingNow) {
        // ローディング開始 → 表示
        CommonSimpleLoadingDialog.show(context: context);
      } else if (isLoadingBefore && !isLoadingNow) {
        // ローディング終了 → 閉じる
        Navigator.of(context, rootNavigator: true).pop();
      }
    });

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
                  background: lincaEvent.event.displayImageUrl.isNotEmpty
                      ? GestureDetector(
                          onTap: () => ImagePreviewDialog.show(
                            context: context,
                            imageUrl: lincaEvent.event.displayImageUrl,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: lincaEvent.event.displayImageUrl,
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      : Image.asset(
                          Assets.images.defaultLiveBackground.path,
                          fit: BoxFit.cover,
                        ),
                  collapseMode: CollapseMode.parallax,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      EventStatusBadges(
                        lincaEvent: lincaEvent,
                        participationInfo: participationInfo,
                      ),
                      const SizedBox(height: 4),
                      ..._buildOrganizerArea(
                        context: context,
                        user: state.organizerUser,
                      ),
                      Text(
                        lincaEvent.event.title,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lincaEvent.event.date?.simpleDateFormat() ?? '',
                        style: context.textTheme.titleMedium,
                      ),
                      _buildVenueAreaIfNeeded(context),
                      if (isToday && lincaEvent.event is OfficialEvent)
                        ..._buildCheckInButtonIfNeeded(
                            context: context,
                            onClick: () => viewModel.checkLocation(lincaEvent),
                            isAlreadyCheckedIn: isAlreadyCheckedIn),
                      ..._buildUrlAreaIfNeeded(context: context),
                      ..._buildDescriptionAreaIfNeeded(context: context),
                      ..._buildEventCodeAreaIfNeeded(context: context),
                      ..._buildButtonArea(
                        context: context,
                        selectedParticipationType:
                            selectedParticipationType.value,
                        availableParticipationTypes:
                            lincaEvent.event.availableParticipationTypes,
                        onClickButton: (ParticipationType participationType) {
                          selectedParticipationType.value = participationType;
                        },
                      ),
                      ..._buildEventMemoArea(
                        context: context,
                        participationMemoController:
                            participationMemoController,
                      ),
                      ..._buildTagsArea(context),
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
              style: IconButton.styleFrom(
                backgroundColor: Colors.black26,
                shape: const CircleBorder(),
                fixedSize: const Size(48, 48),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isMyEvent || participationInfo != null)
            Positioned(
              top: 16,
              right: 16,
              child: PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  if (isMyEvent)
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.edit),
                          const SizedBox(width: 8),
                          Text(
                            '編集',
                            style: context.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  if (participationInfo != null && !isMyEvent)
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            '削除',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                onSelected: (String value) {
                  if (value == 'edit') {
                    final UnOfficialEvent event =
                        lincaEvent.event as UnOfficialEvent;
                    context.router.pop();
                    context.router.push(
                      CreateEventRoute(
                        createEventType: event.visibility
                            ? CreateEventType.public
                            : CreateEventType.private,
                        isEditMode: true,
                        unOfficialEvent: event,
                      ),
                    );
                  }
                  if (value == 'delete') {
                    participationController.deleteParticipation(
                      lincaEvent,
                      participationInfo!,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.snackbar_title_deleted),
                          backgroundColor: Colors.red,
                        ),
                      );
                      context.router.pop();
                    }
                  }
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await participationController.createParticipation(
            lincaEvent: lincaEvent,
            participation: ParticipationInfo(
              eventId: lincaEvent.event.id,
              participationType: selectedParticipationType.value,
              participationMemo: participationMemoController.text,
              groupSlug: lincaEvent.organizerName,
            ),
            needsRefresh: true,
          );
          if (context.mounted) {
            context.router.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.snackbar_title_saved),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('保存'),
      ),
    );
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
          style: context.textTheme.titleSmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 2),
      ];
    } else {
      return <Widget>[];
    }
  }

  Widget _buildVenueAreaIfNeeded(BuildContext context) {
    return lincaEvent.venueName.isNotEmpty
        ? InkWell(
            onTap: () {
              final Uri url =
                  Uri.parse(context.l10n.map_launch_url(lincaEvent.venueName));
              launchUrl(url, mode: LaunchMode.externalApplication);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.pin_drop),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(
                      lincaEvent.venueName,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  List<Widget> _buildCheckInButtonIfNeeded({
    required BuildContext context,
    required VoidCallback onClick,
    required bool isAlreadyCheckedIn,
  }) {
    return <Widget>[
      ElevatedButton.icon(
        onPressed: () => isAlreadyCheckedIn ? null : onClick(),
        icon: const Icon(Icons.location_on),
        label: Text(
          '会場チェックイン',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.surface,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isAlreadyCheckedIn ? Colors.grey : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          fixedSize: const Size(double.infinity, 30),
        ),
      ),
      const SizedBox(height: 8),
    ];
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

  List<Widget> _buildButtonArea({
    required BuildContext context,
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
            iconData: Icons.connected_tv,
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
            iconData: Icons.ondemand_video,
            onClick: () => onClickButton(ParticipationType.streaming),
          ),
        ),
      );
    }
    buttons.add(
      Expanded(
        child: CustomParticipationButton(
          participationType: ParticipationType.absent,
          selectedParticipationType: selectedParticipationType,
          iconData: Icons.cancel,
          onClick: () => onClickButton(ParticipationType.absent),
        ),
      ),
    );

    return <Widget>[
      Container(
        decoration: BoxDecoration(
          color: context.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(children: buttons),
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildEventMemoArea({
    required BuildContext context,
    required TextEditingController participationMemoController,
  }) =>
      <Widget>[
        TextField(
          controller: participationMemoController,
          // 自動で高さが伸びる
          maxLines: null,
          maxLength: AppConstants.eventMemoMaxLength,
          keyboardType: TextInputType.multiline,
          style: Theme.of(context).textTheme.bodyLarge,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: context.l10n.event_detail_memo_hint,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: context.colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ];

  List<Widget> _buildDescriptionAreaIfNeeded({
    required BuildContext context,
  }) {
    if (lincaEvent.event is OfficialEvent) return <Widget>[];
    final UnOfficialEvent userEvent = lincaEvent.event as UnOfficialEvent;

    return <Widget>[
      Text(
        context.l10n.text_unofficial_event_description,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        userEvent.desrcription,
        style: context.textTheme.titleSmall,
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildEventCodeAreaIfNeeded({
    required BuildContext context,
  }) {
    if (lincaEvent.event is OfficialEvent ||
        lincaEvent.event is UnOfficialEvent && !lincaEvent.event.visibility) {
      return <Widget>[];
    }
    final UnOfficialEvent userEvent = lincaEvent.event as UnOfficialEvent;

    return <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Text(
              context.l10n.event_detail_text_event_code(userEvent.id),
              style: context.textTheme.titleMedium,
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

  List<Widget> _buildTagsArea(BuildContext context) {
    return <Widget>[
      Wrap(
        spacing: 4,
        children: <Widget>[
          ...lincaEvent.tags.map(
            (Tag tag) {
              return Chip(
                label: Text(
                  tag.name,
                  style: context.textTheme.labelMedium,
                ),
              );
            },
          ),
        ],
      ),
      const SizedBox(height: 8),
    ];
  }
}
