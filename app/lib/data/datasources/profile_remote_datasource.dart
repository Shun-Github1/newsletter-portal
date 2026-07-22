import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/topic_model.dart';
import '../models/sector_model.dart';
import '../models/region_response_model.dart';
import '../models/article_model.dart';

class ProfileRemoteDatasource {
  final Dio _dio;

  ProfileRemoteDatasource(this._dio);

  Future<UserModel> getProfile() async {
    final response = await _dio.get('/profile');
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> changeLanguage(String lang) async {
    final response = await _dio.post('/profile/language', data: {'language': lang});
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }

  Future<List<TopicModel>> getTopics({String? lang}) async {
    final response = await _dio.get('/profile/topics', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    final data = response.data['data'];
    final topicsList = data is Map<String, dynamic> ? (data['topics'] as List? ?? []) : (data as List? ?? []);
    return topicsList.map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<List<TopicModel>> getAllTopics({String? lang}) async {
    final response = await _dio.get('/profile/listtopics', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    final data = response.data['data'];
    final topicsList = data is Map<String, dynamic> ? (data['topics'] as List? ?? []) : (data as List? ?? []);
    return topicsList.map((e) => TopicModel.fromJson(e)).toList();
  }

  Future<void> editTopic(String action, String topic, {String? lang}) async {
    final response = await _dio.post('/profile/edittopic', queryParameters: {
      'action': action,
      'topic': topic,
      'lang': lang,
    }..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }

  Future<List<SectorModel>> getSectors({String? lang}) async {
    final response = await _dio.get('/sectors', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => SectorModel.fromJson(e)).toList();
  }

  Future<RegionResponseModel> getPublisherRegions({String? lang}) async {
    final response = await _dio.get('/profile/regions', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return RegionResponseModel.fromJson(response.data['data']);
  }

  Future<void> editPublisherRegion(String action, String tag, {String? lang}) async {
    final response = await _dio.post('/profile/regions/edit', data: {
      'action': action,
      'tag': tag,
    }, queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }

  Future<List<ArticleModel>> getHistory({String? lang}) async {
    final response = await _dio.get('/profile/history', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<List<ArticleModel>> getSaved({String? lang}) async {
    final response = await _dio.get('/profile/saved', queryParameters: {'lang': lang}..removeWhere((k, v) => v == null));
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
    return (response.data['data'] as List).map((e) => ArticleModel.fromJson(e)).toList();
  }

  Future<void> saveArticle(String articleId) async {
    final response = await _dio.post('/profile/saved/add', data: {'articleId': articleId});
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }

  Future<void> addToReadingHistory(String articleId) async {
    final response = await _dio.post('/profile/history/add', data: {'articleId': articleId});
    if (response.data['code'] != 0 && response.data['code'] != 200) {
      throw Exception(response.data['msg']);
    }
  }
}
