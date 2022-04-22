/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'edge_model.dart';
import 'edge_repository.dart';

class EdgeService {
  final _log = Logger('EdgeService');
  late final EdgeRepository _repository;

  Future<EdgeService> open(Database database) async {
    if (!database.isOpen)
      throw ArgumentError.value(database, 'database', 'database is not open');
    _repository = EdgeRepository(database);
    await _repository.createTable();
    return this;
  }

  Future<void> insert(List<EdgeModel> edges) async {
    return _repository.transaction((txn) async {
      edges.forEach((edge) async {
        await _repository.insert(edge, txn: txn);
      });
    });
  }

  Future<void> pushed(List<String> fingerprints) =>
      _repository.setPushed(fingerprints);

  Future<void> retryIn(Map<String, int> retries) =>
      _repository.setRetry(retries.map((key, value) =>
          MapEntry(key, DateTime.now().add(Duration(seconds: value)))));

  Future<List<EdgeModel>> findAllRetries() => _repository.findAllRetries();
}
