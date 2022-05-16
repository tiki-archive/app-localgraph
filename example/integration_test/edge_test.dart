/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_localgraph/src/edge/edge_model.dart';
import 'package:tiki_localgraph/src/edge/edge_repository.dart';
import 'package:tiki_localgraph/src/edge/edge_service.dart';
import 'package:tiki_localgraph/src/vertex/vertex_model.dart';
import 'package:tiki_localgraph/src/vertex/vertex_service.dart';
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

    test('findLatest - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel v1 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      VertexModel v2 = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());

      vertexService.insert([v1, v2]);

      await EdgeService().open(database);
      EdgeRepository edgeRepository = EdgeRepository(database);

      String fp1 = Uuid().v4().toString();
      String fp2 = Uuid().v4().toString();
      String fp3 = Uuid().v4().toString();

      EdgeModel edge1 = EdgeModel(
          fingerprint: fp1,
          v1: v1,
          v2: v2,
          created: DateTime.now().subtract(Duration(hours: 1)),
          nft: Uint8List.fromList(utf8.encode('hello')));

      EdgeModel edge2 = EdgeModel(
          fingerprint: fp2,
          v1: v1,
          v2: v2,
          created: DateTime.now(),
          nft: Uint8List.fromList(utf8.encode('hello')));

      EdgeModel edge3 = EdgeModel(
          fingerprint: fp3,
          v1: v1,
          v2: v2,
          created: DateTime.now().add(Duration(hours: 1)),
          nft: Uint8List.fromList(utf8.encode('hello')));

      await edgeRepository.insert(edge1);
      await edgeRepository.insert(edge2);
      await edgeRepository.insert(edge3);

      List<EdgeModel> page1 = await edgeRepository.findLatest(1, pageSize: 2);
      List<EdgeModel> page2 = await edgeRepository.findLatest(2, pageSize: 2);

      expect(page1.length, 2);
      expect(page2.length, 1);
      expect(page1.elementAt(0).fingerprint, fp3);
      expect(page1.elementAt(1).fingerprint, fp2);
      expect(page2.elementAt(0).fingerprint, fp1);
    });
  });
}
