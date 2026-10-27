import 'dart:convert';

import 'memory/memory_document.dart';
import 'debate/debate_content.dart';
import 'impromptu/impromptu_content.dart';

const moduleIds = {
  'writing',
  'reading',
  'speech',
  'memory',
  'debate',
  'impromptu',
};
const exerciseLevels = {'beginner', 'intermediate', 'advanced'};

class Exercise {
  Exercise._(this.snapshot);
  final String snapshot;
  Map<String, dynamic> get document =>
      jsonDecode(snapshot) as Map<String, dynamic>;
  Map<String, dynamic> get content =>
      (document['exercises'] as List).single as Map<String, dynamic>;
  String get id => content['id'] as String;
  String get module => content['module'] as String;
  String get level => content['level'] as String;
  int get version => content['version'] as int;
  int get packVersion => document['packVersion'] as int;
  String get title => content['title'] as String;
  String get prompt => content['prompt'] as String;
  String get focus => content['focus'] as String;
  String get language => content['language'] as String;
  List<Map<String, dynamic>> get criteria =>
      (content['rubric']['criteria'] as List).cast<Map<String, dynamic>>();

  factory Exercise.fromSnapshot(String value) =>
      validateExercisePack(value).single;
}

// Validate the whole pack before exposing any exercise or creating an attempt.
List<Exercise> validateExercisePack(String source) {
  Never invalid(String path) =>
      throw FormatException('Invalid exercise content: $path');
  if (source.length > 1000000 || utf8.encode(source).length > 1000000) {
    invalid('pack exceeds 1 MB');
  }
  Map<String, dynamic> object(
    Object? value,
    String path,
    Set<String> keys, {
    Set<String> optional = const {},
  }) {
    if (value is! Map<String, dynamic> ||
        value.keys.toSet().difference({...keys, ...optional}).isNotEmpty ||
        keys.difference(value.keys.toSet()).isNotEmpty) {
      invalid(path);
    }
    return value;
  }

  String text(Object? value, String path, {int max = 50000}) {
    if (value is! String || value.trim().isEmpty || value.length > max) {
      invalid(path);
    }
    return value;
  }

  void version(Object? value, String path) {
    if (value is! int || value < 1) invalid(path);
  }

  void identifier(Object? value, String path) {
    if (!RegExp(r'^[a-z][a-z0-9-]{0,79}$')
        .hasMatch(text(value, path, max: 80))) {
      invalid(path);
    }
  }

  final root = object(jsonDecode(source), 'root', {
    'formatVersion',
    'packId',
    'packVersion',
    'exercises',
  });
  if (root['formatVersion'] is! int || root['formatVersion'] != 1) {
    invalid('unsupported formatVersion');
  }
  identifier(root['packId'], 'packId');
  version(root['packVersion'], 'packVersion');
  final entries = root['exercises'];
  if (entries is! List || entries.isEmpty || entries.length > 1000) {
    invalid('exercises');
  }
  final ids = <String>{};
  final result = <Exercise>[];
  for (final entry in entries) {
    final e = object(
      entry,
      'exercise',
      {
        'id',
        'version',
        'module',
        'language',
        'level',
        'title',
        'prompt',
        'focus',
        'rubric',
        'authorship',
        'license',
      },
      optional: {'writing', 'reading', 'memory', 'debate', 'impromptu'},
    );
    if (e.containsKey('impromptu')) {
      if (e['module'] != 'impromptu') {
        invalid('impromptu metadata on another module');
      }
      validateImpromptuContent(e['impromptu'], e['rubric']);
    }
    if (e.containsKey('debate')) {
      if (e['module'] != 'debate') invalid('debate metadata on another module');
      validateDebateContent(e['debate'], e['rubric']);
    }
    if (e.containsKey('memory')) {
      if (e['module'] != 'memory') invalid('memory metadata on another module');
      validateMemorySnapshot(e['memory']);
      final memory = e['memory'] as Map<String, dynamic>;
      final speech = MemoryDocument.parse(memory['speech']);
      final section = speech.sections.singleWhere(
        (s) => s['id'] == memory['sectionId'],
      );
      if (e['version'] != memory['versionNumber'] ||
          e['language'] != speech.data['language'] ||
          e['level'] != speech.data['level'] ||
          e['prompt'] != section['text']) {
        invalid('memory snapshot does not match the practiced version');
      }
    }
    if (e.containsKey('reading')) {
      if (e['module'] != 'reading') {
        invalid('reading metadata on another module');
      }
      final reading = object(e['reading'], 'reading', {'passage', 'questions'});
      final paragraphs = reading['passage'];
      if (paragraphs is! List || paragraphs.isEmpty || paragraphs.length > 20) {
        invalid('reading.passage');
      }
      final paragraphIds = <String>{};
      for (final value in paragraphs) {
        final p = object(value, 'paragraph', {'id', 'text'});
        identifier(p['id'], 'paragraph.id');
        if (!paragraphIds.add(p['id'] as String)) {
          invalid('duplicate paragraph');
        }
        text(p['text'], 'paragraph.text');
      }
      final questions = reading['questions'];
      if (questions is! List || questions.isEmpty || questions.length > 20) {
        invalid('reading.questions');
      }
      final questionIds = <String>{};
      final kinds = <String>{};
      for (final value in questions) {
        final q = object(
          value,
          'question',
          {'id', 'kind', 'prompt'},
          optional: {
            'options',
            'answerKey',
            'rationale',
            'sampleReasoning',
            'reviewPrompts',
          },
        );
        identifier(q['id'], 'question.id');
        if (!questionIds.add(q['id'] as String)) invalid('duplicate question');
        final kind = q['kind'];
        if (!{
          'literal',
          'inference',
          'evidence',
          'summary',
          'critical',
        }.contains(kind)) {
          invalid('question.kind');
        }
        kinds.add(kind as String);
        text(q['prompt'], 'question.prompt');
        if (kind == 'summary' || kind == 'critical') {
          if (q.containsKey('options') ||
              q.containsKey('answerKey') ||
              q.containsKey('rationale')) {
            invalid('open question cannot have a key');
          }
          text(q['sampleReasoning'], 'sampleReasoning');
          final prompts = q['reviewPrompts'];
          if (prompts is! List || prompts.isEmpty || prompts.length > 5) {
            invalid('reviewPrompts');
          }
          for (final p in prompts) {
            text(p, 'reviewPrompt');
          }
        } else {
          if (q.containsKey('sampleReasoning') ||
              q.containsKey('reviewPrompts')) {
            invalid('closed question guidance');
          }
          final options = q['options'];
          if (options is! List || options.length < 2 || options.length > 6) {
            invalid('question.options');
          }
          final optionIds = <String>{};
          for (final value in options) {
            final o = object(
              value,
              'option',
              {'id', 'text'},
              optional: {'paragraphId'},
            );
            identifier(o['id'], 'option.id');
            if (!optionIds.add(o['id'] as String)) invalid('duplicate option');
            text(o['text'], 'option.text');
            if (kind == 'evidence'
                ? !paragraphIds.contains(o['paragraphId'])
                : o.containsKey('paragraphId')) {
              invalid('option.paragraphId');
            }
          }
          if (!optionIds.contains(q['answerKey'])) invalid('answerKey');
          text(q['rationale'], 'rationale');
        }
      }
      if (!kinds.containsAll({
        'literal',
        'inference',
        'evidence',
        'summary',
        'critical',
      })) {
        invalid('reading question coverage');
      }
    }
    if (e.containsKey('writing')) {
      if (e['module'] != 'writing') {
        invalid('writing metadata on another module');
      }
      final writing = object(e['writing'], 'writing', {
        'audience',
        'purpose',
        'kind',
        'outlineHint',
      });
      for (final key in writing.keys) {
        text(writing[key], 'writing.$key');
      }
      if (!{
        'paragraph',
        'explanation',
        'essay',
        'argument',
        'revision',
      }.contains(writing['kind'])) {
        invalid('writing.kind');
      }
    }
    identifier(e['id'], 'id');
    if (!ids.add(e['id'] as String)) invalid('duplicate exercise id');
    version(e['version'], 'exercise.version');
    if (!moduleIds.contains(e['module'])) invalid('module');
    if (!exerciseLevels.contains(e['level'])) invalid('level');
    if (!RegExp(r'^[a-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$')
        .hasMatch(text(e['language'], 'language', max: 35))) {
      invalid('language');
    }
    for (final key in ['title', 'prompt', 'focus']) {
      text(e[key], key);
    }
    final author = object(e['authorship'], 'authorship', {
      'creator',
      'kind',
      'source',
    });
    for (final key in author.keys) {
      text(author[key], 'authorship.$key');
    }
    if (!{'original', 'adapted', 'licensed'}.contains(author['kind'])) {
      invalid('authorship.kind');
    }
    final license = object(e['license'], 'license', {'id', 'notice'});
    text(license['id'], 'license.id', max: 100);
    text(license['notice'], 'license.notice');
    final rubric = object(e['rubric'], 'rubric', {'id', 'version', 'criteria'});
    identifier(rubric['id'], 'rubric.id');
    version(rubric['version'], 'rubric.version');
    final criteria = rubric['criteria'];
    if (criteria is! List || criteria.isEmpty || criteria.length > 20) {
      invalid('rubric.criteria');
    }
    final criteriaIds = <String>{};
    for (final value in criteria) {
      final c = object(
        value,
        'criterion',
        {'id', 'label', 'description'},
        optional: {'anchors'},
      );
      identifier(c['id'], 'criterion.id');
      if (!criteriaIds.add(c['id'] as String)) {
        invalid('duplicate criterion id');
      }
      text(c['label'], 'criterion.label');
      text(c['description'], 'criterion.description');
      if (c.containsKey('anchors')) {
        final anchors = object(c['anchors'], 'criterion.anchors', {
          'emerging',
          'developing',
          'effective',
        });
        for (final key in anchors.keys) {
          text(anchors[key], 'criterion.anchors.$key');
        }
      }
    }
    if (e.containsKey('writing') &&
        (!criteriaIds.containsAll({
              'purpose',
              'organization',
              'support',
              'clarity',
            }) ||
            criteriaIds.length != 4 ||
            criteria.any((c) => !(c as Map).containsKey('anchors')))) {
      invalid('writing rubric');
    }
    result.add(
      Exercise._(
        jsonEncode({
          ...root,
          'exercises': [e],
        }),
      ),
    );
  }
  return List.unmodifiable(result);
}
