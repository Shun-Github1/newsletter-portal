import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/domain/repositories/feed_repository.dart';
import 'package:newsletter_portal/data/models/article_model.dart';

import 'package:newsletter_portal/data/datasources/feed_remote_datasource.dart';
import 'package:newsletter_portal/data/datasources/search_remote_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDatasource feedDatasource;
  final SearchRemoteDatasource searchDatasource;

  FeedRepositoryImpl({
    required this.feedDatasource,
    required this.searchDatasource,
  });

  @override
  Future<List<Article>> getPersonalFeed({int offset = 0, int limit = 20, String? lang, String? sortby}) async {
    final response = await feedDatasource.getPersonalFeed(offset: offset, limit: limit, lang: lang, sortby: sortby);
    return response.articles.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<Article>> getHomeFeed({String? tag, int offset = 0, int limit = 20, String? lang}) async {
    final response = await feedDatasource.getHomeFeed(tag: tag, offset: offset, limit: limit, lang: lang);
    return response.articles.map(_mapModelToEntity).toList();
  }

  @override
  Future<List<Article>> searchArticles(String query, {String? lang, int? page, int? limit, String? sortby}) async {
    final response = await searchDatasource.search(query, lang: lang, page: page, limit: limit, sortby: sortby);
    return response.articles.map(_mapModelToEntity).toList();
  }

  Article _mapModelToEntity(ArticleModel model) {
    return Article(
      id: model.articleID,
      title: model.title,
      imageUrl: model.pictureURL,
      date: DateTime.tryParse(model.date) ?? DateTime.now(),
      url: model.articleURL,
      sentimentScore: model.metrics?.sentiment,
      subjectivityScore: model.metrics?.subjectivity,
      centricScore: model.coverage?.centric,
      progressiveScore: model.coverage?.progressive,
      region: model.region,
      sector: model.sector,
      sourceCount: model.nSources,
      synopsis: model.synopsis ?? model.description,
      summary: model.summary,
      implications: model.implications,
    );
  }
}
