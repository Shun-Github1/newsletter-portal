import 'package:newsletter_portal/domain/entities/user.dart';
import 'package:newsletter_portal/domain/repositories/profile_repository.dart';
import 'package:newsletter_portal/data/models/topic_model.dart';
import 'package:newsletter_portal/data/models/sector_model.dart';

import 'package:newsletter_portal/data/datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepositoryImpl({required this.remoteDatasource});

  @override
  Future<User> getProfile() async {
    final model = await remoteDatasource.getProfile();
    return User(
      username: model.username,
      email: model.email,
      isPro: model.isPro,
      language: model.language,
      profileIcon: model.profileIcon,
      authMethod: model.authMethod,
    );
  }

  @override
  Future<List<TopicModel>> getAllTopics({String? lang}) async {
    return await remoteDatasource.getAllTopics(lang: lang);
  }

  @override
  Future<List<SectorModel>> getSectors({String? lang}) async {
    return await remoteDatasource.getSectors(lang: lang);
  }
}
