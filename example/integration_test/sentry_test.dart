
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_localgraph/src/edge/edge_model.dart';
import 'package:tiki_localgraph/src/edge/edge_repository.dart';
import 'package:tiki_localgraph/src/edge/edge_service.dart';
import 'package:tiki_localgraph/src/vertex/vertex_model.dart';
import 'package:tiki_localgraph/src/vertex/vertex_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Sentry Tests', () {
    test('Insert No Edge - Fail - caught by runZonedGuarded', () async {
      bool errorCaught = false;
      await runZonedGuarded(() async {
        Logger.root.level = Level.INFO;
        Logger.root.onRecord.listen((record) => errorCaught = true);
        WidgetsFlutterBinding.ensureInitialized();
        Database database = await openDatabase('${Uuid().v4()}.db');
        VertexService vertexService = await VertexService().open(database);

        VertexModel v1 = VertexModel(
            type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
        VertexModel v2 = VertexModel(
            type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

        vertexService.insert([v1]);

        await EdgeService().open(database);
        EdgeRepository edgeRepository = EdgeRepository(database);

        EdgeModel edge = EdgeModel(
            fingerprint: Uuid().v4().toString(),
            v1: v1,
            v2: v2,
            created: DateTime.now(),
            nft: Uint8List.fromList(utf8.encode('hello')));
        await edgeRepository.insert(edge);
        runApp(Container());
      }, (exception, stackTrace) async {
        Logger("Uncaught Exception").severe(
            "Caught by runZoneGuarded", exception, stackTrace);
      });
      expect(errorCaught, true);
    });
  });
}