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
          'pushed_epoch INTEGER, '
          'retry_epoch INTEGER );');

  Future<EdgeModel> insert(EdgeModel edge, {Transaction? txn}) async {
    await (txn ?? _database).rawInsert(
        'INSERT INTO $table(fingerprint, v1, v2, created_epoch, nft_hash, pushed_epoch, retry_epoch) '
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
          edge.pushed?.millisecondsSinceEpoch,
          edge.retry?.millisecondsSinceEpoch
        ]);
    _log.finest('inserted: #${edge.fingerprint}');
    return edge;
  }

  Future<void> setPushed(List<String> fingerprints,
      {Transaction? txn, DateTime? pushed}) async {
    if (pushed == null) pushed = DateTime.now();
    Batch batch = (txn ?? _database).batch();
    fingerprints.forEach((fingerprint) => batch.update(
        table, {'pushed_epoch': pushed?.millisecondsSinceEpoch},
        where: 'fingerprint = ?', whereArgs: [fingerprint]));
    await batch.commit(noResult: true);
  }

  Future<void> setRetry(Map<String, DateTime> retries,
      {Transaction? txn}) async {
    Batch batch = (txn ?? _database).batch();
    retries.entries.forEach((retry) => batch.update(
        table, {'retry_epoch': retry.value.millisecondsSinceEpoch},
        where: 'fingerprint = ?', whereArgs: [retry.key]));
    await batch.commit(noResult: true);
  }

  static const _selectJoin =
      'SELECT fingerprint, $table.created_epoch, nft_hash, '
      'pushed_epoch, retry_epoch, vertex1.id as v1_id, '
      'vertex1.val as v1_val, vertex1.type as v1_type, '
      'vertex1.created_epoch as v1_created, vertex2.id as v2_id, '
      'vertex2.val as v2_val, vertex2.type as v2_type, '
      'vertex2.created_epoch as v2_created '
      'FROM $table '
      'LEFT JOIN ${VertexRepository.table} AS vertex1 ON $table.v1 = vertex1.id '
      'LEFT JOIN ${VertexRepository.table} AS vertex2 on $table.v2 = vertex2.id ';

  Future<EdgeModel?> findByFingerprint(String fingerprint,
      {Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database)
        .rawQuery('$_selectJoin WHERE fingerprint = ?', [fingerprint]);
    if (rows.isNotEmpty) {
      EdgeModel edgeModel = EdgeModel.fromMap(_map(rows[0]));
      _log.finest('findByFingerprint: $edgeModel');
      return edgeModel;
    } else
      return null;
  }

  Future<List<EdgeModel>> findAllRetries({Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).rawQuery(
        '$_selectJoin WHERE (retry_epoch <= ? OR retry_epoch IS NULL) AND pushed_epoch IS NULL',
        [DateTime.now().millisecondsSinceEpoch]);
    List<EdgeModel> edges =
        rows.map((row) => EdgeModel.fromMap(_map(row))).toList();
    _log.finest('findAllRetries: ${edges.length}');
    return edges;
  }

  Future<List<EdgeModel>> findLatest(int pageNum,
      {int pageSize = 100, Transaction? txn}) async {
    int offset = pageNum <= 1 ? 0 : pageSize * (pageNum - 1);
    List<Map<String, Object?>> rows = await (txn ?? _database).rawQuery(
        '$_selectJoin ORDER BY $table.created_epoch DESC LIMIT ?1 OFFSET ?2',
        [pageSize, offset]);
    if (rows.isNotEmpty) {
      List<EdgeModel> edges =
          rows.map((row) => EdgeModel.fromMap(_map(row))).toList();
      _log.finest('findLatest: ${edges.length} records');
      return edges;
    } else
      return List.empty();
  }

  Map<String, Object?> _map(Map<String, Object?> row) {
    Map<String, Object?> v1 = Map();
    Map<String, Object?> v2 = Map();
    Map<String, Object?> edge = Map();

    edge['fingerprint'] = row['fingerprint'];
    edge['created_epoch'] = row['created_epoch'];
    edge['nft_hash'] = row['nft_hash'];
    edge['pushed_epoch'] = row['pushed_epoch'];
    edge['retry_epoch'] = row['retry_epoch'];

    v1['id'] = row['v1_id'];
    v1['type'] = row['v1_type'];
    v1['val'] = row['v1_val'];
    v1['created_epoch'] = row['v1_created'];

    v2['id'] = row['v2_id'];
    v2['type'] = row['v2_type'];
    v2['val'] = row['v2_val'];
    v2['created_epoch'] = row['v2_created'];

    edge['v1'] = v1;
    edge['v2'] = v2;
    return edge;
  }
}
