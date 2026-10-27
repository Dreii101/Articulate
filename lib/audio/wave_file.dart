import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

class WaveInfo {
  const WaveInfo(
    this.sampleRate,
    this.channels,
    this.durationMs,
    this.bytes,
    this.peakDb,
    this.rmsDb,
    this.repaired,
  );
  final int sampleRate, channels, durationMs, bytes;
  final double peakDb, rmsDb;
  final bool repaired;
}

// Inspect real PCM frames off the UI isolate; file metadata alone cannot prove a signal.
Future<WaveInfo> inspectWave(String path, {bool repair = false}) =>
    Isolate.run(() => _inspect(path, repair));

WaveInfo _inspect(String path, bool repair) {
  if (!File(path).existsSync()) {
    throw FileSystemException('Recording file is missing', path);
  }
  final file = File(path)
      .openSync(mode: repair ? FileMode.append : FileMode.read);
  try {
    final length = file.lengthSync();
    Uint8List read(int offset, int count) {
      file.setPositionSync(offset);
      return file.readSync(count);
    }

    String tag(Uint8List bytes) => String.fromCharCodes(bytes);
    final header = read(0, 12);
    if (header.length != 12 ||
        tag(header.sublist(0, 4)) != 'RIFF' ||
        tag(header.sublist(8)) != 'WAVE') {
      throw const FormatException('Not a PCM WAV recording');
    }
    final riffSize = ByteData.sublistView(header).getUint32(4, Endian.little);
    int offset = 12,
        rate = 0,
        channels = 0,
        align = 0,
        dataAt = 0,
        dataSize = 0,
        sizeAt = 0;
    while (offset + 8 <= length) {
      final chunk = read(offset, 8);
      final name = tag(chunk.sublist(0, 4));
      final size = ByteData.sublistView(chunk).getUint32(4, Endian.little);
      if (name == 'fmt ') {
        if (size < 16 || size > 4096 || offset + 8 + size > length) {
          throw const FormatException('Invalid WAV format header');
        }
        final fmt = ByteData.sublistView(read(offset + 8, size));
        final format = fmt.getUint16(0, Endian.little);
        channels = fmt.getUint16(2, Endian.little);
        rate = fmt.getUint32(4, Endian.little);
        align = fmt.getUint16(12, Endian.little);
        final pcm =
            format == 1 ||
            (format == 65534 &&
                size >= 40 &&
                fmt.getUint32(24, Endian.little) == 1);
        if (!pcm ||
            fmt.getUint16(14, Endian.little) != 16 ||
            channels < 1 ||
            channels > 2 ||
            align != channels * 2 ||
            rate < 8000 ||
            rate > 192000 ||
            fmt.getUint32(8, Endian.little) != rate * align) {
          throw const FormatException(
            'Only 16-bit PCM WAV with valid rate/channels is supported',
          );
        }
      } else if (name == 'data') {
        dataAt = offset + 8;
        dataSize = size;
        sizeAt = offset + 4;
        break;
      }
      if (size > length || offset + 8 + size > length) {
        throw const FormatException('Truncated WAV chunk');
      }
      offset += 8 + size + (size % 2);
    }
    if (rate == 0 || dataAt == 0) {
      throw const FormatException('Missing WAV format or data');
    }
    final needsRepair =
        riffSize + 8 > length ||
        riffSize + 8 < dataAt + dataSize ||
        riffSize < 36 ||
        dataSize == 0 ||
        dataAt + dataSize > length;
    if (needsRepair && !repair) {
      throw const FormatException('Recording header was not finalized');
    }
    if (needsRepair) dataSize = length - dataAt;
    if (dataSize < align || dataSize % align != 0) {
      throw const FormatException('No complete PCM recording frames');
    }
    double sum = 0;
    int peak = 0, samples = 0;
    for (var at = dataAt; at < dataAt + dataSize;) {
      final bytes = read(at, min(65536, dataAt + dataSize - at));
      if (bytes.isEmpty) throw const FormatException('Truncated recording');
      final values = ByteData.sublistView(bytes);
      for (var i = 0; i + 1 < bytes.length; i += 2) {
        final sample = values.getInt16(i, Endian.little);
        sum += sample * sample;
        peak = max(peak, sample.abs());
        samples++;
      }
      at += bytes.length;
    }
    if (needsRepair) {
      void writeSize(int at, int value) {
        final b = ByteData(4)..setUint32(0, value, Endian.little);
        file.setPositionSync(at);
        file.writeFromSync(b.buffer.asUint8List());
      }

      writeSize(4, length - 8);
      writeSize(sizeAt, dataSize);
      file.flushSync();
    }
    double db(double v) => 20 * log(max(v / 32768, 0.000001)) / ln10;
    return WaveInfo(
      rate,
      channels,
      (dataSize * 1000 ~/ (rate * align)),
      length,
      db(peak.toDouble()),
      db(sqrt(sum / samples)),
      needsRepair,
    );
  } finally {
    file.closeSync();
  }
}
