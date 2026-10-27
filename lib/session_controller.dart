import 'dart:async';

import 'storage/practice_repository.dart';

abstract class PracticeClock {
  DateTime localNow();
  int get monotonicMs;
}

class SystemPracticeClock implements PracticeClock {
  final _watch = Stopwatch()..start();
  @override
  DateTime localNow() => DateTime.now();
  @override
  int get monotonicMs => _watch.elapsedMilliseconds;
}

class SessionController {
  SessionController(this.repository, this.id, {PracticeClock? clock})
    : clock = clock ?? SystemPracticeClock();
  final PracticeRepository repository;
  final String id;
  final PracticeClock clock;
  SessionDetail? detail;
  String? _segmentId;
  int _anchorMs = 0;
  int _baseMs = 0;
  bool _needsRecovery = false;
  Future<void> _tail = Future.value();

  // Serialize autosaves, checkpoints and transitions; a failed write does not poison retries.
  Future<T> _queue<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<SessionDetail> open() => _queue(() async {
    detail = await repository.load(id);
    if (detail!.session.status == 'running') {
      detail = await repository.transition(
        id,
        PracticeStatus.interrupted,
        clock.localNow().toUtc(),
      );
    }
    return detail!;
  });
  int get currentSegmentMs => _segmentId == null
      ? 0
      : _baseMs + (clock.monotonicMs - _anchorMs).clamp(0, 1 << 53);
  int get elapsedMs =>
      (detail?.elapsedMs ?? 0) +
      (_segmentId == null
          ? 0
          : currentSegmentMs - (detail?.openSegment?.elapsedMs ?? 0));

  void _anchor(SessionDetail value) {
    _needsRecovery = false;
    detail = value;
    _segmentId = value.session.status == 'running'
        ? value.openSegment?.id
        : null;
    _anchorMs = clock.monotonicMs;
    _baseMs = value.openSegment?.elapsedMs ?? 0;
  }

  Future<void> saveResponse(String value) => _queue(() async {
    await repository.saveResponse(id, value, clock.localNow().toUtc());
    detail = await repository.load(id);
  });

  Future<void> _checkpoint() async {
    try {
      if (_needsRecovery) {
        detail = await repository.transition(
          id,
          PracticeStatus.interrupted,
          clock.localNow().toUtc(),
        );
        _needsRecovery = false;
      }
      await _writeCheckpoint();
    } catch (_) {
      _segmentId = null;
      _needsRecovery = true;
      if (detail case final d?) {
        detail = SessionDetail(
          d.session.copyWith(status: 'interrupted'),
          d.response,
          d.segments,
          d.review,
        );
      }
      rethrow;
    }
  }

  Future<void> _writeCheckpoint() async {
    if (_segmentId case final segment?) {
      final now = clock.monotonicMs;
      final delta = now - _anchorMs;
      // A delayed heartbeat can include machine sleep or a frozen process. Never credit that unknown interval.
      if (delta < 0 || delta > 10000) {
        detail = await repository.transition(
          id,
          PracticeStatus.interrupted,
          clock.localNow().toUtc(),
        );
        _segmentId = null;
        return;
      }
      await repository.checkpoint(
        id,
        segment,
        _baseMs + delta,
        clock.localNow().toUtc(),
      );
      _baseMs += delta;
      _anchorMs = now;
      detail = await repository.load(id);
    }
  }

  Future<void> checkpoint() => _queue(_checkpoint);
  Future<void> start() => _queue(() async {
    await _checkpoint();
    if (_segmentId != null) return;
    _anchor(await repository.start(id, clock.localNow().toUtc()));
  });
  Future<void> changeStage(PracticeStage stage) => _queue(() async {
    await _checkpoint();
    if (detail?.session.stage == stage.name) return;
    _anchor(
      await repository.transition(
        id,
        PracticeStatus.interrupted,
        clock.localNow().toUtc(),
        nextStage: stage,
      ),
    );
  });
  Future<void> transition(PracticeStatus status) => _queue(() async {
    await _checkpoint();
    _anchor(await repository.transition(id, status, clock.localNow().toUtc()));
  });
  Future<void> leave() => _queue(() async {
    await _checkpoint();
    if (detail?.session.status == 'running') {
      _anchor(
        await repository.transition(
          id,
          PracticeStatus.interrupted,
          clock.localNow().toUtc(),
        ),
      );
    }
  });
  Future<void> saveReview(String notes, ReviewStatus status) => _queue(
    () async {
      await repository.saveReview(id, notes, status, clock.localNow().toUtc());
      detail = await repository.load(id);
    },
  );
}
