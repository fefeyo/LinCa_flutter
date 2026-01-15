import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/tag_extension.dart';
import 'package:linca_otaku_support/core/widgets/event/participation_status_badge.dart';

import '../../../core/utils/context_extension.dart';
import '../../core/constants/analytics_event.dart';
import '../../core/constants/analytics_screen.dart';
import '../../core/constants/event_type.dart';
import '../../core/constants/participation_type.dart';
import '../../core/models/filter_settings.dart';
import '../../core/network/model/tag.dart';
import '../../core/network/providers.dart';
import '../../core/utils/event_analytics_manager.dart';
import '../../core/utils/screen_analytics_manager.dart';
import '../../core/utils/sort_items_extension.dart';

@RoutePage()
class EventSortFilterPage extends HookConsumerWidget
    with ScreenAnalyticsManager, EventAnalyticsManager {
  const EventSortFilterPage({
    super.key,
    required this.initialSettings,
    this.needInputArea = false,
    this.needHiddenParticipationArea = false,
    this.needHiddenOriginalEventArea = false,
    this.needDisplayOrderArea = false,
    this.needParticipationArea = false,
    this.needEventTypeArea = false,
    this.needTagsArea = false,
  });

  final FilterSettings initialSettings;
  final bool needInputArea;
  final bool needHiddenParticipationArea;
  final bool needHiddenOriginalEventArea;
  final bool needDisplayOrderArea;
  final bool needParticipationArea;
  final bool needEventTypeArea;
  final bool needTagsArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logScreen(AnalyticsScreen.eventSortBottomSheet);

    final TextEditingController keywordController =
        useTextEditingController(text: initialSettings.keyword);
    final ValueNotifier<DisplayOrder> currentDisplayOrder =
        useState(initialSettings.displayOrder);
    final ValueNotifier<List<ParticipationType>> currentParticipationTypes =
        useState(initialSettings.participationFilters);
    final ValueNotifier<bool> isShowOfficialEvent =
        useState(initialSettings.isShowOfficialEvent);
    final ValueNotifier<bool> isShowOriginalEvent =
        useState(initialSettings.isShowOriginalEvent);
    final ValueNotifier<List<Tag>> currentTypeTags =
        useState(initialSettings.typeTags);
    final ValueNotifier<List<Tag>> currentSeriesTags =
        useState(initialSettings.seriesTags);
    final List<Tag> tags = ref.watch(tagControllerProvider).value ?? <Tag>[];
    final ValueNotifier<bool> isHiddenParticipationEvent =
        useState(initialSettings.isHiddenParticipationEvent);
    final ValueNotifier<bool> isHiddenOriginalEvent =
        useState(initialSettings.isHiddenOriginalEvent);
    final ValueNotifier<DateTime?> startDate =
        useState(initialSettings.startDate);
    final ValueNotifier<DateTime?> endDate = useState(initialSettings.endDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.router.pop(),
        ),
        title: Text(
          context.l10n.event_sort_title,
          style: context.textTheme.titleMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              logEvent(event: AnalyticsEvent.filterResetClick);

              currentDisplayOrder.value = DisplayOrder.newest;
              currentParticipationTypes.value = <ParticipationType>[];

              isShowOfficialEvent.value = false;
              isShowOriginalEvent.value = false;

              currentTypeTags.value = <Tag>[];
              currentSeriesTags.value = <Tag>[];

              isHiddenParticipationEvent.value = false;
              isHiddenOriginalEvent.value = false;

              startDate.value = null;
              endDate.value = null;
            },
            child: Text(context.l10n.event_sort_clear),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // ← キーボード重なり対策
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              maxHeight: MediaQuery.of(context).size.height * 0.87,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        ..._buildDisplayOrderAreaIfNeeded(
                          context: context,
                          currentDisplayOrder: currentDisplayOrder.value,
                          onChanged: (DisplayOrder displayOrder) =>
                              currentDisplayOrder.value = displayOrder,
                        ),
                        ..._buildVisibilityOptionsAreaIfNeeded(
                          context: context,
                          isHiddenParticipationEvent:
                              isHiddenParticipationEvent.value,
                          onChanged: (bool? selected) =>
                              isHiddenParticipationEvent.value =
                                  selected ?? false,
                        ),
                        _buildDateRangeArea(
                          context: context,
                          startDate: startDate.value,
                          endDate: endDate.value,
                          onChanged: (DateTime? inputStartDate,
                              DateTime? inputEndDate) {
                            startDate.value = inputStartDate;
                            endDate.value = inputEndDate;
                          },
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        ..._buildParticipationAreaIfNeeded(
                          context: context,
                          currentParticipationTypes:
                              currentParticipationTypes.value,
                          onChanged: (List<ParticipationType> types) {
                            currentParticipationTypes.value = types;
                          },
                        ),
                        ..._buildEventTypeAreaIfNeeded(
                          context: context,
                          isShowOfficialEvent: isShowOfficialEvent.value,
                          isShowOriginalEvent: isShowOriginalEvent.value,
                          onChanged: (EventType eventType) {
                            switch (eventType) {
                              case EventType.official:
                                isShowOfficialEvent.value =
                                    !isShowOfficialEvent.value;
                              case EventType.unofficial:
                                isShowOriginalEvent.value =
                                    !isShowOriginalEvent.value;
                            }
                          },
                        ),
                        ..._buildTypeTagsAreaIfNeeded(
                          context: context,
                          tags: tags.typeTags,
                          currentTags: currentTypeTags.value,
                          onChanged: (List<Tag> tags) =>
                              currentTypeTags.value = tags,
                        ),
                        ..._buildSeriesTagsAreaIfNeeded(
                          context: context,
                          tags: tags.seriesTags,
                          currentTags: currentSeriesTags.value,
                          onChanged: (List<Tag> tags) =>
                              currentSeriesTags.value = tags,
                        ),
                      ],
                    ),
                  ),
                  // ボタンは下固定
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            logEvent(event: AnalyticsEvent.filterCancelClick);

                            context.router.pop();
                          },
                          child: Text(
                            context.l10n.common_cancel,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            final FilterSettings filterSettings =
                                FilterSettings(
                              keyword: keywordController.text,
                              displayOrder: currentDisplayOrder.value,
                              participationFilters:
                                  currentParticipationTypes.value,
                              seriesTags: currentSeriesTags.value,
                              typeTags: currentTypeTags.value,
                              isHiddenParticipationEvent:
                                  isHiddenParticipationEvent.value,
                              isHiddenOriginalEvent:
                                  isHiddenOriginalEvent.value,
                              isShowOfficialEvent: isShowOfficialEvent.value,
                              isShowOriginalEvent: isShowOriginalEvent.value,
                              startDate: startDate.value,
                              endDate: endDate.value,
                            );

                            logEvent(
                              event: AnalyticsEvent.filterConfirmClick,
                              params: <String, Object>{
                                'keyword': keywordController.text,
                                'displayOrder': currentDisplayOrder.value,
                                'participationFilters':
                                    currentParticipationTypes.value,
                                'seriesTags': currentSeriesTags.value,
                                'typeTags': currentTypeTags.value,
                                'isHiddenParticipationEvent':
                                    isHiddenParticipationEvent.value ? 1 : 0,
                                'isHiddenOriginalEvent':
                                    isHiddenOriginalEvent.value ? 1 : 0,
                                'isShowOfficialEvent':
                                    isShowOfficialEvent.value ? 1 : 0,
                                'isShowOriginalEvent':
                                    isShowOriginalEvent.value ? 1 : 0,
                                'startDate': startDate,
                                'endDate': endDate,
                              },
                            );

                            context.router.pop(filterSettings);
                          },
                          child: Text(
                            context.l10n.common_determination,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDisplayOrderAreaIfNeeded({
    required BuildContext context,
    required DisplayOrder currentDisplayOrder,
    required Function(DisplayOrder displayOrder) onChanged,
  }) {
    if (!needDisplayOrderArea) return <Widget>[];

    return <Widget>[
      Center(
        child: Wrap(
          spacing: 12,
          children: DisplayOrder.values.map(
            (DisplayOrder displayOrder) {
              return ChoiceChip(
                showCheckmark: false,
                label: Text(
                  displayOrder.label(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                visualDensity: VisualDensity.comfortable,
                selected: currentDisplayOrder == displayOrder,
                onSelected: (_) => onChanged(displayOrder),
              );
            },
          ).toList(),
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildVisibilityOptionsAreaIfNeeded({
    required BuildContext context,
    required bool isHiddenParticipationEvent,
    required Function(bool? selected) onChanged,
  }) {
    if (!needHiddenParticipationArea) return <Widget>[];

    return <Widget>[
      GestureDetector(
        onTap: () => onChanged(!isHiddenParticipationEvent),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Checkbox(
              value: isHiddenParticipationEvent,
              onChanged: onChanged,
            ),
            Flexible(
              child: Text(
                context.l10n.event_sort_section_title_hidden_already_added,
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Divider(),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildParticipationAreaIfNeeded({
    required BuildContext context,
    required List<ParticipationType> currentParticipationTypes,
    required Function(List<ParticipationType> types) onChanged,
  }) {
    if (!needParticipationArea) return <Widget>[];

    return <Widget>[
      _buildExpansionSection(
        context: context,
        title: context.l10n.event_sort_section_title_paricipation,
        isSelected: currentParticipationTypes.isNotEmpty,
        child: Wrap(
          spacing: 4,
          runSpacing: 8,
          children: ParticipationType.values.map(
            (ParticipationType participationType) {
              return ChoiceChip(
                label: Text(
                  participationType.label(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                showCheckmark: false,
                visualDensity: VisualDensity.comfortable,
                selected: currentParticipationTypes.contains(participationType),
                onSelected: (bool selected) {
                  final List<ParticipationType> current =
                      List<ParticipationType>.of(currentParticipationTypes);
                  if (selected) {
                    current.add(participationType);
                  } else {
                    current.remove(participationType);
                  }
                  onChanged(current);
                },
              );
            },
          ).toList(),
        ),
      ),
      const SizedBox(height: 8),
      const Divider(),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildEventTypeAreaIfNeeded({
    required BuildContext context,
    required bool isShowOfficialEvent,
    required bool isShowOriginalEvent,
    required Function(EventType eventType) onChanged,
  }) {
    if (!needEventTypeArea) return <Widget>[];

    return <Widget>[
      _buildExpansionSection(
        context: context,
        title: context.l10n.event_sort_section_title_event_type,
        isSelected: isShowOfficialEvent || isShowOriginalEvent,
        child: Wrap(
          spacing: 4,
          runSpacing: 8,
          children: EventType.values.map(
            (EventType eventType) {
              return ChoiceChip(
                label: Text(
                  eventType.label(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                showCheckmark: false,
                visualDensity: VisualDensity.comfortable,
                selected: (eventType == EventType.official &&
                        isShowOfficialEvent) ||
                    (eventType == EventType.unofficial && isShowOriginalEvent),
                onSelected: (bool selected) {
                  onChanged(eventType);
                },
              );
            },
          ).toList(),
        ),
      ),
      const SizedBox(height: 8),
      const Divider(),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildTypeTagsAreaIfNeeded({
    required BuildContext context,
    required List<Tag> tags,
    required List<Tag> currentTags,
    required Function(List<Tag> tags) onChanged,
  }) {
    if (!needTagsArea) return <Widget>[];

    return <Widget>[
      _buildExpansionSection(
        context: context,
        title: context.l10n.event_sort_section_title_event_style,
        isSelected: currentTags.isNotEmpty,
        child: Wrap(
          spacing: 4,
          runSpacing: 8,
          children: tags.map(
            (Tag tag) {
              return ChoiceChip(
                showCheckmark: false,
                label: Text(
                  tag.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                visualDensity: VisualDensity.comfortable,
                selected: currentTags.contains(tag),
                onSelected: (bool selected) {
                  final List<Tag> current = List<Tag>.of(currentTags);
                  if (selected) {
                    current.add(tag);
                  } else {
                    current.remove(tag);
                  }
                  onChanged(current);
                },
              );
            },
          ).toList(),
        ),
      ),
      const SizedBox(height: 8),
      const Divider(),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildSeriesTagsAreaIfNeeded({
    required BuildContext context,
    required List<Tag> tags,
    required List<Tag> currentTags,
    required Function(List<Tag> tags) onChanged,
  }) {
    if (!needTagsArea) return <Widget>[];

    return <Widget>[
      _buildExpansionSection(
        context: context,
        title: context.l10n.event_sort_section_title_series_tag,
        isSelected: currentTags.isNotEmpty,
        child: Wrap(
          spacing: 4,
          runSpacing: 8,
          children: tags.map(
            (Tag tag) {
              return ChoiceChip(
                showCheckmark: false,
                label: Text(
                  tag.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                visualDensity: VisualDensity.comfortable,
                selected: currentTags.contains(tag),
                onSelected: (bool selected) {
                  final List<Tag> current = List<Tag>.of(currentTags);
                  if (selected) {
                    current.add(tag);
                  } else {
                    current.remove(tag);
                  }
                  onChanged(current);
                },
              );
            },
          ).toList(),
        ),
      ),
    ];
  }

  Widget _buildDateRangeArea({
    required BuildContext context,
    required DateTime? startDate,
    required DateTime? endDate,
    required void Function(DateTime? start, DateTime? end) onChanged,
  }) {
    return _buildExpansionSection(
      context: context,
      title: context.l10n.event_sort_span_title,
      isSelected: startDate != null || endDate != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final DateTime now = DateTime.now();
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      // 最小はμ's1stがある2012
                      firstDate: DateTime(2012),
                      // 最大は現在の1年後まで
                      lastDate: now.copyWith(year: now.year + 1),
                    );
                    if (picked != null) {
                      onChanged(picked, endDate);
                    }
                  },
                  child: Text(
                    startDate != null
                        ? startDate.simpleDateFormat()
                        : context.l10n.event_sort_span_start,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '〜',
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      onChanged(startDate, picked);
                    }
                  },
                  child: Text(
                    endDate != null
                        ? endDate.simpleDateFormat()
                        : context.l10n.event_sort_span_end,
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => onChanged(null, null),
            child: Text(context.l10n.event_sort_span_clear),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionSection({
    required BuildContext context,
    required String title,
    required Widget child,
    required bool isSelected,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        initiallyExpanded: isSelected,
        title: Row(
          children: <Widget>[
            Text(
              title,
              style: context.textTheme.bodyMedium,
            ),
            const Spacer(),
            if (isSelected)
              ParticipationStatusBadge(
                text: context.l10n.event_sort_selected,
                color: Colors.red,
              )
          ],
        ),
        children: <Widget>[child],
      ),
    );
  }
}
