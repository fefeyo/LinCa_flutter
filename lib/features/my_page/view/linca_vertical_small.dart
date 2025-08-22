import 'package:fefeyo_flutter_template/core/utils/color_extension.dart';
import 'package:fefeyo_flutter_template/core/utils/context_extension.dart';
import 'package:fefeyo_flutter_template/core/utils/sort_items_extension.dart';
import 'package:flutter/material.dart';

import '../../../core/asset_gen/assets.gen.dart';

class LincaVerticalSmall extends StatelessWidget {
  const LincaVerticalSmall({
    super.key,
    required this.name,
    required this.avatar,
    this.seriesChips = const <SeriesTag>[],
    this.bio,
    this.onTap,
    this.tintColor,
  });

  final String name;
  final ImageProvider avatar;
  final List<SeriesTag> seriesChips;
  final String? bio;
  final VoidCallback? onTap;
  final Color? tintColor; // シリーズ色など

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = context.theme.brightness == Brightness.light
        ? context.colorScheme.surface
        : context.colorScheme.surfaceContainer;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Card(
        color: backgroundColor,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            // 本体（内容量に合わせて高さが決まる）
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // 上帯
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        (tintColor ?? context.colorScheme.primary)
                            .withValues(alpha: .95),
                        (tintColor ?? context.colorScheme.primary)
                            .withValues(alpha: .70),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 45),

                // テキスト群
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 6,
                        runSpacing: 4,
                        children: seriesChips
                            .map((SeriesTag tag) => Chip(
                                  label: Text(
                                    tag.label(context),
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: BorderSide.none,
                                  backgroundColor: tag.color(),
                                ))
                            .toList(),
                      ),
                    ),
                    if (bio != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                        child: Text(
                          bio!,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),

            // アバター（帯と本文の境目に重ねる）
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: backgroundColor, width: 3),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Image(
                    image: AssetImage(Assets.images.userIcon.path),
                  ),
                ),
              ),
            ),

            /// TODO: バッジ機能の実装
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Image(
                      image: AssetImage(Assets.images.userIcon.path),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Image(
                      image: AssetImage(Assets.images.userIcon.path),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Image(
                      image: AssetImage(Assets.images.userIcon.path),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
