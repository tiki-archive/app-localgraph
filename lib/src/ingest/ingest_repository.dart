/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import 'ingest_model_req.dart';
import 'ingest_model_rsp.dart';
import 'ingest_model_rsp_data.dart';

class IngestRepository {
  final Logger _log = Logger('IngestRepository');

  static const String _path = 'https://ingest.mytiki.com/api/latest/write';

  Future<void> write(
      {required HttppClient client,
      String? accessToken,
      List<IngestModelReq>? body,
      void Function(List<IngestModelRspData>)? onSuccess,
      void Function(Object)? onError}) {
    HttppRequest request = HttppRequest(
        uri: Uri.parse(_path),
        verb: HttppVerb.POST,
        headers: HttppHeaders.typical(bearerToken: accessToken),
        body: HttppBody(jsonEncode(body?.map((e) => e.toJson()).toList())),
        timeout: Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null) {
            IngestModelRsp model = IngestModelRsp.fromJson(rsp.body?.jsonBody);
            if (model.data != null) onSuccess(model.data!);
          }
        },
        onResult: (rsp) {
          if (onError != null)
            onError(IngestModelRsp.fromJson(rsp.body?.jsonBody));
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }
}
