import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/list_extension.dart';
import 'package:linca_otaku_support/features/output_participate_events/data/output_participate_events_state.dart';
import 'package:linca_otaku_support/features/output_participate_events/view/output_participate_event_page.dart';
import 'package:linca_otaku_support/features/output_participate_events/view_model/output_participate_events_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/models/filter_settings.dart';
import '../../core/models/linca_event.dart';
import '../../core/widgets/bottom_sheet/event_sort_bottom_sheet.dart';

@RoutePage()
class OutputParticipateEventsPage extends HookConsumerWidget {
  const OutputParticipateEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OutputParticipateEventsState state =
        ref.watch(outputParticipateEventsViewModelProvider);
    final OutputParticipateEventsViewModel viewModel =
        ref.read(outputParticipateEventsViewModelProvider.notifier);
    final ValueNotifier<bool> isSearching = useState(false);
    final TextEditingController searchController = useTextEditingController();
    final List<List<LincaEvent>> pages =
        state.sortedEvents.keys.toList().chunk(12);
    final PageController pageController = usePageController();
    final List<GlobalKey> pageKeys = List<GlobalKey>.generate(
      pages.length,
      (_) => GlobalKey(),
    );

    return Scaffold(
      appBar: AppBar(
        title: isSearching.value
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.l10n.hint_choose_official_event_keyword,
                  border: InputBorder.none,
                ),
                style: context.textTheme.bodyMedium,
                onChanged: (String value) {
                  viewModel.setKeyword(value);
                },
              )
            : Text(
                '参加イベント出力画面',
                style: context.textTheme.titleMedium,
              ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              final FilterSettings? result = await EventSortBottomSheet.show(
                context,
                state.filterSettings,
                needInputArea: true,
                needHiddenOriginalEventArea: true,
                needDisplayOrderArea: true,
                needParticipationArea: true,
                needEventTypeArea: true,
                needTagsArea: true,
              );
              if (result != null) {
                viewModel.setFilterSettings(result);
              }
            },
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            icon: Icon(isSearching.value ? Icons.close : Icons.search),
            onPressed: () {
              isSearching.value = !isSearching.value;
              if (!isSearching.value) {
                searchController.clear();
                viewModel.setKeyword('');
              }
            },
          ),
        ],
      ),
      body: state.sortedEvents.isEmpty
          ? Center(
              child: Text(
                context.l10n.event_list_empty_title,
                style: context.textTheme.titleMedium,
              ),
            )
          : PageView(
              controller: pageController,
              children:
                  pages.mapIndexed((int pageIndex, List<LincaEvent> page) {
                final GlobalKey pageKey = pageKeys[pageIndex];
                return RepaintBoundary(
                  key: pageKey,
                  child: OutputParticipateEventPage(events: page),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (pages.isEmpty) {
            return;
          }
          final List<Uint8List> pngs = await _captureAll(pageKeys);

          if (!context.mounted) return;
          await _saveImagesToGallery(context, pngs);
        },
        child: const Icon(Icons.download),
      ),
    );
  }

  Future<List<Uint8List>> _captureAll(List<GlobalKey> keys) async {
    final List<Uint8List> images = <Uint8List>[];
    for (final GlobalKey key in keys) {
      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final ByteData byteData =
          (await image.toByteData(format: ui.ImageByteFormat.png))!;
      images.add(byteData.buffer.asUint8List());
    }
    return images;
  }

  Future<void> _saveImagesToGallery(
    BuildContext context,
    List<Uint8List> pngBytesList,
  ) async {
    if (pngBytesList.isEmpty) {
      return;
    }
    // Android 権限
    if (Theme.of(context).platform == TargetPlatform.android) {
      final PermissionStatus status = await Permission.photos.request();

      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存に必要な権限がありません')),
          );
        }
        return;
      }
    }

    int successCount = 0;
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    for (int index = 0; index < pngBytesList.length; index++) {
      final Map<String, dynamic> result =
          await ImageGallerySaverPlus.saveImage(
        pngBytesList[index],
        quality: 100,
        name: 'linca_events_${timestamp}_${index + 1}',
      );
      if (result['isSuccess'] == true) {
        successCount++;
      }
    }

    if (!context.mounted) return;

    if (successCount == pngBytesList.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像を保存しました')),
      );
    } else if (successCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像の保存に失敗しました')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('一部の画像の保存に失敗しました ($successCount/${pngBytesList.length})'),
        ),
      );
    }
  }
}
