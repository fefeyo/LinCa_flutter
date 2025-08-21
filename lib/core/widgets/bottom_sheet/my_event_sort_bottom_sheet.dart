import 'package:auto_route/auto_route.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/core/utils/sort_items_extension.dart';
import 'package:flutter/material.dart';

class MyEventSortBottomSheet extends StatelessWidget {
  const MyEventSortBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: <Widget>[
              const SizedBox(height: 16),
              SearchBar(
                leading: const Icon(Icons.search),
                hintText: context.l10n.filter_search_hint,
                onChanged: (String value) {
                  // 入力に応じた処理
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
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
                      selected: displayOrder == DisplayOrder.newest,
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
                children: ParticipationFilter.values.map(
                  (ParticipationFilter participationFilter) {
                    return ChoiceChip(
                      label: Text(
                        participationFilter.label(context),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      visualDensity: VisualDensity.comfortable,
                      selected: false,
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
                      selected: false,
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, // 横幅いっぱい
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16), // 高さ感を出す
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 少し丸みを出す
                    ),
                  ),
                  onPressed: () {
                    context.router.pop();
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
    );
  }

  static Future<void> show(BuildContext context) async => showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (BuildContext context) => const MyEventSortBottomSheet());
}
