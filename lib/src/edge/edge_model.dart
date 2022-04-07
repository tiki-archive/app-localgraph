/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import '../vertex/vertex_model.dart';

class EdgeModel {
  String? fingerprint;
  VertexModel? v1;
  VertexModel? v2;
  DateTime? created;
  Uint8List? nft;
  DateTime? pushed;
  DateTime? retry;

  EdgeModel(
      {this.fingerprint,
      this.v1,
      this.v2,
      this.created,
      this.nft,
      this.pushed,
      this.retry});

  EdgeModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      this.fingerprint = map['fingerprint'];
      this.v1 = VertexModel.fromMap(map['v1']);
      this.v2 = VertexModel.fromMap(map['v2']);
      if (map['created_epoch'] != null)
        this.created =
            DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
      this.nft = map['nft_hash'];
      if (map['pushed_epoch'] != null)
        this.created =
            DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
      if (map['retry_epoch'] != null)
        this.created =
            DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
    }
  }

  Map<String, dynamic> toMap() => {
        'fingerprint': fingerprint,
        'v1': v1?.id,
        'v2': v2?.id,
        'created_epoch': created?.millisecondsSinceEpoch,
        'nft_hash': nft,
        'pushed_epoch': pushed?.millisecondsSinceEpoch,
        'retry_epoch': retry?.millisecondsSinceEpoch
      };
}
