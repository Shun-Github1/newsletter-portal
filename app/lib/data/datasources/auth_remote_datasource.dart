import 'package:dio/dio.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  Future<void> register(String email, String username, String password) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
    });
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> logout() async {
    final response = await _dio.post('/auth/logout');
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }

  Future<void> refreshToken() async {
    final response = await _dio.post('/auth/refresh');
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }
}
