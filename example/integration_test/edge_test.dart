/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localgraph/src/edge/edge_model.dart';
import 'package:localgraph/src/edge/edge_repository.dart';
import 'package:localgraph/src/edge/edge_service.dart';
import 'package:localgraph/src/vertex/vertex_model.dart';
import 'package:localgraph/src/vertex/vertex_service.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edge Tests', () {
    test('Insert - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      EdgeModel edge = EdgeModel(
          fingerprint: Uuid().v4().toString(),
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')));

      EdgeModel inserted = await edgeRepository.insert(edge);

      expect(inserted.fingerprint != null, true);
      expect(inserted.v1?.type, v1.type);
      expect(inserted.v2?.type, v2.type);
      expect(inserted.v1?.value, v1.value);
      expect(inserted.v2?.value, v2.value);
      expect(inserted.nft, edge.nft);
      expect(inserted.pushed, edge.pushed);
      expect(inserted.retry, edge.retry);
    });

    test('Insert No Edge - Fail', () async {
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

      expect(() async => await edgeRepository.insert(edge),
          throwsA(isA<DatabaseException>()));
    });

    test('FindByFingerprint - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      EdgeModel edge = EdgeModel(
          fingerprint: Uuid().v4().toString(),
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')));

      await edgeRepository.insert(edge);

      EdgeModel? found =
          await edgeRepository.findByFingerprint(edge.fingerprint!);

      expect(found != null, true);
      expect(found?.fingerprint != null, true);
      expect(found?.v1?.type, v1.type);
      expect(found?.v2?.type, v2.type);
      expect(found?.v1?.value, v1.value);
      expect(found?.v2?.value, v2.value);
      expect(found?.nft, edge.nft);
      expect(found?.pushed, edge.pushed);
      expect(found?.retry, edge.retry);
    });

    test('Retry - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      EdgeModel edge = EdgeModel(
          fingerprint: Uuid().v4().toString(),
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')));

      await edgeRepository.insert(edge);

      await edgeRepository
          .setRetry({edge.fingerprint!: DateTime.now().add(Duration(days: 1))});

      EdgeModel? found =
          await edgeRepository.findByFingerprint(edge.fingerprint!);

      expect(found?.retry != null, true);
    });

    test('Pushed - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      EdgeModel edge = EdgeModel(
          fingerprint: Uuid().v4().toString(),
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')));

      await edgeRepository.insert(edge);

      await edgeRepository.setPushed([edge.fingerprint!]);

      EdgeModel? found =
          await edgeRepository.findByFingerprint(edge.fingerprint!);

      expect(found?.pushed != null, true);
    });

    test('findAllRetries - Null - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      EdgeModel edge = EdgeModel(
          fingerprint: Uuid().v4().toString(),
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')));

      await edgeRepository.insert(edge);

      List<EdgeModel> retries = await edgeRepository.findAllRetries();

      expect(retries.length, 1);
      expect(retries.elementAt(0).fingerprint != null, true);
      expect(retries.elementAt(0).v1?.type, v1.type);
      expect(retries.elementAt(0).v2?.type, v2.type);
      expect(retries.elementAt(0).v1?.value, v1.value);
      expect(retries.elementAt(0).v2?.value, v2.value);
      expect(retries.elementAt(0).nft, edge.nft);
      expect(retries.elementAt(0).pushed, edge.pushed);
      expect(retries.elementAt(0).retry, edge.retry);
    });

    test('findAllRetries - DateTime - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      EdgeModel edge = EdgeModel(
          fingerprint: Uuid().v4().toString(),
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')),
          retry: DateTime.now());

      await edgeRepository.insert(edge);

      List<EdgeModel> retries = await edgeRepository.findAllRetries();

      expect(retries.length, 1);
      expect(retries.elementAt(0).fingerprint != null, true);
      expect(retries.elementAt(0).v1?.type, v1.type);
      expect(retries.elementAt(0).v2?.type, v2.type);
      expect(retries.elementAt(0).v1?.value, v1.value);
      expect(retries.elementAt(0).v2?.value, v2.value);
      expect(retries.elementAt(0).nft, edge.nft);
      expect(retries.elementAt(0).pushed, edge.pushed);
    });

    test('findAllRetries - 1 day - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      EdgeModel edge = EdgeModel(
          fingerprint: Uuid().v4().toString(),
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')),
          retry: DateTime.now().add(Duration(days: 1)));

      await edgeRepository.insert(edge);

      List<EdgeModel> retries = await edgeRepository.findAllRetries();

      expect(retries.length, 0);
    });

    test('findAllRetries - Pushed - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      EdgeModel edge = EdgeModel(
          fingerprint: Uuid().v4().toString(),
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')),
          pushed: DateTime.now());

      await edgeRepository.insert(edge);

      List<EdgeModel> retries = await edgeRepository.findAllRetries();

      expect(retries.length, 0);
    });
  });
}
