import '../session_controller.dart';
import '../storage/practice_repository.dart';
import 'debate_repository.dart';

class DebateController {
  DebateController(this.repository, String id, {PracticeClock? clock})
    : session = SessionController(repository.practice, id, clock: clock);
  final DebateRepository repository;
  final SessionController session;
  DebateRound? round;
  Future<void> _tail = Future.value();
  Future<T> _queue<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> _refresh() async {
    round = await repository.load(session.id);
  }

  Future<void> open() => _queue(() async {
    await session.open();
    await _refresh();
  });
  Future<void> save(String key, Map<String, String> fields) => _queue(() async {
    await repository.saveFields(
      session.id,
      key,
      fields,
      session.clock.localNow(),
    );
    await _refresh();
  });
  Future<void> startTimer() => _queue(() async {
    final r = round!;
    if (r.closed || r.targets[r.workspace.currentStage] == 0) {
      throw StateError('This stage is untimed.');
    }
    await session.start();
    await _refresh();
  });
  Future<void> pauseTimer() => _queue(() async {
    await session.transition(PracticeStatus.paused);
    await _refresh();
  });
  Future<void> checkpoint() => _queue(() async {
    await session.checkpoint();
    await _refresh();
  });
  Future<void> leave() => _queue(() async {
    await session.leave();
    await _refresh();
  });
  Future<void> advance(String expectedKey, {bool skip = false}) =>
      _queue(() async {
        await session.leave();
        await repository.advance(
          session.id,
          expectedKey,
          skip,
          session.clock.localNow(),
        );
        await session.open();
        await _refresh();
      });
  int elapsed(String key) => round!.elapsed(key, session.elapsedMs);
}
