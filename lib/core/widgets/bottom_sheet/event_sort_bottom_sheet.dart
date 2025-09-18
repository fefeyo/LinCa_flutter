import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/filter_settings.dart';
import 'package:linca_otaku_support/core/network/model/group.dart';

import '../../../core/utils/context_extension.dart';
import '../../constants/participation_type.dart';
import '../../network/providers.dart';
import '../../utils/sort_items_extension.dart';

class EventSortBottomSheet extends HookConsumerWidget {
  const EventSortBottomSheet({
    super.key,
    required this.initialSettings,
    this.needInputArea = false,
    this.needDisplayOrderArea = false,
    this.needParticipationArea = false,
    this.needGroupArea = false,
  });

  final FilterSettings initialSettings;
  final bool needInputArea;
  final bool needDisplayOrderArea;
  final bool needParticipationArea;
  final bool needGroupArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String> keyword = useState(initialSettings.keyword);
    final ValueNotifier<DisplayOrder> currentDisplayOrder =
        useState(initialSettings.displayOrder);
    final ValueNotifier<List<ParticipationType>> currentParticipationTypes =
        useState(initialSettings.participationFilters);
    final ValueNotifier<List<Group>> currentGroups =
        useState(initialSettings.groups);
    final List<Group> groups =
        ref.watch(groupControllerProvider).value ?? <Group>[];

    List<Widget> buildInputAreaIfNeeded() {
      if (!needInputArea) return <Widget>[];

      return <Widget>[
        const SizedBox(height: 16),
        SearchBar(
          leading: const Icon(Icons.search),
          hintText: context.l10n.filter_search_hint,
          onChanged: (String value) {
            keyword.value = value;
          },
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
      ];
    }

    List<Widget> buildDisplayOrderAreaIfNeeded() {
      if (!needDisplayOrderArea) return <Widget>[];

      return <Widget>[
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: DisplayOrder.values.map(
            (DisplayOrder displayOrder) {
              return ChoiceChip(
                label: Text(
                  displayOrder.label(context),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                visualDensity: VisualDensity.comfortable,
                selected: currentDisplayOrder.value == displayOrder,
                onSelected: (bool selected) =>
                    currentDisplayOrder.value = displayOrder,
              );
            },
          ).toList(),
        ),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
      ];
    }

    List<Widget> buildParticipationAreaIfNeeded() {
      if (!needParticipationArea) return <Widget>[];

      return <Widget>[
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: ParticipationType.values.map(
            (ParticipationType participationType) {
              return ChoiceChip(
                label: Text(
                  participationType.label(context),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                visualDensity: VisualDensity.comfortable,
                selected:
                    currentParticipationTypes.value.contains(participationType),
                onSelected: (bool selected) {
                  final List<ParticipationType> current =
                      List<ParticipationType>.of(
                          currentParticipationTypes.value);
                  if (selected) {
                    current.add(participationType);
                  } else {
                    current.remove(participationType);
                  }
                  currentParticipationTypes.value = current;
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

    List<Widget> buildSeriesTagAreaIfNeeded() {
      if (!needGroupArea) return <Widget>[];

      return <Widget>[
        Wrap(
          spacing: 4,
          runSpacing: 8,
          children: groups.map(
            (Group group) {
              return ChoiceChip(
                label: Text(
                  group.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                visualDensity: VisualDensity.comfortable,
                selected: currentGroups.value.contains(group),
                onSelected: (bool selected) {
                  final List<Group> current =
                      List<Group>.of(currentGroups.value);
                  if (selected) {
                    current.add(group);
                  } else {
                    current.remove(group);
                  }
                  currentGroups.value = current;
                },
              );
            },
          ).toList(),
        ),
      ];
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // ← キーボード重なり対策
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ...buildInputAreaIfNeeded(),
                ...buildDisplayOrderAreaIfNeeded(),
                ...buildParticipationAreaIfNeeded(),
                ...buildSeriesTagAreaIfNeeded(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, // 横幅いっぱい
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
                          keyword: keyword.value,
                          displayOrder: currentDisplayOrder.value,
                          participationFilters: currentParticipationTypes.value,
                          groups: currentGroups.value,
                        ),
                      );
                    },
                    child: Text(
                      context.l10n.filter_apply_button,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white, // 適用ボタンは白文字が定番
                            fontWeight: FontWeight.bold,
                          ),
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

  static Future<FilterSettings?> show(
    BuildContext context,
    FilterSettings initialSettings, {
    bool needInputArea = false,
    bool needDisplayOrderArea = false,
    bool needParticipationArea = false,
    bool needSeriesTagArea = false,
  }) async =>
      showModalBottomSheet<FilterSettings?>(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        builder: (BuildContext context) => EventSortBottomSheet(
          initialSettings: initialSettings,
          needInputArea: needInputArea,
          needDisplayOrderArea: needDisplayOrderArea,
          needParticipationArea: needParticipationArea,
          needGroupArea: needSeriesTagArea,
        ),
      );
}
