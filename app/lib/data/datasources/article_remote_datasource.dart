import 'package:dio/dio.dart';
import '../models/article_detail_model.dart';

class ArticleRemoteDatasource {
  final Dio _dio;

  ArticleRemoteDatasource(this._dio);

  Future<ArticleDetailModel> getArticle(String idOrTitle, {String? lang}) async {
    final response = await _dio.get('/article/$idOrTitle', queryParameters: {
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return ArticleDetailModel.fromJson(response.data['data']);
  }

  Future<void> submitFeedback(String idOrTitle, String content) async {
    final response = await _dio.post('/article/\$idOrTitle/feedback', data: {
      'content': content,
    });
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }
}
