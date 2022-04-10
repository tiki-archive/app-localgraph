/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'ingest_model_rsp_data.dart';
import 'ingest_model_rsp_message.dart';
import 'ingest_model_rsp_page.dart';

class IngestModelRsp<T> {
  String? status;
  int? code;
  IngestModelRspData? data;
  IngestModelRspPage? page;
  List<IngestModelRspMessage>? messages;

  IngestModelRsp({this.status, this.code, this.data, this.page, this.messages});

  IngestModelRsp.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      status = json['status'];
      code = json['code'];

      data = IngestModelRspData.fromJson(json['data']);
      page = IngestModelRspPage.fromJson(json['page']);

      if (json['messages'] != null)
        this.messages = (json['messages'] as List)
            .map((e) => IngestModelRspMessage.fromJson(e))
            .toList();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'status': status,
        'code': code,
        'data': data?.toJson(),
        'page': page?.toJson(),
        'messages': messages?.map((e) => e.toJson()).toList()
      };
}
