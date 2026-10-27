import 'dart:convert';

const defaultIntervals = [1, 3, 7, 14];
const practiceLabels = ['practice', 'benchmark', 'unfamiliar'];
const recallObservations = ['needsWork', 'withHelp', 'independent'];
const advancedSettingKeys = {'reviewIntervals', 'practiceRecommendations'};
const scheduleExplanation =
    'Optional heuristic, not a mastery estimate. Your explicit recall observation chooses the next interval. Needs work or help returns to the first interval; independent recall advances one step. Missed days stay due without penalties. Each speech version, section and recall mode has its own schedule.';

String calendarDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
DateTime parseCalendarDate(String value) {
  final date = DateTime.tryParse('${value}T00:00:00Z');
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
      date == null ||
      calendarDate(date) != value) {
    throw const FormatException('Use a valid local date: YYYY-MM-DD.');
  }
  return date;
}

String plusDays(String date, int days) =>
    calendarDate(parseCalendarDate(date).add(Duration(days: days)));
List<int> validateIntervals(Object? value) {
  if (value is! List ||
      value.isEmpty ||
      value.length > 12 ||
      value.any((v) => v is! int || v < 1 || v > 365)) {
    throw const FormatException(
      'Use 1–12 increasing intervals, each 1–365 days.',
    );
  }
  final days = value.cast<int>();
  for (var i = 1; i < days.length; i++) {
    if (days[i] <= days[i - 1]) {
      throw const FormatException('Intervals must increase.');
    }
  }
  return days;
}

bool validAdvancedSetting(String key, String value) {
  if (key == 'practiceRecommendations') {
    return {'true', 'false'}.contains(value);
  }
  if (key != 'reviewIntervals') return false;
  try {
    validateIntervals(jsonDecode(value));
    return true;
  } catch (_) {
    return false;
  }
}

String observationLabel(String value) => switch (value) {
  'needsWork' => 'Needs work — my observation',
  'withHelp' => 'Recalled with help — my observation',
  'independent' => 'Recalled independently — my observation',
  _ => 'Not observed',
};
