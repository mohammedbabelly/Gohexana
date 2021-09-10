import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:http/http.dart' as http;
import 'package:hx_to_dec/Utils/api_routes.dart';
import 'package:hx_to_dec/Utils/app_loading.dart';
import 'package:hx_to_dec/models/code_model.dart';

class CodeApi {
  Future<CodeModel?> readCode(String path) async {
    try {
      showLoading();
      Uri uri = Uri.parse('$baseUrl${ApiEndPoints.readCode}');
      print(uri);
      http.MultipartRequest request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('code', path));
      http.StreamedResponse response = await request.send();
      var responseBytes = await response.stream.toBytes();
      var responseString = utf8.decode(responseBytes);
      if (response.statusCode != 200)
        BotToast.showText(text: 'Status Code: ${response.statusCode}');
      var model = CodeModel.fromRawJson(responseString);
      // var model = CodeModel.fromRawJson(res);
      closeLoading();
      return model;
    } catch (_) {
      BotToast.showText(text: _.toString());
      closeLoading();
      return null;
    }
  }

  Future<CodeModel?> generateCode(CodeModel model) async {
    try {
      showLoading();
      Uri uri = Uri.parse('$baseUrl${ApiEndPoints.generateCode}');
      var body = model.toRawJson();
      print(uri);
      print(body);
      http.Response response =
          await http.post(uri, body: body, headers: headers);
      if (response.statusCode != 200)
        BotToast.showText(text: 'Status Code: ${response.statusCode}');
      var res = CodeModel.fromRawJson(response.body);
      closeLoading();
      return res;
    } catch (_) {
      BotToast.showText(text: _.toString());
      closeLoading();
      return null;
    }
  }
}

const headers = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE'
};
var res = ''' {
    "standardization": 8832,
    "standardizationHX": "_1A_2C_1C",
    "sector": 86401,
    "sectorHX": "_1B_1G_3F",
    "entity": 17247502336,
    "entityHX": "_1A_1A_1A_1C_1E_3A",
    "timeStump": 1006632960,
    "timeStumpHX": "_1A_1A_1A_1A_8E_1A",
    "section": 2752,
    "sectionHX": "_1A_6D",
    "item": 65664,
    "itemHX": "_1A_1C_3A",
    "quality": 6,
    "qualityHX": "_1G",
    "unit": 3714,
    "unitHX": "_1C_8C",
    "validty": 40960,
    "validtyHX": "_1A_1A_2C"
} ''';
