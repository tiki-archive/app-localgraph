/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_localgraph/src/vertex/vertex_model.dart';
import 'package:tiki_localgraph/src/vertex/vertex_service.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Vertex Tests', () {
    test('Insert - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel vertex = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      vertexService.insert([vertex]);

      VertexModel? found =
          await vertexService.find(vertex.type!, vertex.value!);

      expect(found != null, true);
      expect(found?.id != null, true);
      expect(found?.value, vertex.value);
      expect(found?.type, vertex.type);
    });

    test('Insert Bulk - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      List<VertexModel> vertices = List.empty(growable: true);
      for (int i = 0; i < 20; i++) {
        vertices.add(VertexModel(
            type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now()));
      }
      vertexService.insert(vertices);

      vertices.forEach((vertex) async {
        VertexModel? found =
            await vertexService.find(vertex.type!, vertex.value!);

        expect(found != null, true);
        expect(found?.id != null, true);
        expect(found?.value, vertex.value);
        expect(found?.type, vertex.type);
      });
    });

    test('Insert Duplicates - Success', () async {
      Database database = await openDatabase('${Uuid().v4()}.db');
      VertexService vertexService = await VertexService().open(database);

      VertexModel vertex = VertexModel(
          type: Uuid().v4(), value: Uuid().v4(), created: DateTime.now());
      vertexService.insert([vertex, vertex]);

      VertexModel? found =
          await vertexService.find(vertex.type!, vertex.value!);

      expect(found != null, true);
      expect(found?.id != null, true);
      expect(found?.value, vertex.value);
      expect(found?.type, vertex.type);
    });
  });
}
