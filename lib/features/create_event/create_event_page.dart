import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/models/linca_event.dart';
import 'package:linca_otaku_support/core/network/controller/participation_controller.dart';
import 'package:linca_otaku_support/core/network/controller/user_event_controller.dart';
import 'package:linca_otaku_support/core/network/model/event_base.dart';
import 'package:linca_otaku_support/core/network/model/tag.dart';
import 'package:linca_otaku_support/core/network/providers.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/participation_type.dart';
import '../../core/network/model/participation_info.dart';
import 'data/create_event_type.dart';

@RoutePage()
class CreateEventPage extends HookConsumerWidget {
  const CreateEventPage({
    super.key,
    required this.createEventType,
  });

  final CreateEventType createEventType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title = createEventType == CreateEventType.public
        ? context.l10n.create_public_event_title
        : context.l10n.create_private_event_title;
    final TextEditingController titleController = useTextEditingController();
    final ValueNotifier<DateTime?> selectedDate = useState<DateTime?>(null);
    final TextEditingController venueConroller = useTextEditingController();
    final TextEditingController eventUrlController = useTextEditingController();
    useTextEditingController();
    final TextEditingController descriptionController =
        useTextEditingController();
    final ValueNotifier<Set<Tag>> selectedTags = useState<Set<Tag>>(<Tag>{});
    final List<Tag> tags = ref.watch(tagControllerProvider).value ?? <Tag>[];
    final UserEventController userEventController =
        ref.read(userEventControllerProvider.notifier);
    final ParticipationController participationController =
        ref.read(participationControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'タイトルを入力してください',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 1),
                  ),
                );
                return;
              }
              if (selectedDate.value == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '開催日を選択してください',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 1),
                  ),
                );
                return;
              }

              final String eventId = const Uuid().v4();
              final UnOfficialEvent event = UnOfficialEvent(
                title: titleController.text,
                desrcription: descriptionController.text,
                venueName: venueConroller.text,
                date: selectedDate.value,
                url: eventUrlController.text,
                tagIds: selectedTags.value.map((Tag tag) => tag.id).toList(),
                visibility:
                    createEventType == CreateEventType.public ? true : false,
              );
              await userEventController.registerEvent(
                eventId: eventId,
                event: event,
              );
              await participationController.createParticipation(
                lincaEvent: LincaEvent(
                  event: event,
                ),
                participation: ParticipationInfo(
                  eventId: eventId,
                  participationType: ParticipationType.onSite,
                ),
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'イベントを作成しました',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
                context.router.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // タイトル
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: context.l10n.input_create_event_title,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // イベント概要
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: context.l10n.input_create_event_description,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 開催日
            Row(
              children: <Widget>[
                Text(
                  selectedDate.value != null
                      ? '${selectedDate.value!.year}/${selectedDate.value!.month}/${selectedDate.value!.day}'
                      : context.l10n.text_create_event_choose_date,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) selectedDate.value = picked;
                  },
                  child: Text(context.l10n.input_create_event_choose_date),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 開催場所
            TextField(
              controller: venueConroller,
              decoration: InputDecoration(
                labelText: context.l10n.input_create_event_venue,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // イベントURL
            TextField(
              controller: eventUrlController,
              decoration: InputDecoration(
                labelText: context.l10n.input_create_event_event_url,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // タグ選択
            Text(
              context.l10n.input_create_event_tag,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Wrap(
              spacing: 4,
              runSpacing: 8,
              children: tags
                  .where((Tag tag) => tag.category == 'series')
                  .map((Tag tag) {
                return FilterChip(
                  label: Text(tag.name),
                  selected: selectedTags.value.contains(tag),
                  onSelected: (bool selected) {
                    final Set<Tag> updated = Set<Tag>.of(selectedTags.value);
                    if (selected) {
                      updated.add(tag);
                    } else {
                      updated.remove(tag);
                    }
                    selectedTags.value = updated;
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
