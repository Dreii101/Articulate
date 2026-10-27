import 'dart:convert';

const cueStages = ['full', 'phrase', 'keywords', 'title', 'hidden'];
const cueLabels = ['Full text', 'Phrase', 'Keywords', 'Title only', 'Hidden'];
const memoryModes = ['verbatim', 'meaning'];
const recallKinds = ['typed', 'spoken'];
const recallRatings = ['notAssessed', 'missed', 'recalled'];

class MemoryDocument {
  MemoryDocument._(this.json);
  final String json;
  Map<String, dynamic> get data => jsonDecode(json) as Map<String, dynamic>;
  String get title => data['title'] as String;
  List<Map<String, dynamic>> get sections =>
      (data['sections'] as List).cast<Map<String, dynamic>>();
  factory MemoryDocument.parse(Object? value, {bool draft = false}) {
    Never invalid() => throw const FormatException(
      'A speech needs a title, language, level, and 1–30 sections with unique IDs, titles, and text.',
    );
    if (value is! Map<String, dynamic>) invalid();
    const fields = {
      'title',
      'language',
      'level',
      'author',
      'license',
      'sections',
    };
    if (value.keys.toSet().difference(fields).isNotEmpty ||
        !value.keys.toSet().containsAll(fields)) {
      invalid();
    }
    for (final key in fields.difference({'sections'})) {
      if (value[key] is! String ||
          (value[key] as String).length > 500 ||
          (!draft && (value[key] as String).trim().isEmpty)) {
        invalid();
      }
    }
    if (!{'beginner', 'intermediate', 'advanced'}.contains(value['level']) ||
        !RegExp(r'^[a-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$')
            .hasMatch(value['language'] as String)) {
      invalid();
    }
    final sections = value['sections'];
    if (sections is! List || sections.isEmpty || sections.length > 30) {
      invalid();
    }
    final ids = <String>{};
    const sectionFields = {
      'id',
      'title',
      'text',
      'phrase',
      'keywords',
      'ideas',
      'transition',
    };
    for (final s in sections) {
      if (s is! Map<String, dynamic> ||
          s.keys.toSet().difference(sectionFields).isNotEmpty ||
          !s.keys.toSet().containsAll(sectionFields)) {
        invalid();
      }
      for (final key in sectionFields) {
        if (s[key] is! String ||
            (s[key] as String).length > (key == 'text' ? 10000 : 2000)) {
          invalid();
        }
      }
      if (!RegExp(r'^[a-z][a-z0-9-]{0,79}$').hasMatch(s['id'] as String) ||
          !ids.add(s['id'] as String)) {
        invalid();
      }
      if (!draft &&
          ((s['title'] as String).trim().isEmpty ||
              (s['text'] as String).trim().isEmpty)) {
        invalid();
      }
    }
    final encoded = jsonEncode(value);
    if (encoded.length > 400000) invalid();
    return MemoryDocument._(encoded);
  }
}

void validateMemorySnapshot(Object? value) {
  if (value is! Map<String, dynamic> ||
      value.keys.toSet().difference({
        'speechId',
        'versionId',
        'versionNumber',
        'sectionId',
        'speech',
      }).isNotEmpty ||
      value.length != 5) {
    throw const FormatException('Invalid memory reference');
  }
  for (final k in ['speechId', 'versionId', 'sectionId']) {
    if (value[k] is! String ||
        (value[k] as String).isEmpty ||
        (value[k] as String).length > 80) {
      throw const FormatException('Invalid memory ID');
    }
  }
  if (value['versionNumber'] is! int || (value['versionNumber'] as int) < 1) {
    throw const FormatException('Invalid speech version');
  }
  final speech = MemoryDocument.parse(value['speech']);
  if (!speech.sections.any((s) => s['id'] == value['sectionId'])) {
    throw const FormatException('Missing practiced section');
  }
}

List<MemoryDocument> validateMemoryPack(String source) {
  if (source.length > 1000000) {
    throw const FormatException('Speech pack too large');
  }
  final root = jsonDecode(source);
  if (root is! Map<String, dynamic> ||
      root['formatVersion'] != 1 ||
      root['packVersion'] != 1 ||
      root['speeches'] is! List ||
      (root['speeches'] as List).isEmpty) {
    throw const FormatException('Unsupported speech pack');
  }
  return (root['speeches'] as List)
      .map((v) => MemoryDocument.parse(v))
      .toList();
}

String cueText(Map<String, dynamic> section, String stage) => switch (stage) {
  'full' => section['text'] as String,
  'phrase' =>
    (section['phrase'] as String).trim().isEmpty
        ? 'No phrase cue supplied for this section.'
        : section['phrase'] as String,
  'keywords' =>
    (section['keywords'] as String).trim().isEmpty
        ? 'No keywords supplied for this section.'
        : section['keywords'] as String,
  'title' => section['title'] as String,
  'hidden' => 'Cues are hidden. Recall the section at your own pace.',
  _ => throw ArgumentError('Unknown cue stage'),
};
