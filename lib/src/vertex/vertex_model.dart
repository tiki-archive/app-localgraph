/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class VertexModel {
  int? id;
  String? type;
  String? value;
  DateTime? created;

  VertexModel({this.id, this.type, this.value, this.created});

  VertexModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      this.id = map['id'];
      this.type = map['type'];
      this.value = map['val'];
      if (map['created_epoch'] != null)
        this.created =
            DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'val': value,
        'created_epoch': created?.millisecondsSinceEpoch
      };

  @override
  String toString() {
    return 'VertexModel{id: $id, type: $type, value: $value, created: $created}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VertexModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          value == other.value &&
          created == other.created;

  @override
  int get hashCode =>
      id.hashCode ^ type.hashCode ^ value.hashCode ^ created.hashCode;
}
