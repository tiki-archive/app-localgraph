/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../vertex/vertex_repository.dart';
import 'edge_model.dart';

class EdgeRepository {
  static const String table = 'edge';
  final _log = Logger('EdgeRepository');

  final Database _database;

  EdgeRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $table('
          'fingerprint TEXT PRIMARY KEY, '
          'v1 INTEGER NOT NULL, '
          'v2 INTEGER NOT NULL, '
          'created_epoch INTEGER NOT NULL, '
          'nft_hash BLOB NOT NULL, '
          'synced_epoch INTEGER, '
          'retry_epoch INTEGER );');

  Future<EdgeModel> insert(EdgeModel edge, {Transaction? txn}) async {
    await (txn ?? _database).rawInsert(
        'INSERT INTO $table(fingerprint, v1, v2, created_epoch, nft_hash, synced_epoch, retry_epoch) '
        'VALUES ( ?, '
        '(SELECT id FROM ${VertexRepository.table} WHERE type = ? AND val = ?), '
        '(SELECT id FROM ${VertexRepository.table} WHERE type = ? AND val = ?), '
        '?, ?, ?, ?)',
        [
          edge.fingerprint,
          edge.v1?.type,
          edge.v1?.value,
          edge.v2?.type,
          edge.v2?.value,
          edge.created?.millisecondsSinceEpoch,
          edge.nft,
          edge.synced?.millisecondsSinceEpoch,
          edge.retry?.millisecondsSinceEpoch
        ]);
    _log.finest('inserted: #${edge.fingerprint}');
    return edge;
  }

  Future<EdgeModel?> findByFingerprint(String fingerprint,
      {Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).rawQuery(
        'SELECT fingerprint, $table.created_epoch, nft_hash, '
        'synced_epoch, retry_epoch, vertex1.id as v1_id, '
        'vertex1.val as v1_val, vertex1.type as v1_type, '
        'vertex1.created_epoch as v1_created, vertex2.id as v2_id, '
        'vertex2.val as v2_val, vertex2.type as v2_type, '
        'vertex2.created_epoch as v2_created '
        'FROM $table '
        'LEFT JOIN ${VertexRepository.table} AS vertex1 ON $table.v1 = vertex1.id '
        'LEFT JOIN ${VertexRepository.table} AS vertex2 on $table.v2 = vertex2.id '
        'WHERE fingerprint = ?',
        [fingerprint]);
    if (rows.isNotEmpty) {
      Map<String, Object?> v1 = Map();
      Map<String, Object?> v2 = Map();
      Map<String, Object?> edge = Map();

      edge['fingerprint'] = rows[0]['fingerprint'];
      edge['created_epoch'] = rows[0]['created_epoch'];
      edge['nft_hash'] = rows[0]['nft_hash'];
      edge['synced_epoch'] = rows[0]['synced_epoch'];
      edge['retry_epoch'] = rows[0]['retry_epoch'];

      v1['id'] = rows[0]['v1_id'];
      v1['type'] = rows[0]['v1_type'];
      v1['val'] = rows[0]['v1_val'];
      v1['created_epoch'] = rows[0]['v1_created'];

      v2['id'] = rows[0]['v2_id'];
      v2['type'] = rows[0]['v2_type'];
      v2['val'] = rows[0]['v2_val'];
      v2['created_epoch'] = rows[0]['v2_created'];

      edge['v1'] = v1;
      edge['v2'] = v2;

      EdgeModel edgeModel = EdgeModel.fromMap(edge);
      _log.finest('findByFingerprint: $edgeModel');
      return edgeModel;
    } else
      return null;
  }
}
