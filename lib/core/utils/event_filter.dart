import '../models/filter_settings.dart';
import '../models/linca_event.dart';
import '../network/model/event_base.dart';
import 'linca_event_extension.dart';

/// Shared list filters; participation rules stay in each view model.
extension EventFilter on List<LincaEvent> {
  List<LincaEvent> applyFilterSettings(FilterSettings settings) =>
      filterWithPeriod(startDate: settings.startDate, endDate: settings.endDate)
          .filterWithTag(settings.typeTags)
          .filterWithTag(settings.seriesTags)
          .filterWithKeyword(settings.keyword)
          .sortWithDisplayOrder(displayOrder: settings.displayOrder);

  List<LincaEvent> filterWithEventVisibility(FilterSettings settings) {
    // Preserve the existing fallback and intersection of the visibility flags.
    if (!settings.isShowOfficialEvent && !settings.isShowOriginalEvent) {
      return List<LincaEvent>.of(this);
    }
    return where((LincaEvent event) {
      if ((settings.isHiddenOriginalEvent || settings.isShowOfficialEvent) &&
          event.event is! OfficialEvent) {
        return false;
      }
      if (settings.isShowOriginalEvent && event.event is! UnOfficialEvent) {
        return false;
      }
      return true;
    }).toList();
  }
}
