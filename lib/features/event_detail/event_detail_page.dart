import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tutorial_overlay/flutter_tutorial_overlay.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/analytics_event.dart';
import 'package:linca_otaku_support/core/constants/analytics_screen.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/constants/participation_type.dart';
import 'package:linca_otaku_support/core/models/linca_user.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/controller/user_controller.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/linca_badge.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/router/app_router.gr.dart';
import 'package:linca_otaku_support/core/utils/coach_manager.dart';
import 'package:linca_otaku_support/core/utils/event_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import 'package:linca_otaku_support/core/utils/linca_event_extension.dart';
import 'package:linca_otaku_support/core/utils/screen_analytics_manager.dart';
import 'package:linca_otaku_support/core/utils/tag_extension.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_dialog.dart';
import 'package:linca_otaku_support/core/widgets/common/common_simple_loading_dialog.dart';
import 'package:linca_otaku_support/core/widgets/common/event_status_badges.dart';
import 'package:linca_otaku_support/core/widgets/dialog/image_preview_dialog.dart';
import 'package:linca_otaku_support/features/create_event/data/create_event_type.dart';
import 'package:linca_otaku_support/features/event_detail/data/event_detail_state.dart';
import 'package:linca_otaku_support/features/event_detail/view/custom_participation_button.dart';
import 'package:linca_otaku_support/features/event_detail/view_model/event_detail_view_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/context_extension.dart';
import '../../../core/utils/date_extension.dart';
import '../../core/asset_gen/assets.gen.dart';
import '../../core/models/check_in_condition.dart';
import '../../core/models/event_memory.dart';
import '../../core/models/linca_event.dart';
import '../../core/network/model/tag.dart';
import '../../core/network/providers.dart';
import '../../core/utils/image_uploader.dart';
import '../../core/utils/preferences_service.dart';
import '../../core/utils/providers.dart';

@RoutePage()
class EventDetailPage extends HookConsumerWidget
    with CoachManager, ScreenAnalyticsManager, EventAnalyticsManager {
  const EventDetailPage({
    super.key,
    required this.lincaEvent,
    this.participationInfo,
  });

  final LincaEvent lincaEvent;
  final ParticipationInfo? participationInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.eventDetail);

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
    final bool isCheckInAvailable =
        lincaEvent.event.displayCheckInId.isNotEmpty;
    final bool isAlreadyCheckedIn = lincaUser?.acquiredBadges.any(
            (LincaBadge badge) =>
                badge.id == lincaEvent.event.displayCheckInId) ??
        false;
    final bool isMyEvent = lincaEvent.event is UnOfficialEvent &&
        (lincaEvent.event as UnOfficialEvent).createdBy == lincaUser?.user.id;
    final GlobalKey<State<StatefulWidget>> participationAreaKey =
        useMemoized(() => GlobalKey());
    final GlobalKey<State<StatefulWidget>> saveButtonKey =
        useMemoized(() => GlobalKey());
    final ValueNotifier<List<EventMemory>> eventMemories =
        useState(participationInfo?.eventMemories ?? <EventMemory>[]);

    final List<TutorialStep> steps = <TutorialStep>[
      TutorialStep(
        targetKey: participationAreaKey,
        title: context.l10n.coach_step5_title,
        description: context.l10n.coach_step5_description,
        tag: 'participation_area',
        onStepNext: (String _) =>
            logEvent(event: AnalyticsEvent.coachNextClick),
      ),
      TutorialStep(
        targetKey: saveButtonKey,
        title: context.l10n.coach_step6_title,
        description: context.l10n.coach_step6_description,
        tag: 'save_button',
        onStepNext: (String _) =>
            logEvent(event: AnalyticsEvent.coachCompleteClick),
      ),
    ];

    useEffect(() {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      Future<void>.microtask(() async {
        if (!context.mounted) return;
        final PreferencesService preferences =
            ref.read(preferencesServiceProvider);
        showIfNeeded(
          context: context,
          preferences: preferences,
          steps: steps,
          isCompletable: true,
          onComplete: () => preferences.markTutorialAsSeen(),
          onSkip: () => logEvent(event: AnalyticsEvent.coachSkipClick),
        );
      });

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
          String? title;
          final String message;
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
              title = context.l10n.check_in_in_range_title;
              message = context.l10n.check_in_in_range_description;
              break;
            case CheckInCondition.outRange:
              message = context.l10n.check_in_out_range;
              break;
          }
          if (title != null) {
            await CommonSimpleDialog.show(
                context: context, title: title, content: message);
          } else {
            await CommonSimpleDialog.show(context: context, title: message);
          }
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
                        organizerName: lincaEvent.organizerName,
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
                      if (isToday &&
                          lincaEvent.event is OfficialEvent &&
                          isCheckInAvailable)
                        ..._buildCheckInButtonIfNeeded(
                            context: context,
                            onClick: () => viewModel.checkLocation(lincaEvent),
                            isAlreadyCheckedIn: isAlreadyCheckedIn),
                      ..._buildUrlAreaIfNeeded(context: context),
                      ..._buildDescriptionAreaIfNeeded(context: context),
                      ..._buildEventCodeAreaIfNeeded(context: context),
                      ..._buildParticipationToggleArea(
                        context: context,
                        selectedParticipationType:
                            selectedParticipationType.value,
                        availableParticipationTypes:
                            lincaEvent.event.availableParticipationTypes,
                        participationAreaKey: participationAreaKey,
                        onClickButton: (ParticipationType participationType) {
                          selectedParticipationType.value = participationType;
                        },
                      ),
                      if (participationInfo != null)
                        ..._buildEventMemoryArea(
                          context: context,
                          uid: lincaUser?.user.id,
                          eventMemories: eventMemories.value,
                          addEventMemory: (EventMemory eventMemory) async {
                            final List<EventMemory> resultMemories =
                                await participationController
                                    .updateParticipationMemory(
                              targetParticipationInfo: participationInfo,
                              eventMemory: eventMemory,
                            );
                            eventMemories.value = resultMemories;
                          },
                          editEventMemory: (EventMemory eventMemory) async {
                            final String? uid = lincaUser?.user.id;
                            if (uid == null) return;
                            final String? targetPhotoUrl =
                                await pickCompressAndUploadImage(
                              uid: uid,
                              uploadPath: eventMemory.path,
                              imageQuality: ImageQuality.memory,
                            );
                            if (targetPhotoUrl == null) return;
                            final List<EventMemory> resultMemories =
                                await participationController
                                    .updateParticipationMemory(
                              targetParticipationInfo: participationInfo,
                              eventMemory: EventMemory(
                                url: targetPhotoUrl,
                                path: eventMemory.path,
                              ),
                              isEdit: true,
                            );
                            eventMemories.value = resultMemories;
                          },
                          deleteEventMemory: (EventMemory eventMemory) async {
                            final String? uid = lincaUser?.user.id;
                            if (uid == null) return;
                            final List<EventMemory> resultMemories =
                                await participationController
                                    .deleteParticipationMemory(
                              targetParticipationInfo: participationInfo,
                              eventMemory: eventMemory,
                            );
                            eventMemories.value = resultMemories;
                            if (!context.mounted) return;
                            context.showSuccessSnackBar(
                                message:
                                    context.l10n.event_detail_memory_deleted);
                          },
                        ),
                      ..._buildEventMemoArea(
                        context: context,
                        participationMemoController:
                            participationMemoController,
                      ),
                      ..._buildTagsArea(context),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
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
          ),
          if (isMyEvent || participationInfo != null)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
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
                              context.l10n.common_edit,
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
                              context.l10n.common_delete,
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
                      logEvent(event: AnalyticsEvent.eventDetailEditClick);

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
                      if (participationInfo == null) return;
                      logEvent(event: AnalyticsEvent.eventDetailCloseClick);

                      CommonSimpleDialog.show(
                        context: context,
                        title: context.l10n.my_event_delete_dialog_title,
                        content:
                            context.l10n.my_event_delete_dialog_description,
                        onClickOk: () {
                          participationController
                              .deleteParticipation(participationInfo!);
                          if (!context.mounted) return;
                          context.showSuccessSnackBar(
                            message: context.l10n.my_event_deleted,
                            effect: () => context.router.pop(),
                          );
                        },
                        onClickCancel: () {},
                      );
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
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: saveButtonKey,
        onPressed: () async {
          logEvent(
            event: AnalyticsEvent.eventDetailSaveClick,
            params: <String, Object>{
              'eventId': lincaEvent.event.id,
              'participationType': selectedParticipationType.value,
              'participationMemo': participationMemoController.text,
              'groupSlug': lincaEvent.organizer,
            },
          );

          await participationController.createParticipation(
            lincaEvent: lincaEvent,
            participation: ParticipationInfo(
              eventId: lincaEvent.event.id,
              participationType: selectedParticipationType.value,
              participationMemo: participationMemoController.text,
              groupSlug: lincaEvent.organizer,
            ),
          );
          if (!context.mounted) return;
          context.router.pop();
          context.showSuccessSnackBar(
            message: context.l10n.common_save_suceeded,
            effect: () => context.router.pop(),
          );
        },
        icon: const Icon(Icons.save),
        label: Text(
          context.l10n.common_save,
          style: context.textTheme.labelMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOrganizerArea({
    required BuildContext context,
    required String organizerName,
  }) {
    switch (lincaEvent.event) {
      case OfficialEvent():
        {
          organizerName = lincaEvent.group.name;
          break;
        }
      case UnOfficialEvent():
        {
          if (organizerName.isEmpty) return <Widget>[];
          organizerName =
              context.l10n.text_unofficial_event_organizer(organizerName);
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
          context.l10n.check_in,
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

  List<Widget> _buildParticipationToggleArea({
    required BuildContext context,
    required ParticipationType selectedParticipationType,
    required List<ParticipationType> availableParticipationTypes,
    required GlobalKey participationAreaKey,
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
        key: participationAreaKey,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(children: buttons),
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildEventMemoryArea({
    required BuildContext context,
    required String? uid,
    required List<EventMemory> eventMemories,
    required Function(EventMemory eventMemory) addEventMemory,
    required Function(EventMemory eventMemory) editEventMemory,
    required Function(EventMemory eventMemory) deleteEventMemory,
  }) {
    return <Widget>[
      Text(
        context.l10n.event_detail_memory_title,
        style: context.textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double spacing = 8;
          final double itemWidth = (constraints.maxWidth - spacing * 2) / 3;

          return SizedBox(
            height: itemWidth,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (final EventMemory eventMemory in eventMemories)
                  Padding(
                    padding: const EdgeInsets.only(right: spacing),
                    child: SizedBox(
                      width: itemWidth,
                      height: itemWidth,
                      child: GestureDetector(
                        onTap: () => ImagePreviewDialog.showEditable(
                          context: context,
                          imageUrl: eventMemory.url,
                          onEdit: () => editEventMemory(eventMemory),
                          onDelete: () => deleteEventMemory(eventMemory),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: eventMemory.url,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                if (eventMemories.length < 3 && uid != null)
                  SizedBox(
                    width: itemWidth,
                    height: itemWidth,
                    child: buildAddImageButton(
                      context: context,
                      uid: uid,
                      updateUserPhoto: addEventMemory,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget buildAddImageButton({
    required BuildContext context,
    required String uid,
    required Function(EventMemory eventMemory) updateUserPhoto,
  }) {
    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        final String uuid = const Uuid().v4();
        final String path = 'participations/$uid/$uuid.jpg';
        final String? photoUrl = await pickCompressAndUploadImage(
          uid: uid,
          uploadPath: path,
          imageQuality: ImageQuality.memory,
        );
        if (context.mounted) context.router.pop();
        if (photoUrl == null) return;
        updateUserPhoto(EventMemory(url: photoUrl, path: path));
      },
      child: Container(
        width: 96,
        height: 96,
        color: context.colorScheme.surfaceContainerLow,
        child: Icon(
          Icons.add_a_photo,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
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
              if (!context.mounted) return;
              context.showSuccessSnackBar(
                message: context.l10n.event_detail_text_event_code_copied,
                duration: const Duration(milliseconds: 1000),
              );
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
          ...lincaEvent.tags.displayTags.map(
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
