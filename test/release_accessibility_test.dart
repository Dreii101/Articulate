import 'dart:convert';

import 'package:articulate/bootstrap.dart';
import 'package:articulate/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'startup failure remains readable with large text in a short window',
    (t) async {
      t.view.physicalSize = const Size(375, 390);
      t.view.devicePixelRatio = 1;
      t.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      // Fail content validation before any real app-storage access.
      rootBundle.clear();
      t.binding.defaultBinaryMessenger.setMockMessageHandler(
        'flutter/assets',
        (_) async =>
            ByteData.sublistView(Uint8List.fromList(utf8.encode('{}'))),
      );
      addTearDown(() {
        t.binding.defaultBinaryMessenger.setMockMessageHandler(
          'flutter/assets',
          null,
        );
        rootBundle.clear();
      });
      await t.pumpWidget(const ArticulateBootstrap());
      await t.pumpAndSettle();
      expect(find.text('Your saved work could not be opened.'), findsOneWidget);
      await t.ensureVisible(find.text('Try again'));
      expect(find.text('Try again').hitTestable(), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  for (final platform in [TargetPlatform.android, TargetPlatform.windows]) {
    testWidgets('$platform reduced motion leaves pushed content stationary', (
      t,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      await t.pumpWidget(
        MaterialApp(
          navigatorKey: navigator,
          theme: articulateTheme(Brightness.light).copyWith(platform: platform),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const Scaffold(body: Text('Before')),
        ),
      );
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Reduced motion destination')),
          ),
        ),
      );
      await t.pump();
      await t.pump(const Duration(milliseconds: 1));
      final label = find.text('Reduced motion destination');
      final initial = t.getRect(label);
      expect(label.hitTestable(), findsOneWidget);
      await t.pump(const Duration(milliseconds: 100));
      expect(t.getRect(label), initial);
      await t.pumpAndSettle();
      expect(t.getRect(label), initial);
      expect(t.takeException(), isNull);
    });
  }
}
