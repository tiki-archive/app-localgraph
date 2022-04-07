/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localgraph/edge.dart';
import 'package:localgraph/localgraph.dart';
import 'package:localgraph/src/edge/edge_model.dart';
import 'package:localgraph/src/edge/edge_repository.dart';
import 'package:localgraph/src/vertex/vertex_model.dart';
import 'package:localgraph/src/vertex/vertex_service.dart';
import 'package:localgraph/vertex.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Localgraph Tests', () {
    test('Add One - Success', () async {
      TikiKeysService tikiKeysService = TikiKeysService();
      TikiKeysModel keys = await tikiKeysService.generate();

      Database database = await openDatabase('${Uuid().v4()}.db');

      TikiChainService tikiChainService =
          await TikiChainService(keys).open(database);
      LocalGraph localGraph = await LocalGraph(tikiChainService).open(database);

      Vertex v1 = Vertex(Uuid().v4(), 'value1');
      Vertex v2 = Vertex(Uuid().v4(), 'value2');

      List<String> fingerprints = await localGraph.add([Edge(v1, v2)]);
      expect(fingerprints.length, 1);

      VertexService vertexService = await VertexService().open(database);

      VertexModel? foundV1 = await vertexService.find(v1.type, v1.value);
      expect(foundV1 != null, true);
      expect(foundV1?.value, v1.value);
      expect(foundV1?.type, v1.type);

      VertexModel? foundV2 = await vertexService.find(v2.type, v2.value);
      expect(foundV2 != null, true);
      expect(foundV2?.value, v2.value);
      expect(foundV2?.type, v2.type);

      EdgeRepository edgeRepository = EdgeRepository(database);
      EdgeModel? foundE =
          await edgeRepository.findByFingerprint(fingerprints.first);
      expect(foundE != null, true);
    });
  });
}
