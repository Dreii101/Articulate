import '../session_controller.dart';
import '../storage/practice_repository.dart';
import 'impromptu_repository.dart';

class ImpromptuController {
  ImpromptuController(this.repository, String id, {PracticeClock? clock})
    : session = SessionController(repository.practice, id, clock: clock);
  final ImpromptuRepository repository;
  final SessionController session;
  ImpromptuAttempt? attempt;
  Future<void> _tail = Future.value();
  Future<void> _queue(Future<void> Function() action) {
    final result = _tail.then((_) => action());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> refresh() async {
    attempt = await repository.load(session.id);
  }

  Future<void> open() => _queue(() async {
    await session.open();
    await refresh();
  });
  Future<void> startTimer() => _queue(() async {
    final a = attempt!;
    final index = a.workspace.viewStep == 'prepare'
        ? 0
        : a.workspace.viewStep == 'respond'
        ? 1
        : -1;
    if (a.closed || index < 0 || a.targets[index] == 0) {
      throw StateError('This stage is untimed.');
    }
    await session.start();
    await refresh();
  });
  Future<void> pause() => _queue(() async {
    await session.transition(PracticeStatus.paused);
    await refresh();
  });
  Future<void> checkpoint() => _queue(() async {
    await session.checkpoint();
    await refresh();
  });
  Future<void> leave() => _queue(() async {
    await session.leave();
    await refresh();
  });
  Future<void> advance(String expected) => _queue(() async {
    await session.leave();
    await repository.advance(session.id, expected, session.clock.localNow());
    await session.open();
    await refresh();
  });
  int elapsed(PracticeStage stage) =>
      (session.detail?.elapsedFor(stage) ?? 0) +
      (session.detail?.session.stage == stage.name
          ? session.elapsedMs - (session.detail?.elapsedMs ?? 0)
          : 0);
}
