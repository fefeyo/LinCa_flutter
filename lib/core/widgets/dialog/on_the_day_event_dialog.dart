import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/network/model/participation_info.dart';
import 'package:linca_otaku_support/core/utils/color_extension.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';
import 'package:linca_otaku_support/core/utils/date_extension.dart';
import 'package:linca_otaku_support/core/utils/event_base_extension.dart';
import 'package:linca_otaku_support/core/utils/preferences_service.dart';
import 'package:linca_otaku_support/core/utils/providers.dart';
import '../../asset_gen/assets.gen.dart';
import '../../models/linca_event.dart';
import '../../router/app_router.gr.dart';

class OnTheDayEventDialog extends HookConsumerWidget {
  const OnTheDayEventDialog({
    super.key,
    required this.events,
    required this.participations,
  });

  final List<LincaEvent> events;
  final Map<LincaEvent, ParticipationInfo> participations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController controller = usePageController(viewportFraction: 1.0);
    final ValueNotifier<int> currentPage = useState(0);
    final ValueNotifier<bool> dontShowToday = useState(false);

    // 画面サイズから画像エリアの高さを決める（縦横どちらの画像でもそこそこバランス良い）
    final Size size = MediaQuery.of(context).size;
    final double imageHeight = size.height * 0.4; // お好みで 0.35〜0.45 くらい

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: <Color>[
              Colors.pink.shade300,
              Colors.pink.shade200,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildTitle(context),
            const SizedBox(height: 12),

            SizedBox(
              height: imageHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PageView.builder(
                  controller: controller,
                  onPageChanged: (int index) => currentPage.value = index,
                  itemCount: events.length,
                  itemBuilder: (BuildContext context, int index) {
                    final LincaEvent event = events[index];

                    return GestureDetector(
                      onTap: () => context.router.push(
                        EventDetailRoute(
                          lincaEvent: event,
                          participationInfo: participations[event],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          // ------ 背景ブラー＋カバーフィル --------------
                          if (event.event.displayImageUrl.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: event.event.displayImageUrl,
                              fit: BoxFit.cover,
                              color: Colors.black.withValues(alpha: 0.3),
                              colorBlendMode: BlendMode.darken,
                            )
                          else
                            Image.asset(
                              Assets.images.defaultLiveBackground.path,
                              fit: BoxFit.cover,
                              color: Colors.black.withValues(alpha: 0.3),
                              colorBlendMode: BlendMode.darken,
                            ),

                          // ------ メイン画像（contain） --------------
                          Center(
                            child: event.event.displayImageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: event.event.displayImageUrl,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    Assets.images.defaultLiveBackground.path,
                                    fit: BoxFit.contain,
                                  ),
                          ),

                          // ------ 下部グラデーション（タイトル背景） ------
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: <Color>[
                                    Colors.black.withValues(alpha: 0.75),
                                    Colors.black.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    event.event.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        context.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ページインジケータ
            if (events.length > 1)
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

            GestureDetector(
              onTap: () => dontShowToday.value = !dontShowToday.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Checkbox(
                    value: dontShowToday.value,
                    onChanged: (bool? v) => dontShowToday.value = v ?? false,
                    activeColor: Colors.white,
                    checkColor: Colors.pink.shade400,
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  Text(
                    '今日はもう表示しない',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            TextButton(
              onPressed: () {
                if (dontShowToday.value) {
                  // 今日表示しない設定を保存
                  final PreferencesService sharedPreferences =
                      ref.read(preferencesServiceProvider);
                  sharedPreferences
                      .updateLastUpdatedAt(AppConstants.hideOnTheDayDialog);
                }
                Navigator.of(context).pop();
              },
              child: Text(
                '閉じる',
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '本日開催の公式イベント',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.pink.shade600,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// ---------- static show() はそのまま ----------
  static Future<bool?> show({
    required BuildContext context,
    required List<LincaEvent> events,
    required Map<LincaEvent, ParticipationInfo> participations,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => OnTheDayEventDialog(
        events: events,
        participations: participations,
      ),
    );
  }
}
