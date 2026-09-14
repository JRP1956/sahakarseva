import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8000/api/v1');

class ApiException implements Exception {
  ApiException(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => message;
}

/// Thin JSON client. Token + role persisted in SharedPreferences.
class Api {
  Api._();
  static final Api I = Api._();

  String? token;
  String? role;
  String lang = 'en';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    token = _prefs.getString('token');
    role = _prefs.getString('role');
    lang = _prefs.getString('lang') ?? 'en';
  }

  Future<void> setLang(String l) async {
    lang = l;
    await _prefs.setString('lang', l);
  }

  Map<String, String> get _headers => {
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      };

  dynamic _handle(http.Response r) {
    if (r.statusCode >= 400) {
      String msg = r.body;
      try {
        msg = jsonDecode(r.body)['detail'].toString();
      } catch (_) {}
      throw ApiException(r.statusCode, msg);
    }
    return r.body.isEmpty ? null : jsonDecode(r.body);
  }

  Future<dynamic> get(String path) async => _handle(await http.get(Uri.parse('$apiUrl$path'), headers: _headers));
  Future<dynamic> post(String path, [Object? body]) async =>
      _handle(await http.post(Uri.parse('$apiUrl$path'), headers: _headers, body: body == null ? null : jsonEncode(body)));
  Future<dynamic> put(String path, Object body) async =>
      _handle(await http.put(Uri.parse('$apiUrl$path'), headers: _headers, body: jsonEncode(body)));
  Future<dynamic> patch(String path, Object body) async =>
      _handle(await http.patch(Uri.parse('$apiUrl$path'), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> form(String path, Map<String, String> fields) async {
    final req = http.MultipartRequest('POST', Uri.parse('$apiUrl$path'))
      ..headers['authorization'] = 'Bearer $token'
      ..fields.addAll(fields);
    return _handle(await http.Response.fromStream(await req.send()));
  }

  Future<void> _store(Map data) async {
    token = data['access_token'];
    role = data['role'];
    await _prefs.setString('token', token!);
    await _prefs.setString('role', role!);
  }

  Future<void> login(String phone, String password) async => _store(await post('/auth/login', {'phone': phone, 'password': password}));

  Future<void> register({required String phone, required String password, required String name, required String role, int? coopId}) async =>
      _store(await post('/auth/register', {'phone': phone, 'password': password, 'name': name, 'role': role, 'lang': lang, 'coop_id': coopId}));

  Future<void> logout() async {
    token = null;
    role = null;
    await _prefs.remove('token');
    await _prefs.remove('role');
  }
}

String inr(dynamic v) => '₹${double.parse(v.toString()).toStringAsFixed(0)}';
