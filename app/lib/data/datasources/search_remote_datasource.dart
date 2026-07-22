import 'package:dio/dio.dart';
import '../models/search_response_model.dart';

class SearchRemoteDatasource {
  final Dio _dio;

  SearchRemoteDatasource(this._dio);

  Future<SearchResponseModel> search(String query, {String? lang, int? page, int? limit, String? sortby}) async {
    final response = await _dio.get('/search', queryParameters: {
      'q': query,
      'lang': lang,
      'page': page,
      'limit': limit,
      'sortby': sortby,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return SearchResponseModel.fromJson(response.data['data']);
  }

  Future<SearchResponseModel> getTrendingSearch({String? lang}) async {
    final response = await _dio.get('/search/trending', queryParameters: {
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return SearchResponseModel.fromJson(response.data['data']);
  }
}
