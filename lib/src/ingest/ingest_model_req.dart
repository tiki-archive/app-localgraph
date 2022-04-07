/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'ingest_model_req_vertex.dart';

class IngestModelReq {
  String? fingerprint;
  IngestModelReqVertex? vertex1;
  IngestModelReqVertex? vertex2;

  IngestModelReq({this.fingerprint, this.vertex1, this.vertex2});

  IngestModelReq.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      this.fingerprint = json['fingerprint'];
      this.vertex1 = IngestModelReqVertex.fromJson(json['vertex1']);
      this.vertex2 = IngestModelReqVertex.fromJson(json['vertex2']);
    }
  }

  Map<String, dynamic> toJson() => {
        'fingerprint': fingerprint,
        'vertex1': vertex1?.toJson(),
        'vertex2': vertex2?.toJson()
      };

  @override
  String toString() {
    return 'IngestModelReq{fingerprint: $fingerprint, vertex1: $vertex1, vertex2: $vertex2}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngestModelReq &&
          runtimeType == other.runtimeType &&
          fingerprint == other.fingerprint &&
          vertex1 == other.vertex1 &&
          vertex2 == other.vertex2;

  @override
  int get hashCode =>
      fingerprint.hashCode ^ vertex1.hashCode ^ vertex2.hashCode;
}
