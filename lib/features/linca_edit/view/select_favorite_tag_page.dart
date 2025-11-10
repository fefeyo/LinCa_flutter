import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:linca_otaku_support/core/constants/app_constants.dart';
import 'package:linca_otaku_support/core/utils/context_extension.dart';

import '../../../core/asset_gen/assets.gen.dart';
import '../../../core/network/model/group.dart';

@RoutePage()
class SelectFavoriteTagPage extends HookConsumerWidget {
  const SelectFavoriteTagPage({
    super.key,
    required this.groups,
    required this.favoriteTags,
    required this.maxTagCount,
  });

  final List<Group> groups;
  final List<Group> favoriteTags;
  final int maxTagCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double imageHeight = 50.0;
    const double titlePadding = 8.0;
    final ValueNotifier<List<Group>> changedFavoriteTags =
        useState(favoriteTags);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.select_favorite_tags_title),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.router.pop(changedFavoriteTags.value),
            icon: const Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: Image.asset(
                  Assets.images.lovelive.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagLovelive,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: Image.asset(
                  Assets.images.sunshine.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagSunshine,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: Image.asset(
                  Assets.images.nijigasaki.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagNijigasaki,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: Image.asset(
                  Assets.images.superstar.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagSuperstar,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: SvgPicture.asset(
                  Assets.images.hasunosora.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagHasunosora,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: Image.asset(
                  Assets.images.ikizulive.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagIkizulive,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: Image.asset(
                  Assets.images.yohane.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagYohane,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: Image.asset(
                  Assets.images.musical.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagMusical,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: titlePadding),
                child: SvgPicture.asset(
                  Assets.images.loveliveSeries.path,
                  height: imageHeight,
                ),
              ),
              children: <Widget>[
                _buildSeriesTagChips(
                  context: context,
                  targetSeriesTag: AppConstants.seriesTagCollaborative,
                  selectedTags: changedFavoriteTags.value,
                  onChanged: (List<Group> changed) =>
                      changedFavoriteTags.value = changed,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesTagChips({
    required BuildContext context,
    required String targetSeriesTag,
    required List<Group> selectedTags,
    required Function(List<Group> changed) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsetsGeometry.all(8),
      child: Wrap(
        spacing: 6,
        children: groups
            .where((Group group) => group.seriesTag == targetSeriesTag)
            .map((Group group) {
          return ChoiceChip(
            label: Text(group.name),
            showCheckmark: false,
            selected: selectedTags.contains(group),
            onSelected: (bool selected) {
              final List<Group> current = List<Group>.of(selectedTags);
              if (selected) {
                current.add(group);
              } else {
                current.remove(group);
              }
              _checkAndCallIfUnderLimit(
                context: context,
                selectedGroups: current,
                maxCount: maxTagCount,
                onValid: () => onChanged(current),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  void _checkAndCallIfUnderLimit({
    required BuildContext context,
    required List<Group> selectedGroups,
    required int maxCount,
    required Function() onValid,
  }) {
    if (selectedGroups.length > maxCount) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(context.l10n.select_favorite_tags_alert_title),
          content: Text(
            context.l10n.select_favorite_tags_alert_description(
                AppConstants.maxProfileTagCount),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.common_ok),
            ),
          ],
        ),
      );
      return;
    }
    onValid();
  }
}
