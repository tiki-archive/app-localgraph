/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'vertex_model.dart';

class VertexRepository {
  static const String table = 'vertex';
  final _log = Logger('VertexRepository');

  final Database _database;

  VertexRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $table('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'type TEXT NOT NULL, '
          'val TEXT NOT NULL, '
          'created_epoch INTEGER NOT NULL, '
          'UNIQUE(type,val));');

  Future<VertexModel> insert(VertexModel vertex,
      {Transaction? txn, bool ignore = false}) async {
    int id = await (txn ?? _database).insert(table, vertex.toMap(),
        conflictAlgorithm:
            ignore ? ConflictAlgorithm.ignore : ConflictAlgorithm.abort);
    vertex.id = id;
    _log.finest('inserted: #$id');
    return vertex;
  }

  Future<VertexModel?> findByTypeAndValue(String type, String value,
      {Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).query(table,
        columns: [
          'id',
          'type',
          'val',
          'created_epoch',
        ],
        where: 'type = ? AND val = ?',
        whereArgs: [type, value]);
    if (rows.isNotEmpty) {
      VertexModel vertex = VertexModel.fromMap(rows[0]);
      _log.finest('findByTypeAndValue: $vertex');
      return vertex;
    } else
      return null;
  }
}
