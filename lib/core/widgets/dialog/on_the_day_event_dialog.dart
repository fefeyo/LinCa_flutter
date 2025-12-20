import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import '../../asset_gen/assets.gen.dart';
import '../../models/linca_event.dart';

class OnTheDayEventDialog extends HookConsumerWidget {
  const OnTheDayEventDialog({
    super.key,
    required this.events,
  });

  final List<LincaEvent> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ---------- Hooks ----------
    final PageController controller = usePageController(viewportFraction: 1.0);
    final ValueNotifier<int> currentPage = useState(0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: <Color>[
              Colors.orange.shade200.withValues(alpha: 0.9),
              Colors.deepOrange.shade200.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.deepOrangeAccent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '🎉 本日開催のイベント 🎉',
              style: context.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 500,
              child: PageView.builder(
                controller: controller,
                onPageChanged: (int index) => currentPage.value = index,
                itemCount: events.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: events[0].event.displayImageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: events[0].event.displayImageUrl,
                                  fit: BoxFit.fitWidth,
                                )
                              : Image.asset(
                                  Assets.images.defaultLiveBackground.path,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(
                                      alpha: 0.3), // 半透明の黒背景
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  events[index].event.title,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ----------- Indicator ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(events.length, (int index) {
                final bool active = index == currentPage.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '閉じる',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- static show() 残す ----------
  static Future<bool?> show({
    required BuildContext context,
    required List<LincaEvent> events,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => OnTheDayEventDialog(events: events),
    );
  }
}
