const impromptuCategories = {
  'everyday': 'Everyday choices',
  'community': 'Community & cooperation',
  'ideas': 'Ideas & tradeoffs',
};
const impromptuCriteria = ['directness', 'structure', 'support', 'relevance'];
const impromptuPresets = {
  'Untimed': [0, 0],
  'Quick challenge': [30, 60],
  'Thoughtful challenge': [60, 120],
};
const impromptuScaffold = {
  'point': 'Point — your direct answer',
  'reason': 'Reason — why you think so',
  'example': 'Example — a specific illustration',
  'close': 'Close — return to the question',
};

void validateImpromptuContent(Object? value, Object? rubric) {
  Never invalid() =>
      throw const FormatException('Invalid impromptu question or rubric');
  if (value is! Map<String, dynamic> ||
      value.length != 1 ||
      !impromptuCategories.containsKey(value['category'])) {
    invalid();
  }
  if (rubric is! Map || rubric['criteria'] is! List) {
    invalid();
  }
  final criteria = rubric['criteria'] as List;
  if (criteria.length != 4 ||
      criteria.map((c) => c is Map ? c['id'] : null).toSet().length != 4 ||
      criteria.any((c) => c is! Map || !impromptuCriteria.contains(c['id']))) {
    invalid();
  }
  for (final c in criteria) {
    final anchors = c['anchors'];
    if (anchors is! Map ||
        anchors.length != 3 ||
        !['emerging', 'developing', 'effective'].every(
          (k) =>
              anchors[k] is String &&
              (anchors[k] as String).trim().isNotEmpty &&
              (anchors[k] as String).length < 2000,
        )) {
      invalid();
    }
  }
}

List<int> validateImpromptuTargets(Object? value) {
  if (value is! List ||
      value.length != 2 ||
      value.any((n) => n is! int || n < 0 || n > 3600)) {
    throw ArgumentError(
      'Use 0–3600 seconds for preparation and response. Zero is untimed.',
    );
  }
  return value.cast<int>();
}
