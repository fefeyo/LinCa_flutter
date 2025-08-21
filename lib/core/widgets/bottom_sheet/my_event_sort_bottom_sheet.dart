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
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          minHeight: 800,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 16),
              SearchBar(
                leading: const Icon(Icons.search),
                hintText: 'キーワードを入力',
                onChanged: (value) {
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
                        style: Theme.of(context).textTheme.titleLarge,
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
                children: ParticipationFilter.values.map(
                  (ParticipationFilter participationFilter) {
                    return ChoiceChip(
                      label: Text(
                        participationFilter.label(context),
                        style: Theme.of(context).textTheme.titleLarge,
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
                        style: Theme.of(context).textTheme.titleLarge,
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
                    // 適用処理を書く
                    Navigator.of(context).pop(); // シートを閉じるなど
                  },
                  child: Text(
                    '適用',
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
      builder: (BuildContext context) => const MyEventSortBottomSheet());
}
