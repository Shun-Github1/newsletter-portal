import 'package:newsletter_portal/domain/entities/article.dart';

abstract class FeedRepository {
  Future<List<Article>> getPersonalFeed({int offset = 0, int limit = 20, String? lang, String? sortby});
  Future<List<Article>> getHomeFeed({String? tag, int offset = 0, int limit = 20, String? lang});
  Future<List<Article>> searchArticles(String query, {String? lang, int? page, int? limit, String? sortby});
}
