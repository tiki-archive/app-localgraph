/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:localchain/localchain.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:wallet/wallet.dart';

import 'edge.dart';
import 'src/edge/edge_model.dart';
import 'src/edge/edge_service.dart';
import 'src/vertex/vertex_model.dart';
import 'src/vertex/vertex_service.dart';

export 'src/edge/edge_model.dart';
export 'src/vertex/vertex_model.dart';

class LocalGraph {
  final TikiChainService _tikiChain;
  late final EdgeService _edgeService;
  late final VertexService _vertexService;

  LocalGraph(this._tikiChain);

  Future<LocalGraph> open(Database database) async {
    _edgeService = await EdgeService().open(database);
    _vertexService = await VertexService().open(database);
    return this;
  }

  Future<List<String>> add(List<Edge> req) async {
    List<VertexModel> vertices = List.empty(growable: true);
    List<EdgeModel> edges = List.empty(growable: true);
    List<String> fingerprints = List.empty(growable: true);
    for (Edge edge in req) {
      DateTime now = DateTime.now();
      VertexModel v1 =
          VertexModel(type: edge.v1.type, value: edge.v1.value, created: now);
      VertexModel v2 =
          VertexModel(type: edge.v2.type, value: edge.v2.value, created: now);
      vertices.addAll([v1, v2]);

      final List<String> vString = <String>[
        '${edge.v1.type}:${edge.v1.value}',
        '${edge.v2.type}:${edge.v2.value}'
      ];
      vString.sort();

      TikiChainCacheBlock block = await _tikiChain
          .mint(Uint8List.fromList(utf8.encode(vString.join(','))));

      BlockContentsDataNft nft =
          Localchain.codec.decode(block.plaintextContents!);

      edges.add(EdgeModel(
          v1: v1,
          v2: v2,
          created: now,
          nft: block.hash,
          fingerprint: nft.fingerprint));

      fingerprints.add(nft.fingerprint!);
    }
    await _vertexService.insert(vertices);
    await _edgeService.insert(edges);
    return fingerprints;
  }
}
