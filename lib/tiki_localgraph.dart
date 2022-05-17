/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:httpp/httpp.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';
import 'package:tiki_localchain/tiki_localchain.dart';
import 'package:tiki_wallet/tiki_wallet.dart';

import 'src/edge/edge_model.dart';
import 'src/edge/edge_service.dart';
import 'src/ingest/ingest_model_req.dart';
import 'src/ingest/ingest_model_req_vertex.dart';
import 'src/ingest/ingest_service.dart';
import 'src/vertex/vertex_model.dart';
import 'src/vertex/vertex_service.dart';
import 'tiki_localgraph_edge.dart';

export 'src/edge/edge_model.dart';
export 'src/vertex/vertex_model.dart';

class TikiLocalGraph {
  final TikiChainService _tikiChain;
  late final EdgeService _edgeService;
  late final VertexService _vertexService;
  late final IngestService _ingestService;
  late final String? Function() _accessToken;

  TikiLocalGraph(this._tikiChain);

  Future<TikiLocalGraph> open(Database database,
      {Httpp? httpp,
      Future<void> Function(void Function(String?)? onSuccess)? refresh,
      String? Function()? accessToken}) async {
    _edgeService = await EdgeService().open(database);
    _vertexService = await VertexService().open(database);
    _ingestService = IngestService(
        edgeService: _edgeService, httpp: httpp, refresh: refresh);
    _accessToken = accessToken ?? () => null;
    retry();
    return this;
  }

  Future<List<String>> add(List<TikiLocalGraphEdge> req) async {
    Map<String, MapEntry<VertexModel, VertexModel>> vertices = {};
    Map<String, Uint8List> mintReq = {};
    DateTime now = DateTime.now();

    for (int i = 0; i < req.length; i++) {
      TikiLocalGraphEdge edge = req.elementAt(i);
      VertexModel v1 =
          VertexModel(type: edge.v1.type, value: edge.v1.value, created: now);
      VertexModel v2 =
          VertexModel(type: edge.v2.type, value: edge.v2.value, created: now);

      vertices[i.toString()] = MapEntry(v1, v2);

      final List<String> vString = <String>[
        '${edge.v1.type}:${edge.v1.value}',
        '${edge.v2.type}:${edge.v2.value}'
      ];
      vString.sort();

      mintReq[i.toString()] =
          Uint8List.fromList(utf8.encode(vString.join(',')));
    }

    Map<String, TikiChainBlock> nfts = await _tikiChain.mint(mintReq);
    List<EdgeModel> edges = List.empty(growable: true);
    List<IngestModelReq> pushes = List.empty(growable: true);
    List<String> fingerprints = List.empty(growable: true);

    nfts.forEach((id, block) {
      MapEntry<VertexModel, VertexModel>? vpair = vertices[id];
      String? fingerprint =
          BlockContentsDataNft.payload(block.plaintext!).fingerprint;

      if (vpair != null && fingerprint != null) {
        edges.add(EdgeModel(
            v1: VertexModel(
                type: vpair.key.type, value: vpair.key.value, created: now),
            v2: VertexModel(
                type: vpair.value.type, value: vpair.value.value, created: now),
            created: now,
            nft: block.hash,
            fingerprint: fingerprint));

        pushes.add(IngestModelReq(
            fingerprint: fingerprint,
            vertex1: IngestModelReqVertex(
                type: vpair.key.type, value: vpair.key.value),
            vertex2: IngestModelReqVertex(
                type: vpair.value.type, value: vpair.value.value)));

        fingerprints.add(fingerprint);
      }
    });

    if (pushes.length > 0)
      _ingestService.write(req: pushes, accessToken: _accessToken());
    if (vertices.length > 0)
      await _vertexService.insert(
          vertices.values.expand((entry) => [entry.key, entry.value]).toList());
    if (edges.length > 0) await _edgeService.insert(edges);
    return fingerprints;
  }

  Future<void> retry() async {
    List<IngestModelReq> retries = (await _edgeService.findAllRetries())
        .map((edge) => IngestModelReq(
            fingerprint: edge.fingerprint,
            vertex1: IngestModelReqVertex(
                type: edge.v1?.type, value: edge.v1?.value),
            vertex2: IngestModelReqVertex(
                type: edge.v2?.type, value: edge.v2?.value)))
        .toList();
    if (retries.length > 0)
      return _ingestService.write(req: retries, accessToken: _accessToken());
  }

  Future<List<EdgeModel>> latest(int pageNum, {int pageSize = 100}) =>
      _edgeService.findLatest(pageNum, pageSize: pageSize);
}
