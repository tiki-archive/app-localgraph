/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'tiki_localgraph_vertex.dart';

class TikiLocalGraphEdge {
  final TikiLocalGraphVertex _v1;
  final TikiLocalGraphVertex _v2;

  TikiLocalGraphEdge(this._v1, this._v2);

  TikiLocalGraphVertex get v1 => _v1;
  TikiLocalGraphVertex get v2 => _v2;

  @override
  String toString() {
    return 'TikiLocalGraphEdge{_v1: $_v1, _v2: $_v2}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TikiLocalGraphEdge &&
          runtimeType == other.runtimeType &&
          _v1 == other._v1 &&
          _v2 == other._v2;

  @override
  int get hashCode => _v1.hashCode ^ _v2.hashCode;
}
