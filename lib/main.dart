import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final name in [
      'NATIVE-NOTICES',
      'mpv-Copyright',
      'LGPL-2.1',
      'LGPL-3.0',
      'GPL-3.0',
    ]) {
      yield LicenseEntryWithLineBreaks([
        'Native audio libraries',
      ], await rootBundle.loadString('assets/licenses/$name.txt'));
    }
    for (final name in ['Manrope', 'Lora']) {
      yield LicenseEntryWithLineBreaks([
        name,
      ], await rootBundle.loadString('assets/fonts/$name-OFL.txt'));
    }
  });
  runApp(const ArticulateBootstrap());
}
