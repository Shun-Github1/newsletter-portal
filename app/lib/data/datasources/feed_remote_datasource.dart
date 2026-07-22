import 'package:dio/dio.dart';
import '../models/feed_response_model.dart';
import '../models/topic_model.dart';

class FeedRemoteDatasource {
  final Dio _dio;

  FeedRemoteDatasource(this._dio);

  Future<FeedResponseModel> getHomeFeed({String? tag, int? offset, int? limit, String? lang}) async {
    final response = await _dio.get('/feed/home', queryParameters: {
      'tag': tag,
      'offset': offset,
      'limit': limit,
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return FeedResponseModel.fromJson(response.data['data']);
  }

  Future<FeedResponseModel> getPersonalFeed({int? offset, int? limit, String? lang, String? sortby}) async {
    final response = await _dio.get('/feed/personal', queryParameters: {
      'offset': offset,
      'limit': limit,
      'lang': lang,
      'sortby': sortby,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return FeedResponseModel.fromJson(response.data['data']);
  }

  Future<List<TopicModel>> getTrendingTopics({String? lang}) async {
    final response = await _dio.get('/feed/trending-topics', queryParameters: {
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<FeedResponseModel> getFeedByTopic(String topic, {int? offset, int? limit, String? lang}) async {
    final response = await _dio.get('/feed/topic/$topic', queryParameters: {
      'offset': offset,
      'limit': limit,
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return FeedResponseModel.fromJson(response.data['data']);
  }
}
