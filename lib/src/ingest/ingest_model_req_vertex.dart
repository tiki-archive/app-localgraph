/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class IngestModelReqVertex {
  String? type;
  String? value;

  IngestModelReqVertex({this.type, this.value});

  IngestModelReqVertex.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      this.type = json['type'];
      this.value = json['value'];
    }
  }

  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  @override
  String toString() {
    return 'IngestModelReqVertex{type: $type, value: $value}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngestModelReqVertex &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;
}
