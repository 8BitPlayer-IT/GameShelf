import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameshelf/app/version.dart';
import 'package:gameshelf/data/database.dart';

void main() {
  test('la versione nel codice e quella del pubspec sono la stessa', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    final RegExpMatch? riga = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(riga, isNotNull, reason: 'pubspec.yaml deve avere una riga «version: x.y.z+n»');
    expect(
      riga!.group(1),
      appVersion,
      reason: 'cambiando lib/app/version.dart va cambiato anche pubspec.yaml',
    );
    expect(int.parse(riga.group(2)!), greaterThanOrEqualTo(2), reason: 'il numero di build cresce a ogni APK');
  });

  test('la prima cifra della versione è la versione dello schema del database', () {
    final AppDatabase db = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    );
    addTearDown(db.close);

    expect(
      appVersion.split('.').first,
      '${db.schemaVersion}',
      reason: 'è la regola della numerazione: x = schema del database',
    );
  });
}
