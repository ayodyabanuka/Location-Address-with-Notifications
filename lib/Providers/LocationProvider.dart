import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationProvider with ChangeNotifier {
  address(data) async {
    return await http.post(
        Uri.parse(
            "http://sindhizbackend.sindhizgroup.com.au/public/api/addlocation"),
        body: jsonEncode(data),
        headers: _setHeaders());
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer',
        'Connection': 'keep-alive',
      };
}
