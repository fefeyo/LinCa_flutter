import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/filter_settings.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/tag_extension.dart';

import '../../../core/utils/context_extension.dart';
import '../../constants/participation_type.dart';
import '../../network/model/tag.dart';
import '../../utils/sort_items_extension.dart';

class EventSortBottomSheet extends HookConsumerWidget {
  const EventSortBottomSheet({
    super.key,
    required this.initialSettings,
    this.needInputArea = false,
    this.needHiddenParticipationArea = false,
    this.needDisplayOrderArea = false,
    this.needParticipationArea = false,
    this.needTagsArea = false,
  });

  final FilterSettings initialSettings;
  final bool needInputArea;
  final bool needHiddenParticipationArea;
  final bool needDisplayOrderArea;
  final bool needParticipationArea;
  final bool needTagsArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController keywordController =
        useTextEditingController(text: initialSettings.keyword);
    final ValueNotifier<DisplayOrder> currentDisplayOrder =
        useState(initialSettings.displayOrder);
    final ValueNotifier<List<ParticipationType>> currentParticipationTypes =
        useState(initialSettings.participationFilters);
    final ValueNotifier<List<Tag>> currentTypeTags =
        useState(initialSettings.typeTags);
    final ValueNotifier<List<Tag>> currentSeriesTags =
        useState(initialSettings.seriesTags);
    final List<Tag> tags = ref.watch(tagControllerProvider).value ?? <Tag>[];
    final ValueNotifier<bool> isHiddenParticipationEvent =
        useState(initialSettings.isHiddenParticipationEvent);

    return SafeArea(
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      Center(
                        child: Text(
                          'イベントを絞り込む',
                          style: context.textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ..._buildDisplayOrderAreaIfNeeded(
                        context: context,
                        currentDisplayOrder: currentDisplayOrder.value,
                        onChanged: (DisplayOrder displayOrder) =>
                            currentDisplayOrder.value = displayOrder,
                      ),
                      _buildParticipationEnabled(
                        context: context,
                        isHiddenParticipationEvent:
                            isHiddenParticipationEvent.value,
                        onChanged: (bool? selected) =>
                            isHiddenParticipationEvent.value =
                                selected ?? false,
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
                        onPressed: () => context.router.pop(),
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
                          context.router.pop(
                            FilterSettings(
                              keyword: keywordController.text,
                              displayOrder: currentDisplayOrder.value,
                              participationFilters:
                                  currentParticipationTypes.value,
                              seriesTags: currentSeriesTags.value,
                              typeTags: currentTypeTags.value,
                              isHiddenParticipationEvent:
                                  isHiddenParticipationEvent.value,
                            ),
                          );
                        },
                        child: Text(
                          '決定',
                          // context.l10n.filter_apply_button,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
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
    ];
  }

  Widget _buildParticipationEnabled({
    required BuildContext context,
    required bool isHiddenParticipationEvent,
    required Function(bool? selected) onChanged,
  }) {
    if (!needHiddenParticipationArea) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => onChanged(!isHiddenParticipationEvent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: isHiddenParticipationEvent,
            onChanged: onChanged,
          ),
          Text(
            '参加予定のイベントを非表示',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticipationAreaIfNeeded({
    required BuildContext context,
    required List<ParticipationType> currentParticipationTypes,
    required Function(List<ParticipationType> types) onChanged,
  }) {
    if (!needParticipationArea) return <Widget>[];

    return <Widget>[
      Text(
        '参加形態',
        style: context.textTheme.bodyMedium,
      ),
      const SizedBox(height: 8),
      Wrap(
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
      Text(
        'イベント形態',
        style: context.textTheme.bodyMedium,
      ),
      const SizedBox(height: 8),
      Wrap(
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
      Text(
        'シリーズタグ',
        style: context.textTheme.bodyMedium,
      ),
      const SizedBox(height: 8),
      Wrap(
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
    ];
  }

  static Future<FilterSettings?> show(
    BuildContext context,
    FilterSettings initialSettings, {
    bool needInputArea = false,
    bool needHiddenParticipationArea = false,
    bool needDisplayOrderArea = false,
    bool needParticipationArea = false,
    bool needTagsArea = false,
  }) async =>
      showModalBottomSheet<FilterSettings?>(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) => EventSortBottomSheet(
          initialSettings: initialSettings,
          needInputArea: needInputArea,
          needHiddenParticipationArea: needHiddenParticipationArea,
          needDisplayOrderArea: needDisplayOrderArea,
          needParticipationArea: needParticipationArea,
          needTagsArea: needTagsArea,
        ),
      );
}
