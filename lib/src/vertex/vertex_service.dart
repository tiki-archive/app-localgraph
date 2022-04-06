/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'vertex_model.dart';
import 'vertex_repository.dart';

class VertexService {
  final _log = Logger('VertexService');
  late final VertexRepository _repository;

  Future<VertexService> open(Database database) async {
    if (!database.isOpen)
      throw ArgumentError.value(database, 'database', 'database is not open');
    _repository = VertexRepository(database);
    await _repository.createTable();
    return this;
  }

  Future<void> insert(List<VertexModel> vertices) async {
    return _repository.transaction((txn) async {
      vertices.forEach((vertex) async {
        await _repository.insert(vertex, txn: txn, ignore: true);
      });
    });
  }

  Future<VertexModel?> find(String type, String value) =>
      _repository.findByTypeAndValue(type, value);
}
