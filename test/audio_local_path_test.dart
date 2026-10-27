import 'package:articulate/audio/audio_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'native playback rejects remote and relative paths before opening a player',
    () async {
      final backend = NativeAudioBackend();
      for (final path in [
        'https://example.invalid/take.wav',
        'http://localhost/take.wav',
        r'\\server\take.wav',
        '//server/take.wav',
        'relative.wav',
      ]) {
        await expectLater(backend.open(path), throwsArgumentError);
      }
      await backend.dispose();
    },
  );
}
