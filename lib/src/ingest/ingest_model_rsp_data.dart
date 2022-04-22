/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class IngestModelRspData {
  int? retryIn;
  String? fingerprint;

  IngestModelRspData({this.retryIn, this.fingerprint});

  IngestModelRspData.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      this.retryIn = json['retryIn'];
      this.fingerprint = json['fingerprint'];
    }
  }

  Map<String, dynamic> toJson() =>
      {'retryIn': retryIn, 'fingerprint': fingerprint};

  @override
  String toString() {
    return 'IngestModelRspData{retryIn: $retryIn, fingerprint: $fingerprint}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngestModelRspData &&
          runtimeType == other.runtimeType &&
          retryIn == other.retryIn &&
          fingerprint == other.fingerprint;

  @override
  int get hashCode => retryIn.hashCode ^ fingerprint.hashCode;
}
