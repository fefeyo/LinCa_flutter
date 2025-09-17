import '../../../core/utils/context_extension.dart';
import 'package:flutter/material.dart';

import '../../../core/network/model/group.dart';

class ChooseOfficialEventCard extends StatelessWidget {
  const ChooseOfficialEventCard({
    super.key,
    required this.groups,
    required this.onTap,
  });

  final List<Group> groups;
  final Function(Group group) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '公式イベントから選択',
            style: context.textTheme.titleLarge,
          ),
        ),
        // TODO: 仮
        leading: const Icon(Icons.verified, color: Colors.blueAccent),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        // 展開時の枠線消去
        collapsedShape:
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        // 閉じたときも消去
        children: groups
            .map((Group group) => ListTile(
                  title: Text(
                    group.name,
                    style: context.textTheme.titleMedium,
                  ),
                  onTap: () => onTap(group),
                ))
            .toList(),
      ),
    );
  }
}
