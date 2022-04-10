/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class IngestModelRspData {
  int? retryIn;

  IngestModelRspData({this.retryIn});

  IngestModelRspData.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      this.retryIn = json['retryIn'];
    }
  }

  Map<String, dynamic> toJson() => {'retryIn': retryIn};

  @override
  String toString() {
    return 'IngestModelRsp{retryIn: $retryIn}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngestModelRspData &&
          runtimeType == other.runtimeType &&
          retryIn == other.retryIn;

  @override
  int get hashCode => retryIn.hashCode;
}
