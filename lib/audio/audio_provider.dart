import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'audio_backend.dart';
import 'audio_store.dart';
import 'local_audio.dart';

final localAudioProvider = FutureProvider<LocalAudio>((ref) async {
  final store = await AudioStore.open(ref.watch(repositoryProvider));
  await store.reconcile();
  final audio = LocalAudio(store, NativeAudioBackend());
  ref.onDispose(() {
    unawaited(audio.close().catchError((Object _) {}));
  });
  return audio;
});
