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
    this.isEditMode = false,
    this.unOfficialEvent,
  });

  final CreateEventType createEventType;
  final bool isEditMode;
  final UnOfficialEvent? unOfficialEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title = switch (createEventType) {
      CreateEventType.public =>
      isEditMode ? '公開イベント編集' : context.l10n.create_public_event_title,

      CreateEventType.private =>
      isEditMode ? '非公開イベント編集' : context.l10n.create_private_event_title,
    };
    final TextEditingController titleController =
        useTextEditingController(text: unOfficialEvent?.title);
    final ValueNotifier<DateTime?> selectedDate =
        useState<DateTime?>(unOfficialEvent?.date);
    final TextEditingController venueConroller =
        useTextEditingController(text: unOfficialEvent?.venueName);
    final TextEditingController organizerNameController =
    useTextEditingController(text: unOfficialEvent?.organizerName);
    final TextEditingController eventUrlController =
        useTextEditingController(text: unOfficialEvent?.url);
    final TextEditingController descriptionController =
        useTextEditingController(
      text: unOfficialEvent?.desrcription,
    );
    final List<Tag> tags = ref.watch(tagControllerProvider).value ?? <Tag>[];
    final ValueNotifier<Set<Tag>> selectedTags = useState<Set<Tag>>(
      (unOfficialEvent?.tagIds ?? const <String>[])
          .map(
            (String id) =>
                tags.where((Tag tag) => tag.id == id).cast<Tag?>().firstOrNull,
          )
          .whereType<Tag>()
          .toSet(),
    );
    final UserEventController userEventController =
        ref.read(userEventControllerProvider.notifier);
    final ParticipationController participationController =
        ref.read(participationControllerProvider.notifier);
    final ObjectRef<GlobalKey<FormState>> formKey =
        useRef(GlobalKey<FormState>());

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (formKey.value.currentState?.validate() == false) return;
              if (selectedDate.value == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.create_event_event_date_required,
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

              final String eventId;
              if (isEditMode && unOfficialEvent != null) {
                eventId = unOfficialEvent!.id;
              } else {
                eventId = const Uuid().v4();
              }
              final UnOfficialEvent event = UnOfficialEvent(
                title: titleController.text,
                desrcription: descriptionController.text,
                venueName: venueConroller.text,
                organizerName: organizerNameController.text,
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
              if (!isEditMode) {
                await participationController.createParticipation(
                  lincaEvent: LincaEvent(
                    event: event,
                  ),
                  participation: ParticipationInfo(
                    eventId: eventId,
                    participationType: ParticipationType.onSite,
                  ),
                );
              }

              if (context.mounted) {
                final String text = isEditMode
                    ? context.l10n.create_event_event_updated
                    : context.l10n.create_event_event_created;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      text,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // イベント名
                Row(
                  children: <Widget>[
                    Text(
                      context.l10n.input_create_event_title,
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      context.l10n.common_required,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: context.l10n.create_event_title_hint,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.create_event_event_name_required;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // イベント概要
                Text(
                  context.l10n.input_create_event_description,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: context.l10n.create_event_description_hint,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                // 開催日
                Row(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          selectedDate.value != null
                              ? '${selectedDate.value!.year}/${selectedDate.value!.month}/${selectedDate.value!.day}'
                              : context.l10n.text_create_event_choose_date,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        if (selectedDate.value == null)
                          Text(
                            context.l10n.common_required,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                            ),
                          ),
                      ],
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
                Text(
                  context.l10n.input_create_event_venue,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: venueConroller,
                  decoration: InputDecoration(
                    labelText: context.l10n.create_event_venue_hint,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 主催者名
                Text(
                  context.l10n.create_event_organizer_title,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: organizerNameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.create_event_organizer_hint,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // イベントURL
                Text(
                  context.l10n.input_create_event_event_url,
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: eventUrlController,
                  decoration: InputDecoration(
                    labelText: context.l10n.input_create_event_event_url_hint,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
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
                      showCheckmark: false,
                      label: Text(tag.name),
                      selected: selectedTags.value.contains(tag),
                      onSelected: (bool selected) {
                        final Set<Tag> updated =
                            Set<Tag>.of(selectedTags.value);
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
        ),
      ),
    );
  }
}
