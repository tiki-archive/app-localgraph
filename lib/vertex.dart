/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class Vertex {
  final String _type;
  final String _value;

  Vertex(this._type, this._value);

  String get type => _type;
  String get value => _value;

  @override
  String toString() {
    return 'Vertex{_type: $_type, _value: $_value}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vertex &&
          runtimeType == other.runtimeType &&
          _type == other._type &&
          _value == other._value;

  @override
  int get hashCode => _type.hashCode ^ _value.hashCode;
}
