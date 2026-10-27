const debateStageKeys = [
  'preparation',
  'opening',
  'opposition',
  'rebuttal',
  'reflection',
];
const debateStageLabels = [
  'Preparation',
  'Opening',
  'Scripted opposition',
  'Rebuttal',
  'Reflection',
];
const debateCriteria = [
  'relevance',
  'support',
  'reasoning',
  'fairness',
  'response',
];
const supportKinds = ['assertion', 'example', 'source'];
const supportLabels = [
  'Unsupported assertion / not supplied',
  'Illustrative example — not proof',
  'Source-backed claim — self-labelled, unchecked',
];
const debateFieldLabels = {
  'claim': 'Claim',
  'reasoning': 'Reasoning',
  'evidence': 'Evidence or example',
  'sourceNotes': 'Source notes and limitations',
  'opening': 'Opening argument',
  'counterargument': 'Counterargument — your fair summary',
  'rebuttal': 'Rebuttal — answer the opposing claim',
  'reflection': 'Reflection and next action',
};
const debateFields = {
  'preparation': ['claim', 'reasoning', 'evidence', 'sourceNotes'],
  'opening': ['opening'],
  'opposition': ['counterargument'],
  'rebuttal': ['rebuttal', 'evidence', 'sourceNotes'],
  'reflection': ['reflection'],
};
const debatePresets = {
  'Untimed round': [0, 0, 0, 0, 0],
  'Short round': [120, 60, 45, 60, 60],
  'Extended round': [240, 120, 90, 120, 120],
};

void validateDebateContent(Object? value, Object? rubric) {
  Never invalid() =>
      throw const FormatException('Invalid scripted debate content or rubric');
  bool text(Object? v) =>
      v is String && v.trim().isNotEmpty && v.length <= 20000;
  if (value is! Map<String, dynamic> ||
      value.length != 4 ||
      !value.keys.toSet().containsAll({
        'motion',
        'scenario',
        'for',
        'against',
      })) {
    invalid();
  }
  if (!text(value['motion']) || !text(value['scenario'])) invalid();
  for (final side in ['for', 'against']) {
    final script = value[side];
    if (script is! Map<String, dynamic> ||
        script.length != 3 ||
        script['kind'] != 'scripted' ||
        !text(script['argument']) ||
        !text(script['challenge'])) {
      invalid();
    }
  }
  if (rubric is! Map || rubric['criteria'] is! List) invalid();
  final criteria = rubric['criteria'] as List;
  if (criteria.length != 5 ||
      criteria
          .map((c) => c is Map ? c['id'] : null)
          .toSet()
          .difference(debateCriteria.toSet())
          .isNotEmpty) {
    invalid();
  }
  for (final c in criteria) {
    if (c is! Map || c['anchors'] is! Map) invalid();
    final a = c['anchors'] as Map;
    if (a.length != 3 ||
        !['emerging', 'developing', 'effective'].every((k) => text(a[k]))) {
      invalid();
    }
  }
}

List<int> validateDebateTargets(Object? value) {
  if (value is! List ||
      value.length != 5 ||
      value.any((v) => v is! int || v < 0 || v > 3600)) {
    throw ArgumentError(
      'Choose 0–3600 seconds for each stage; zero is untimed.',
    );
  }
  return value.cast<int>();
}
