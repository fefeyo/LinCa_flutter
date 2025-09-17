import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/utils/context_extension.dart';
import '../../utils/sort_items_extension.dart';

class MyEventSortBottomSheet extends HookConsumerWidget {
  const MyEventSortBottomSheet({
    super.key,
    this.needInputArea = false,
  });

  final bool needInputArea;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String> keyword = useState('');
    final ValueNotifier<List<DisplayOrder>> displayOrders =
        useState(<DisplayOrder>[]);
    final ValueNotifier<List<Participation>> participations =
        useState(<Participation>[]);
    final ValueNotifier<List<SeriesTag>> seriesTags = useState(<SeriesTag>[]);

    List<Widget> buildInputAreaIfNeeded() {
      if (needInputArea) {
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

      return <Widget>[];
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
                        selected: displayOrders.value.contains(displayOrder),
                        onSelected: (bool selected) {
                          if (selected) {
                            displayOrders.value.add(displayOrder);
                          } else {
                            displayOrders.value.remove(displayOrder);
                          }
                        },
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 8,
                  children: Participation.values.map(
                    (Participation participation) {
                      return ChoiceChip(
                        label: Text(
                          participation.label(context),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        visualDensity: VisualDensity.comfortable,
                        selected: participations.value.contains(participation),
                        onSelected: (bool selected) {
                          if (selected) {
                            participations.value.add(participation);
                          } else {
                            participations.value.remove(participation);
                          }
                        },
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 8,
                  children: SeriesTag.values.map(
                    (SeriesTag seriesTag) {
                      return ChoiceChip(
                        label: Text(
                          seriesTag.label(context),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        visualDensity: VisualDensity.comfortable,
                        selected: seriesTags.value.contains(seriesTag),
                        onSelected: (bool selected) {
                          if (selected) {
                            seriesTags.value.add(seriesTag);
                          } else {
                            seriesTags.value.remove(seriesTag);
                          }
                        },
                      );
                    },
                  ).toList(),
                ),
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
                      context.router.pop(<String, Object>{
                        'keyword': keyword.value,
                        'displayOrder': displayOrders.value,
                        'participationFilter': participations.value,
                        'seriesTag': seriesTags.value,
                      });
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

  static Future<void> show(BuildContext context) async => showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        builder: (BuildContext context) => const MyEventSortBottomSheet(),
      );

  static Future<void> showWithInput(BuildContext context) async =>
      showModalBottomSheet(
        context: context,
        enableDrag: false,
        isScrollControlled: true,
        builder: (BuildContext context) =>
            const MyEventSortBottomSheet(needInputArea: true),
      );
}
