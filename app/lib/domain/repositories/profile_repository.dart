import 'package:newsletter_portal/domain/entities/user.dart';
import 'package:newsletter_portal/data/models/topic_model.dart';
import 'package:newsletter_portal/data/models/sector_model.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<List<TopicModel>> getAllTopics({String? lang});
  Future<List<SectorModel>> getSectors({String? lang});
}
