/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'vertex.dart';

class Edge {
  final Vertex _v1;
  final Vertex _v2;

  Edge(this._v1, this._v2);

  Vertex get v1 => _v1;
  Vertex get v2 => _v2;

  @override
  String toString() {
    return 'Edge{_v1: $_v1, _v2: $_v2}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Edge &&
          runtimeType == other.runtimeType &&
          _v1 == other._v1 &&
          _v2 == other._v2;

  @override
  int get hashCode => _v1.hashCode ^ _v2.hashCode;
}
